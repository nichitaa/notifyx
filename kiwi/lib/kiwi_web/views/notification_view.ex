defmodule KiwiWeb.NotificationView do
  use KiwiWeb, :view

  def render("create_notification_success.json", %{notification: notification, count: count}) do
    data = render_one(notification, __MODULE__, "notification_dto.json")
    data = Map.put(data, :message, "updated #{inspect(count)} records")
    success_response(data)
  end

  def render("create_notification_error.json", _assigns) do
    error_response("unable to create notification")
  end

  def render("user_notifications.json", %{notifications: notifications}) do
    success_response(notifications)
  end

  def render("notification_dto.json", %{notification: notification}) do
    %{
      id: notification.id,
      message: notification.message,
      topic_id: notification.topic_id,
      from_user_id: notification.from_user_id
    }
  end

  ## Privates 

  defp success_response(payload), do: %{success: true, data: payload}
  defp error_response(errors), do: %{success: false, errors: errors}
end
