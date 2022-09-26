defmodule KiwiWeb.TopicSubscriberView do
  use KiwiWeb, :view
  alias KiwiWeb.TopicSubscriberView

  def render("subscriber.json", %{subscriber: subscriber}) do
    data = render_one(subscriber, TopicSubscriberView, "subscriber_dto.json", as: :subscriber)
    success_response(data)
  end

  def render("subscribers.json", %{subscribers: subscribers}) do
    data = render_many(subscribers, TopicSubscriberView, "subscriber_dto.json")
    success_response(data)
  end

  ## DTO

  def render("subscriber_dto.json", %{subscriber: subscriber}) do
    %{
      topic_id: subscriber.topic_id,
      user_id: subscriber.user_id
    }
  end

  ## Privates 

  defp success_response(payload), do: %{success: true, data: payload}
  defp error_response(errors), do: %{success: false, errors: errors}
end
