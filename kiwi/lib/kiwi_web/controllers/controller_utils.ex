defmodule KiwiWeb.ControllerUtils do
  use KiwiWeb, :controller

  def handle_json_view(conn, view) when is_binary(view) do
    conn
    |> put_resp_content_type("application/json")
    |> put_status(:ok)
    |> render(view, %{})
  end

  def handle_json_view(conn, view, assigns) when is_binary(view) and is_map(assigns) do
    conn
    |> put_resp_content_type("application/json")
    |> put_status(:ok)
    |> render(view, assigns)
  end

  def handle_json_view(conn, view, status) when is_binary(view) and is_atom(status) do
    conn
    |> put_resp_content_type("application/json")
    |> put_status(status)
    |> render(view, %{})
  end

  def handle_json_view(conn, view, assigns, status)
      when is_binary(view) and is_map(assigns) and is_atom(status) do
    conn
    |> put_resp_content_type("application/json")
    |> put_status(status)
    |> render(view, assigns)
  end
end
