defmodule Acai.Services.Persist do
  alias Acai.ServicesAgent
  @recv_timeout 1000
  @list_token_endpoint "/api/topics"
  @create_topic_endpoint "/api/topics"

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

    if topic == nil do
      {:ok, new_topic} = create_topic(socket, topic_name)
      {:created, new_topic}
    end

    {:existing, topic}
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
