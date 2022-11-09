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

  def update_topic_status(%Topic{} = topic, %{"status" => status}) do
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

  @doc """
  If passing `to_users` list then will fetch topic subscribers (by `topic_id`)
  within `to_users` list only, otherwise will get all topic subscribers
  """
  def list_topic_subscribers(topic_id, to_users) when is_list(to_users) do
    dynamic_filter =
      case to_users do
        [] -> dynamic([sub], sub.topic_id == ^topic_id)
        ids -> dynamic([sub], sub.topic_id == ^topic_id and sub.user_id in ^to_users)
      end

    TopicSubscriber
    |> where(topic_id: ^topic_id)
    |> where(^dynamic_filter)
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

  def commit_2pc(from_user_id, notification_id) do
    update_result =
      get_2pc_query(from_user_id, notification_id)
      |> update(set: [is_2pc_locked: false])
      |> Repo.update_all([])

    case update_result do
      {1, nil} -> {:ok, :commited}
      _ -> {:error, :commit_error}
    end
  end

  def rollback_2pc(from_user_id, notification_id) do
    can_delete_query =
      get_2pc_query(from_user_id, notification_id)
      |> Repo.one([])

    case can_delete_query do
      nil ->
        {:error, :rollback_error}

      _ ->
        # delete relations entity first
        from(un in UserNotification,
          where: un.notification_id == ^notification_id
        )
        |> Repo.delete_all([])

        delete_notification_result =
          get_2pc_query(from_user_id, notification_id)
          |> Repo.delete_all([])

        case delete_notification_result do
          {1, nil} -> {:ok, :rollback}
          _ -> {:error, :rollback_error}
        end
    end
  end

  def get_2pc_query(from_user_id, notification_id) do
    from(n in Notification,
      where:
        n.id == ^notification_id and n.is_2pc_locked == true and n.from_user_id == ^from_user_id
    )
  end

  @doc """
  Works with transactions, it sequentially performs some preconditions (validations)
  and updates the `users_notifications` entity
  """
  def insert_users_notifications(notification_attrs, to_users) do
    notification_changeset = Notification.changeset(%Notification{}, notification_attrs)

    transaction_result =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:notification_changeset, fn _repo, _changes ->
        if notification_changeset.valid?,
          do: {:ok, nil},
          else: {:error, :invalid_notification}
      end)
      |> Ecto.Multi.run(:is_topic_creator, fn _repo, _changes ->
        topic_id = notification_attrs["topic_id"]
        from_user_id = notification_attrs["from_user_id"]
        is_topic_creator(topic_id, from_user_id)
      end)
      |> Ecto.Multi.run(:users, fn _repo, changes ->
        subscribers = list_topic_subscribers(notification_attrs["topic_id"], to_users)

        case subscribers do
          [] -> {:error, :no_subscribers}
          list -> {:ok, list}
        end
      end)
      |> Ecto.Multi.insert(:notification, notification_changeset)
      |> Ecto.Multi.insert_all(
        :insert_all,
        UserNotification,
        fn %{notification: notification, users: users} = changes ->
          Enum.map(users, fn user ->
            add_timestamps(%{
              notification_id: notification.id,
              to_user_id: user.user_id,
              status: :sent
            })
          end)
        end
      )
      |> Repo.transaction()

    case transaction_result do
      {:ok, %{insert_all: {count, nil}, notification: notification}} ->
        {:ok, notification, count}

      {:error, operation, value, _} ->
        {:error,
         "error at operation: `#{Atom.to_string(operation)}`, value: `#{Atom.to_string(value)}`"}

      {:ok, _} ->
        {:ok, "successfully processed transaction (unhandled case though)"}
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
  Gets users notifications filtered by `topic_name`, `from_user_id` and `status`
  """
  def get_user_notifications(user_id, filters) do
    # dynamic queries - https://hexdocs.pm/ecto/dynamic-queries.html#content)
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
    # only Notifications that were committed after 2pc (no currently locked)
    |> join(:right, [un], n in Notification,
      on: un.notification_id == n.id and n.is_2pc_locked == false,
      as: :notification
    )
    |> join(:right, [un, n], t in Topic, on: n.topic_id == t.id, as: :topic)
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

  def update_notification_status(user_id, notification_id) do
    transaction_result =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:notification, fn repo, changes ->
        query_result =
          UserNotification
          |> where(
            [un],
            un.to_user_id == ^user_id and
              un.notification_id == ^notification_id and
              un.status == :sent
          )
          |> Repo.one()

        case query_result do
          nil -> {:error, :not_found}
          notification -> {:ok, notification}
        end
      end)
      |> Ecto.Multi.update_all(
        :update_all,
        fn %{notification: notification} ->
          from(un in UserNotification,
            where: un.notification_id == ^notification_id and un.to_user_id == ^user_id,
            update: [set: [status: :seen]]
          )
        end,
        []
      )
      |> Repo.transaction()

    case transaction_result do
      {:ok, %{update_all: {count, nil}, notification: notification}} ->
        {:ok, notification, count}

      {:error, operation, value, _} ->
        {:error,
         "error at operation: `#{Atom.to_string(operation)}`, value: `#{Atom.to_string(value)}`"}

      {:ok, _} ->
        {:ok, "successfully processed transaction (unhandled case though)"}
    end
  end
end
