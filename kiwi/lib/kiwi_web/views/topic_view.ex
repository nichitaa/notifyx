defmodule KiwiWeb.TopicView do
  use KiwiWeb, :view
  alias KiwiWeb.TopicView

  def render("topics.json", %{topics: topics}) do
    data = render_many(topics, TopicView, "topic_dto.json")
    success_response(data)
  end

  def render("topic.json", %{topic: topic}) do
    data = render_one(topic, TopicView, "topic_dto.json")
    success_response(data)
  end

  def render("not_topic_owner.json", _assigns) do
    error = %{message: "only topic owners can modify it"}
    error_response(error)
  end

  def render("topic_dto.json", %{topic: topic}) do
    %{
      id: topic.id,
      name: topic.name,
      created_by: topic.created_by,
      longevity: topic.longevity,
      status: topic.status
    }
  end

  ## Privates 

  defp success_response(payload), do: %{success: true, data: payload}
  defp error_response(errors), do: %{success: false, errors: errors}
end
