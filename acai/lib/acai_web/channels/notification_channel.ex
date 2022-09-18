defmodule AcaiWeb.NotificationChannel do
  use Phoenix.Channel, hibernate_after: :infinity

  def join("notification:all", _message, socket) do
    {:ok, socket}
  end

  def join("notification:private" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  ## Incoming

  def handle_in("new_notification", %{"body" => body}, socket) do
    broadcast!(socket, "new_notification", %{body: body})
    {:noreply, socket}
  end
end
