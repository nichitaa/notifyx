defmodule GuavaWeb.MailController do
  require Logger
  use GuavaWeb, :controller
  alias GuavaWeb.{ControllerUtils}
  alias Guava.{Balancer, WorkerDynamicSupervisor, Worker}

  def send_mail(
        conn,
        %{"from" => _from, "to" => _to, "message" => _message, "subject" => _subject} = params
      ) do
    node = Balancer.next_node()
    log("received request, call rcp for node: #{inspect(node)}")
    :erpc.call(node, __MODULE__, :send_mail_rpc, [conn, params])
  end

  @doc """
  RPC route only, parent Node (balancer) will call it via `:erpc`
  Should always return `Plug.Conn` as a normal route
  """
  def send_mail_rpc(conn, params) do
    log("[rpc]: received request")

    with {:ok, worker_pid} <- WorkerDynamicSupervisor.start_child([]),
         {:ok, success_data} <- Worker.send_mail(worker_pid, params) do
      ControllerUtils.handle_json_view(conn, "send_mail_success.json", success_data)
    else
      {:error, :max_children} ->
        ControllerUtils.handle_json_view(conn, "too_many_requests.json", :too_many_requests)

      _ ->
        ControllerUtils.handle_json_view(conn, "send_mail_error.json")
    end
  end

  defp log(text),
    do: Logger.info("---[#{node()}-#{inspect(self())}] #{__MODULE__} #{inspect(text)}")
end
