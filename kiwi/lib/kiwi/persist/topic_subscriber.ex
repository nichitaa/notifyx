defmodule Kiwi.Persist.TopicSubscriber do
  use Ecto.Schema
  import Ecto.Changeset
  use Accessible

  alias Kiwi.Persist.Topic

  @primary_key false
  schema "topic_subscribers" do
    field :user_id, :binary_id

    belongs_to(:topic, Topic)

    timestamps()
  end

  @doc false
  def changeset(topic_subscriber, attrs) do
    topic_subscriber
    |> cast(attrs, [:topic_id, :user_id])
    |> validate_required([:topic_id, :user_id])
    |> unique_constraint([:topic_id, :user_id])
  end
end
