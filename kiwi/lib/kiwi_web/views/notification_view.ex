defmodule KiwiWeb.NotificationView do
  use KiwiWeb, :view
  alias KiwiWeb.NotificationView

  def render("index.json", %{notifications: notifications}) do
    %{data: render_many(notifications, NotificationView, "notification.json")}
  end

  def render("show.json", %{notification: notification}) do
    %{data: render_one(notification, NotificationView, "notification.json")}
  end

  def render("notification.json", %{notification: notification}) do
    %{
      id: notification.id,
      message: notification.message,
      from: notification.from,
      seen_by: notification.seen_by,
      to: notification.to
    }
  end
end
