defmodule GuavaWeb.MailView do
  use GuavaWeb, :view

  def render("send_mail_success.json", %{id: id, labels: labels, thread_id: thread_id}) do
    success_response(%{id: id, labels: labels, thread_id: thread_id})
  end

  def render("send_mail_error.json", _assigns) do
    error_response("failed to send mail")
  end

  def render("too_many_requests.json", _assigns) do
    error_response("service is already processing maximum number of simultaneous requests")
  end

  ## Privates 

  defp success_response(payload), do: %{success: true, data: payload}
  defp error_response(errors), do: %{success: false, errors: errors}
end
