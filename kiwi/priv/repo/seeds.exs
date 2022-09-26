# mix run priv/repo/seeds.exs

# Mostly for relationships tests & changeset validations
# not really used as a seed

defmodule Seeds do
  alias Kiwi.Persist.Topic
  alias Kiwi.Persist.Notification
  alias Kiwi.Persist.TopicSubscriber
  alias Kiwi.Persist.UserNotification
  alias Kiwi.Repo

  def run() do
    dbg("run")
    user_id1 = "1111b487-9b6f-457a-be11-37eeb66feccb"
    user_id2 = "2222b487-9b6f-457a-be11-37eeb66feccb"

    {:ok, topic} =
      Topic.changeset(%Topic{}, %{
        name: "topic name",
        status: "active",
        longevity: 10,
        created_by: user_id2
      })
      |> Repo.insert()

    dbg(topic)

    {:ok, sub} =
      TopicSubscriber.changeset(%TopicSubscriber{}, %{
        topic_id: topic.id,
        user_id: user_id2
      })
      |> Repo.insert()

    dbg(sub)

    #    {:ok, notification} =
    #      Notification.changeset(%Notification{}, %{
    #        from_user_id: user_id1,
    #        message: "message text",
    #        topic_id: topic.id
    #      })
    #      |> Repo.insert()
    #
    #    dbg(notification)
    #
    #    user_notification =
    #      UserNotification.changeset(%UserNotification{}, %{
    #        to_user_id: user_id2,
    #        notification_id: notification.id,
    #        status: "sent"
    #      })
    #      |> Repo.insert()
    #
    #    dbg(user_notification)
  end
end

 Seeds.run()
