defmodule KiwiWeb.TopicController do
  use KiwiWeb, :controller

  alias Kiwi.Cache
  alias Kiwi.Persist
  alias Kiwi.Persist.Topic
  alias KiwiWeb.ControllerUtils

  action_fallback KiwiWeb.FallbackController

  def list(conn, params) do
    topics = Cache.get_topics_list_from_cache_or_db()
    ControllerUtils.handle_json_view(conn, "topics.json", %{topics: topics})
  end

  def create(conn, params) do
    user = conn.assigns[:user]
    topic_params = Map.put(params, "created_by", user.id)

    with {:ok, %Topic{} = topic} <- Persist.create_topic(topic_params) do
      Cache.add_topic(topic)
      ControllerUtils.handle_json_view(conn, "topic.json", %{topic: topic})
    end
  end

  def get_by_id(conn, %{"id" => id}) do
    topic = Cache.get_topic_from_cache_or_db!(id)
    ControllerUtils.handle_json_view(conn, "topic.json", %{topic: topic})
  end

  def update_status(conn, %{"id" => id, "status" => new_status}) do
    topic = Cache.get_topic_from_cache_or_db!(id)
    user = conn.assigns[:user]

    if Persist.is_user_topic(topic, user) do
      with {:ok, %Topic{} = topic} <- Persist.update_status(topic, %{"status" => new_status}) do
        ControllerUtils.handle_json_view(conn, "topic.json", %{topic: topic})
      end
    else
      ControllerUtils.handle_json_view(conn, "not_topic_owner.json", :forbidden)
    end
  end
end
