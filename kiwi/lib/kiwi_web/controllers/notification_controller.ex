defmodule KiwiWeb.NotificationController do
  use KiwiWeb, :controller

  alias Kiwi.Cache
  alias Kiwi.Persist
  alias Kiwi.Persist.Notification
  alias KiwiWeb.ControllerUtils

  action_fallback KiwiWeb.FallbackController

  def create(
        conn,
        %{"topic_id" => topic_id, "message" => message, "to_users" => to_users} = params
      )
      when is_list(to_users) do
    user_id = conn.assigns[:user].id

    subscribers = Persist.list_topic_subscribers(topic_id)
    notification_params = Map.put(params, "from_user_id", user_id)

    case Persist.insert_users_notifications(subscribers, notification_params) do
      {:ok, notification, count} ->
        ControllerUtils.handle_json_view(conn, "create_notification_success.json", %{
          notification: notification,
          count: count
        })

      {:error, message} ->
        ControllerUtils.handle_json_view(conn, "create_notification_error.json")
    end
  end

  def get_own_notifications(conn, params) do
    user_id = conn.assigns[:user].id
    notifications = Persist.get_user_notifications(user_id, conn.query_params)

    ControllerUtils.handle_json_view(conn, "user_notifications.json", %{
      notifications: notifications
    })
  end
end
