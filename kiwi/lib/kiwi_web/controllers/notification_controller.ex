defmodule KiwiWeb.NotificationController do
  use KiwiWeb, :controller

  alias Kiwi.Persist
  alias Kiwi.Persist.Notification

  action_fallback KiwiWeb.FallbackController

  def index(conn, _params) do
    notifications = Persist.list_notifications()
    render(conn, "index.json", notifications: notifications)
  end

  def create(conn, %{"notification" => notification_params}) do
    with {:ok, %Notification{} = notification} <- Persist.create_notification(notification_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.notification_path(conn, :show, notification))
      |> render("show.json", notification: notification)
    end
  end

  def show(conn, %{"id" => id}) do
    notification = Persist.get_notification!(id)
    render(conn, "show.json", notification: notification)
  end

  def update(conn, %{"id" => id, "notification" => notification_params}) do
    notification = Persist.get_notification!(id)

    with {:ok, %Notification{} = notification} <- Persist.update_notification(notification, notification_params) do
      render(conn, "show.json", notification: notification)
    end
  end

  def delete(conn, %{"id" => id}) do
    notification = Persist.get_notification!(id)

    with {:ok, %Notification{}} <- Persist.delete_notification(notification) do
      send_resp(conn, :no_content, "")
    end
  end
end
