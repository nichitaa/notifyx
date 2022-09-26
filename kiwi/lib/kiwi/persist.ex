defmodule Kiwi.Persist do
  import Ecto.Query, warn: false
  alias Kiwi.Repo

  alias Kiwi.Persist.Topic
  alias Kiwi.Persist.Notification
  alias Kiwi.Persist.TopicSubscriber
  alias Kiwi.Persist.UserNotification

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

  ## Topic subscribers

  def subscribe(attrs \\ %{}) do
    %TopicSubscriber{}
    |> TopicSubscriber.changeset(attrs)
    |> Repo.insert()
  end

  def list_topic_subscribers(topic_id) do
    TopicSubscriber
    |> Ecto.Query.where(topic_id: ^topic_id)
    |> Repo.all()
  end

  def delete_topic_subscriber(user_id, topic_id) do
    TopicSubscriber
    |> where([sub], sub.user_id == ^user_id and sub.topic_id == ^topic_id)
    |> Repo.delete_all()
  end

  ## Notifications

  def create_notification(attrs \\ %{}) do
    %Notification{}
    |> Notification.changeset(attrs)
    |> Repo.insert()
  end

  def create_users_notification(attrs \\ %{}) do
    %UserNotification{}
    |> UserNotification.changeset(attrs)
    |> Repo.insert()
  end
end
