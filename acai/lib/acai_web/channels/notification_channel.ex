defmodule AcaiWeb.NotificationChannel do
  use Phoenix.Channel, hibernate_after: :infinity

  intercept ["new_notification"]

  def join("notification:all", _message, socket) do
    {:ok, socket}
  end

  def join("notification:private" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  ## Incoming

  def handle_in("new_notification", %{"message" => message, "to" => to}, socket) do
    from = socket.assigns.user.email
    notification = Notification.new(message, from, to)
    broadcast!(socket, "new_notification", notification)
    # {:noreply, socket}
    # the client in UI could have a `loading` state
    {:reply, {:ok, %{success: true}}, socket}
  end

  ## Outgoing

  # expecting a %Notification{} struct from `broadcast!`
  def handle_out("new_notification", %Notification{to: to} = notification, socket) do
    # broadcast new notifications to all subscribers if to === nil
    # otherwise only to right receivers

    me = socket.assigns.user.email

    if to === nil || me === to do
      push(socket, "new_notification", notification)
    end

    {:noreply, socket}
  end
end
