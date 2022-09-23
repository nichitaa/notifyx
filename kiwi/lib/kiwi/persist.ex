defmodule Kiwi.Persist do
  import Ecto.Query, warn: false
  alias Kiwi.Repo

  alias Kiwi.Persist.Topic
  alias Kiwi.Persist.Notification

  ## Topics

  def list_topics do
    Repo.all(Topic)
  end

  def get_topic!(id), do: Repo.get!(Topic, id)

  def get_topic(id), do: Repo.get(Topic, id)

  def create_topic(attrs \\ %{}) do
    %Topic{}
    |> Topic.changeset(attrs)
    |> Repo.insert()
  end

  def is_user_topic(topic, %{id: user_id}) do
    topic.created_by === user_id
  end

  def update_status(%Topic{} = topic, %{"status" => status}) do
    topic
    |> Topic.changeset(%{"status" => status})
    |> Repo.update()
  end

  def delete_topic(%Topic{} = topic) do
    Repo.delete(topic)
  end

  def change_topic(%Topic{} = topic, attrs \\ %{}) do
    Topic.changeset(topic, attrs)
  end

  def list_notifications do
    Repo.all(Notification)
  end

  def get_notification!(id), do: Repo.get!(Notification, id)

  def create_notification(attrs \\ %{}) do
    %Notification{}
    |> Notification.changeset(attrs)
    |> Repo.insert()
  end

  def update_notification(%Notification{} = notification, attrs) do
    notification
    |> Notification.changeset(attrs)
    |> Repo.update()
  end

  def delete_notification(%Notification{} = notification) do
    Repo.delete(notification)
  end

  def change_notification(%Notification{} = notification, attrs \\ %{}) do
    Notification.changeset(notification, attrs)
  end
end
