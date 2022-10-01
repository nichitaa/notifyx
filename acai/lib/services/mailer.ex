defmodule Acai.Services.Mailer do
  alias Acai.ServicesAgent

  @send_email_endpoint "/api/send_mail"

  def send_email(socket, message, to) do
    topic_name = socket.assigns.topic_name
    headers = get_headers(socket)
    options = get_options()
    from = socket.assigns.user.email
    body = Jason.encode!(%{from: from, to: to, message: message, subject: topic_name})

    with {:ok, base_url} <- base_url(),
         send_email_url <- base_url <> @send_email_endpoint,
         response <- HTTPoison.post(send_email_url, body, headers, options),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- response,
         %{"success" => true, "data" => data} <- Jason.decode!(body) do
      {:ok, data}
    else
      error_data -> {:error, error_data}
    end
  end

  ## Privates

  defp base_url(), do: ServicesAgent.get_service_address("mail")

  defp get_headers(socket),
    do: [
      "content-type": "application/json",
      "durian-token": socket.assigns.user.token
    ]

  defp get_options(), do: [recv_timeout: @recv_timeout]
end
