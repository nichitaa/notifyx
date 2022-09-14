defmodule DurianWeb.ChangesetView do
  use DurianWeb, :view

  def translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  def render("error.json", %{changeset: changeset}) do
    %{success: false, errors: translate_errors(changeset)}
  end
end
