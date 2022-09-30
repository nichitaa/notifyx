defmodule AcaiWeb.NotificationChannel do
  use Phoenix.Channel, hibernate_after: :infinity
  alias Acai.Services.Persist

  intercept ["new_notification"]

  def join("notification:" <> topic_name, _message, socket) do
    Persist.create_topic_if_does_not_exist(socket, topic_name)
    {:ok, socket}
  end

  ## Incoming

  def handle_in("new_notification", %{"message" => message, "to" => to}, socket) do
    from = socket.assigns.user.email
    notification = Notification.new(message, from, to)
    dbg("[IN] new_notification")

    broadcast!(socket, "new_notification", notification)
    # {:noreply, socket}
    # the client in UI could have a `loading` state
    {:reply, {:ok, %{success: true}}, socket}
  end

  ## Outgoing

  # expecting a %Notification{} struct from `broadcast!`
  def handle_out("new_notification", %Notification{to: to} = notification, socket) do
    dbg("[OUT] new_notification")
    # broadcast new notifications to all subscribers if to === nil
    # otherwise only to right receivers

    me = socket.assigns.user.email

    if to === nil || me === to do
      push(socket, "new_notification", notification)
    end

    {:noreply, socket}
  end

  @impl true
  def terminate(reason, socket) do
    case reason do
      {:shutdown, :closed} -> dbg("[TERMINATE] closed by client")
      other -> dbg("[TERMINATE] other #{inspect(other)}")
    end

    :ok
  end
end
