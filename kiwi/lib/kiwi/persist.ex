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

  defp is_topic_creator(topic_id, user_id) do
    query_result =
      Topic
      |> where([t], t.created_by == ^user_id and t.id == ^topic_id)
      |> Repo.one()

    case query_result do
      nil -> {:error, :not_topic_creator}
      topic -> {:ok, topic}
    end
  end

  ## Notifications

  def create_notification(attrs \\ %{}) do
    %Notification{}
    |> Notification.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Works with transactions, it sequentially performs some preconditions (validations)
  and updates the `users_notifications` entity
  """
  def insert_users_notifications(users, notification_attrs) do
    notification_changeset = Notification.changeset(%Notification{}, notification_attrs)

    transaction_result =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:is_valid_notification, fn _repo, _changes ->
        case notification_changeset.valid? do
          true ->
            {:ok, nil}

          false ->
            {:error, :invalid_notification}
        end
      end)
      |> Ecto.Multi.run(:is_topic_creator, fn _repo, _changes ->
        is_topic_creator(notification_attrs["topic_id"], notification_attrs["from_user_id"])
      end)
      |> Ecto.Multi.insert(:notification, notification_changeset)
      |> Ecto.Multi.insert_all(:insert_all, UserNotification, fn %{notification: notification} ->
        Enum.map(users, fn user ->
          add_timestamps(%{
            notification_id: notification.id,
            to_user_id: user.user_id,
            status: :sent
          })
        end)
      end)
      |> Repo.transaction()

    # dbg(transaction_result)

    case transaction_result do
      {:ok, %{insert_all: {count, nil}, notification: notification}} ->
        {:ok, notification, count}

      {:error, _, _, _} ->
        {:error, "could not process transaction"}

      {:ok, _} ->
        {:ok, "successfully processed transaction"}
    end
  end

  defp add_timestamps(map) do
    case Map.fetch(map, :inserted_at) do
      {:ok, _} ->
        Map.merge(map, %{
          updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
        })

      :error ->
        Map.merge(map, %{
          inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
          updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
        })
    end
  end

  @doc """
  Very useful [dynamic filters](https://hexdocs.pm/ecto/dynamic-queries.html#content)
  """
  def get_user_notifications(user_id, filters) do
    dynamic_filters =
      Enum.reduce(filters, dynamic(true), fn current, dynamic_acc ->
        case current do
          {"topic_name", value} ->
            dynamic([topic: t], ^dynamic_acc and t.name == ^value)

          {"from_user_id", value} ->
            dynamic([notification: n], ^dynamic_acc and n.from_user_id == ^value)

          {"status", value} ->
            dynamic([un], ^dynamic_acc and un.status == ^value)

          {_, _} ->
            dynamic_acc
        end
      end)

    UserNotification
    |> where([un], un.to_user_id == ^user_id)
    |> join(:left, [un], n in Notification, on: un.notification_id == n.id, as: :notification)
    |> join(:left, [un, n], t in Topic, on: n.topic_id == t.id, as: :topic)
    |> where(^dynamic_filters)
    |> select([un, n, t], %{
      notification_id: n.id,
      message: n.message,
      topic_name: t.name,
      from_user_id: n.from_user_id,
      status: un.status,
      inserted_at: n.inserted_at
    })
    |> Repo.all()
  end
end
