defmodule AcaiWeb.NotificationSocket do
  use Phoenix.Socket

  channel "notification:*", AcaiWeb.NotificationChannel

  @impl true
  def connect(%{"email" => email, "password" => password}, socket, _connect_info) do
    with user when not is_nil(user) <- Acai.Services.Auth.login_and_get_user(email, password) do
      socket = assign(socket, :user, user)
      {:ok, socket}
    else
      _ -> :error
    end
  end

  @impl true
  def id(_socket), do: nil
end
