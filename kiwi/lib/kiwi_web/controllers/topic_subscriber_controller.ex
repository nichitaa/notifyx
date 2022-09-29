defmodule KiwiWeb.TopicSubscriberController do
  use KiwiWeb, :controller

  alias KiwiWeb.ControllerUtils
  alias Kiwi.Persist
  alias Kiwi.Persist.TopicSubscriber
  action_fallback KiwiWeb.FallbackController

  def subscribe(conn, %{"topic_id" => topic_id}) do
    user = conn.assigns[:user]
    params = %{topic_id: topic_id, user_id: user.id}

    with {:ok, %TopicSubscriber{} = subscriber} <- Persist.subscribe(params) do
      ControllerUtils.handle_json_view(conn, "subscriber.json", %{subscriber: subscriber})
    end
  end

  def list_subscribers(conn, %{"topic_id" => topic_id}) do
    subscribers = Persist.list_topic_subscribers(topic_id, [])
    ControllerUtils.handle_json_view(conn, "subscribers.json", %{subscribers: subscribers})
  end

  def unsubscribe(conn, %{"topic_id" => topic_id}) do
    user_id = conn.assigns[:user].id

    case Persist.delete_topic_subscriber(user_id, topic_id) do
      {0, nil} ->
        {:error, :not_found}

      {1, nil} ->
        json(conn, %{ok: true})

      _ ->
        json(conn, %{error: "something happened"})
    end
  end
end
