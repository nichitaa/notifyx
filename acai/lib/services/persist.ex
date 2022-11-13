defmodule Acai.Services.Persist do
  alias Acai.ServicesAgent
  alias Acai.Services.Auth

  @recv_timeout 1000
  @list_token_endpoint "/api/topics"
  @create_topic_endpoint "/api/topics"
  @subscribe_to_topic_endpoint "/api/subscribers"
  @create_notification_endpoint "/api/notifications"
  @get_notifications_endpoint "/api/notifications"
  @commit_2pc_notification_endpoint "/api/notifications/commit_2pc"
  @rollback_2pc_notification_endpoint "/api/notifications/rollback_2pc"

  ## Topics

  def list_topics(socket) do
    headers = get_headers(socket)
    options = get_options()

    with {:ok, base_url} <- base_url(),
         list_topics_url <- base_url <> @list_token_endpoint,
         response <- HTTPoison.get(list_topics_url, headers, options),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- response,
         %{"success" => true, "data" => data} <- Jason.decode!(body) do
      {:ok, data}
    else
      _ -> {:error, nil}
    end
  end

  def create_topic(socket, topic_name) do
    headers = get_headers(socket)

    options = get_options()
    body = Jason.encode!(%{name: topic_name, longevity: 10, status: "active"})

    with {:ok, base_url} <- base_url(),
         create_topic_url <- base_url <> @create_topic_endpoint,
         response <- HTTPoison.post(create_topic_url, body, headers, options),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- response,
         %{"success" => true, "data" => topic} <- Jason.decode!(body) do
      {:ok, topic}
    else
      _ -> {:error, nil}
    end
  end

  def create_topic_if_does_not_exist(socket, topic_name) do
    {:ok, topics} = list_topics(socket)
    topic = Enum.find(topics, fn t -> t["name"] === topic_name end)

    case topic do
      nil ->
        {:ok, new_topic} = create_topic(socket, topic_name)
        {:created, new_topic}

      existing_topic ->
        {:existing, topic}
    end
  end

  ## Subscribers

  def subscribe_user_to_topic(socket, topic_id) do
    headers = get_headers(socket)
    options = get_options()

    with {:ok, base_url} <- base_url(),
         subscribe_to_topic_url <- base_url <> @subscribe_to_topic_endpoint <> "/#{topic_id}",
         response <- HTTPoison.post(subscribe_to_topic_url, Jason.encode!(%{}), headers, options),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- response,
         %{"success" => true, "data" => subscription} <- Jason.decode!(body) do
      {:ok, subscription}
    else
      _ -> {:error, nil}
    end
  end

  def unsubscribe_user_from_topic(socket) do
    headers = get_headers(socket)
    options = get_options()

    if Map.has_key?(socket.assigns, :topic_id) do
      topic_id = socket.assigns.topic_id

      with {:ok, base_url} <- base_url(),
           subscribe_to_topic_url <- base_url <> @subscribe_to_topic_endpoint <> "/#{topic_id}",
           response <- HTTPoison.delete(subscribe_to_topic_url, headers, options),
           {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- response,
           %{"success" => true, "data" => data} <- Jason.decode!(body) do
        {:ok, data}
      else
        _ -> {:error, nil}
      end

      {:ok, :not_subscribed}
    end
  end

  @doc """
  Used by `Acai.Services.Manager2PC`  
  Returns {:ok, commit_function, rollback_function}
          {:error, error}
  """
  def init_2pc(socket, notification) do
    response = prepare_2pc_notification(socket, notification)

    case response do
      {:ok, request_id} ->
        commit_fn = fn -> commit_2pc_notification(socket, request_id) end
        rollback_fn = fn -> rollback_2pc_notification(socket, request_id) end
        {:ok, commit_fn, rollback_fn}

      error ->
        error
    end
  end

  ## Notifications

  def prepare_2pc_notification(socket, %Notification{message: message, to: to}) do
    topic_id = socket.assigns.topic_id
    headers = get_headers(socket)
    options = get_options()

    body =
      Jason.encode!(%{message: message, to_users: to, topic_id: topic_id, is_2pc_locked: true})

    with {:ok, base_url} <- base_url(),
         create_notification_url <- base_url <> @create_notification_endpoint,
         response <- HTTPoison.post(create_notification_url, body, headers, options),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- response,
         %{"success" => true, "data" => %{"request_id" => request_id}} <- Jason.decode!(body) do
      dbg(request_id)
      {:ok, request_id}
    else
      error_data -> {:error, error_data}
    end
  end

  def commit_2pc_notification(socket, request_id) do
    headers = get_headers(socket)
    options = get_options()
    body = Jason.encode!(%{request_id: request_id})

    with {:ok, base_url} <- base_url(),
         commit_2pc_notification_url <- base_url <> @commit_2pc_notification_endpoint,
         response <- HTTPoison.post(commit_2pc_notification_url, body, headers, options),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- response,
         %{"success" => true} <- Jason.decode!(body) do
      {:ok, nil}
    else
      error_data -> {:error, error_data}
    end
  end

  def rollback_2pc_notification(socket, request_id) do
    headers = get_headers(socket)
    options = get_options()

    with {:ok, base_url} <- base_url(),
         rollback_2pc_notification_url <-
           base_url <> @rollback_2pc_notification_endpoint <> "/#{request_id}",
         response <- HTTPoison.delete(rollback_2pc_notification_url, headers, options),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- response,
         %{"success" => true} <- Jason.decode!(body) do
      {:ok, nil}
    else
      error_data -> {:error, error_data}
    end
  end

  def get_own_notifications(socket) do
    topic_name = socket.assigns.topic_name
    headers = get_headers(socket)
    options = get_options() ++ [params: [topic_name: topic_name]]
    {:ok, users} = Auth.get_all_users(socket)

    with {:ok, base_url} <- base_url(),
         get_notifications_url <- base_url <> @get_notifications_endpoint,
         response <- HTTPoison.get(get_notifications_url, headers, options),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- response,
         %{"success" => true, "data" => data} <- Jason.decode!(body) do
      populated_with_user =
        Enum.map(data, fn n ->
          user = Enum.find(users, fn u -> u["id"] == n["from_user_id"] end)
          Map.put(n, "from", user["email"])
        end)

      {:ok, populated_with_user}
    else
      error_data -> {:error, error_data}
    end
  end

  ## Privates

  defp base_url(), do: ServicesAgent.get_service_address("persist")

  defp get_headers(socket),
    do: [
      "content-type": "application/json",
      "durian-token": socket.assigns.user.token
    ]

  defp get_options(), do: [recv_timeout: @recv_timeout]
end
