defmodule AcaiWeb.NotificationChannel do
  # This `Channel` exists only for a single topic join

  use Phoenix.Channel, hibernate_after: :infinity
  alias Acai.Services

  intercept ["new_notification"]

  def join("notification:" <> topic_name, _message, socket) do
    # On `join` we create topic if it does not exist already
    # and subscribe user to the current topic
    {topic_info_atom, topic} = Services.Persist.create_topic_if_does_not_exist(socket, topic_name)

    user_id = socket.assigns.user.user_id

    reply = %{from_join: true, can_broadcast: user_id == topic["created_by"]}
    socket = assign(socket, :topic_name, topic_name)

    with {:ok, subscription} <- Services.Persist.subscribe_user_to_topic(socket, topic["id"]) do
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
      case Services.Persist.create_notification(socket, notification) do
        {:error, error} -> error
        {:ok, data} -> data
      end

    broadcast!(socket, "new_notification", notification)
    # the client in UI could have a `loading` state
    # with `{:noreply, socket}` could not block the traffic
    {:reply, {:ok, response}, socket}
  end

  def handle_in("own_notifications_for_topic", _payload, socket) do
    dbg("[IN] own_notifications_for_topic")
    {:ok, notifications} = Services.Persist.get_own_notifications(socket)
    push(socket, "own_notifications_for_topic", %{success: true, notifications: notifications})
    {:noreply, socket}
  end

  def handle_in("send_email", %{"message" => message, "to" => to}, socket) do
    mailer_response = Services.Mailer.send_email(socket, message, to)

    reply =
      case mailer_response do
        {:ok, data} -> %{success: true, data: data, from_send_email: true}
        {:error, err_data} -> %{success: false, error: err_data, from_send_email: true}
      end

    {:reply, {:ok, reply}, socket}
  end

  def handle_in(
        "generate_avatar",
        %{"size" => _size, "name" => _name, "type" => _type} = params,
        socket
      ) do
    dbg("[IN] generate_avatar")
    avatar_response = Services.Generator.generate_avatar(socket, params)

    reply =
      case avatar_response do
        {:ok, body} -> {:binary, body} # :binary -> in client as `ArrayBuffer`
        {:error, err_data} -> %{success: false, error: err_data}
      end

    push(socket, "generate_avatar", reply)
    {:noreply, socket}
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

    Services.Persist.unsubscribe_user_from_topic(socket)
  end
end
