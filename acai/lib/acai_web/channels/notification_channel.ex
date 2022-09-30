defmodule AcaiWeb.NotificationChannel do
  # This `Channel` exists only for a single topic join

  use Phoenix.Channel, hibernate_after: :infinity
  alias Acai.Services.Persist

  intercept ["new_notification"]

  def join("notification:" <> topic_name, _message, socket) do
    # On `join` we create topic if it does not exist already
    # and subscribe user to the current topic
    {topic_info_atom, topic} = Persist.create_topic_if_does_not_exist(socket, topic_name)

    user_id = socket.assigns.user.user_id

    reply = %{from_join: true, can_broadcast: user_id == topic["created_by"]}


    with {:ok, subscription} <- Persist.subscribe_user_to_topic(socket, topic["id"]) do
      socket = assign(socket, :topic_id, subscription["topic_id"])
      {:ok, reply, socket}
    else
      _ -> {:error, %{reason: "could not join/subscribe this topic"}}
    end
  end

  ##################################################################
  ########################## Incoming ##############################
  ##################################################################

  def handle_in("new_notification", %{"message" => message, "to" => to}, socket) do
    dbg("[IN] new_notification")
    from = socket.assigns.user.email
    notification = Notification.new(message, from, to)

    response =
      case Persist.create_notification(socket, notification) do
        {:error, error} -> error
        {:ok, data} -> data
      end

    broadcast!(socket, "new_notification", notification)
    # the client in UI could have a `loading` state
    # with `{:noreply, socket}` could not block the traffic
    {:reply, {:ok, response}, socket}
  end

  ##################################################################
  ########################## Outgoing ##############################
  ##################################################################

  # expecting a %Notification{} struct from `broadcast!`
  def handle_out("new_notification", %Notification{to: to} = notification, socket) do
    dbg("[OUT] new_notification #{inspect(notification)}")
    # broadcast new notifications to all subscribers if to === []
    # otherwise only to right receivers

    if to === [] do
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

    Persist.unsubscribe_user_from_topic(socket)
  end
end
