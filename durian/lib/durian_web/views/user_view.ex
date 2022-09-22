defmodule DurianWeb.UserView do
  use DurianWeb, :view
  alias DurianWeb.UserView

  def render("list.json", %{users: users}) do
    %{
      success: true,
      data: render_many(users, DurianWeb.UserView, "user-data.json")
    }
  end

  def render("get_user.json", %{user: user}) do
    %{
      success: true,
      data: render_one(user, DurianWeb.UserView, "user-data.json")
    }
  end

  def render("user-data.json", %{user: user}) do
    %{
      id: user.id,
      email: user.email
    }
  end

  def render("register.json", %{id: id}) do
    %{
      success: true,
      id: id
    }
  end

  def render("login.json", %{user: %{id: id, token: token}}) do
    %{
      success: true,
      id: id,
      token: token
    }
  end

  def render("logout.json", %{user: %{id: id}}) do
    %{
      success: true,
      id: id,
      message: "successfully logout"
    }
  end
end
