defmodule Guava.Plugs.ValidateNodeEnableRestApi do
  import Plug.Conn

  def init(_params) do
  end

  def call(conn, _params) do
    case enable_rest_api_for_current_node() do
      false ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> send_resp(
          :not_acceptable,
          Jason.encode!(%{error: "only grpc for node: #{inspect(node())}", success: false})
        )
        |> halt()

      true ->
        conn
    end
  end

  defp enable_rest_api_for_current_node(),
    do: Application.fetch_env!(:guava, :enable_rest_api) === 1
end
