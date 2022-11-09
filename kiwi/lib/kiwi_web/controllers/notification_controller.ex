defmodule KiwiWeb.NotificationController do
  use KiwiWeb, :controller

  alias Kiwi.Cache
  alias Kiwi.Persist
  alias Kiwi.Persist.Notification
  alias KiwiWeb.ControllerUtils

  action_fallback KiwiWeb.FallbackController

  def rollback_2pc(conn, %{"request_id" => request_id}) do
    from_user_id = conn.assigns[:user].id

    with {:ok, notification_id} <- Cache.get_2pc_notification(request_id),
         {:ok, :rollback} <- Persist.rollback_2pc(from_user_id, notification_id) do
      Cache.delete_2pc_notification(request_id)
      json(conn, %{success: true, message: "successfully rollback notification"})
    else
      {:not_in_cache} ->
        json(conn, %{
          success: false,
          error: "could not found notification_id to rollback for request_id: #{request_id}"
        })

      {:error, :not_found} ->
        json(conn, %{
          success: false,
          error: "could not find notification"
        })

      _ ->
        json(conn, %{success: false, error: "error at rollback notification"})
    end
  end

  def commit_2pc(conn, %{"request_id" => request_id}) do
    from_user_id = conn.assigns[:user].id

    with {:ok, notification_id} <- Cache.get_2pc_notification(request_id),
         {:ok, :commited} <- Persist.commit_2pc(from_user_id, notification_id) do
      Cache.delete_2pc_notification(request_id)
      json(conn, %{success: true, message: "successfully committed notification"})
    else
      {:not_in_cache} ->
        json(conn, %{
          success: false,
          error: "could not found notification_id to commit for request_id: #{request_id}"
        })

      {:error, :not_found} ->
        json(conn, %{
          success: false,
          error: "could not find notification"
        })

      _ ->
        json(conn, %{success: false, error: "error at committing notification"})
    end
  end

  @doc """
  Handle regular Notification creation or a prepare step from 2pc (if `is_2pc_locked: true`)
  """
  def create(
        conn,
        %{"topic_id" => topic_id, "message" => message, "to_users" => to_users} = params
      )
      when is_list(to_users) do
    user_id = conn.assigns[:user].id
    notification_params = Map.put(params, "from_user_id", user_id)
    is_2pc_prepare = Map.get(params, "is_2pc_locked", false)

    request_id =
      if is_2pc_prepare do
        Base.url_encode64(:crypto.strong_rand_bytes(32))
      else
        nil
      end

    case Persist.insert_users_notifications(notification_params, to_users) do
      {:ok, notification, count} ->
        if is_2pc_prepare do
          Cache.save_prepare_2pc_notification(request_id, notification.id)

          ControllerUtils.handle_json_view(conn, "2pc_prepare_success.json", %{
            request_id: request_id
          })
        else
          ControllerUtils.handle_json_view(conn, "create_notification_success.json", %{
            notification: notification,
            count: count
          })
        end

      {:error, error} ->
        ControllerUtils.handle_json_view(conn, "notification_error.json", %{error: error})
    end
  end

  def get_own_notifications(conn, params) do
    user_id = conn.assigns[:user].id
    notifications = Persist.get_user_notifications(user_id, conn.query_params)

    ControllerUtils.handle_json_view(conn, "user_notifications.json", %{
      notifications: notifications
    })
  end

  def update_status_to_seen(conn, %{"id" => notification_id}) do
    user_id = conn.assigns[:user].id

    case Persist.update_notification_status(user_id, notification_id) do
      {:ok, notification, count} ->
        ControllerUtils.handle_json_view(conn, "create_notification_success.json", %{
          notification: notification,
          count: count
        })

      {:error, error} ->
        ControllerUtils.handle_json_view(conn, "notification_error.json", %{error: error})
    end
  end
end
