defmodule Kiwi.Cache do
  use Nebulex.Cache,
    otp_app: :kiwi,
    adapter: Nebulex.Adapters.Local

  alias Kiwi.Persist
  alias Kiwi.Persist.Topic

  # Topic (:id)

  def add_topic(topic) do
    put(topic[:id], topic, ttl: :timer.hours(1))
    add_topic_to_list(topic)
  end

  def get_topic(id) do
    case get(id) do
      nil -> not_in_cache_response()
      topic -> {:ok, topic}
    end
  end

  def update_topic(topic) do
    case get_topic(topic.id) do
      {:not_in_cache} ->
        add_topic(topic)

      {:ok, _old_topic} ->
        add_topic_to_list(topic)
        put(topic[:id], topic, ttl: :timer.hours(1))
    end
  end

  ## Topics (List)

  def add_topics_list(topics) do
    key = topics_list_cache_key()
    put(key, topics, ttl: :timer.minutes(2))
  end

  def get_topics_list() do
    key = topics_list_cache_key()

    case get(key) do
      nil -> not_in_cache_response()
      topics -> {:ok, topics}
    end
  end

  @doc """
  Adds or updates passed %Topic{} struct to cache (list and individual)
  """
  def add_topic_to_list(%Topic{} = topic) do
    topics =
      case get_topics_list() do
        {:not_in_cache} ->
          nil

        {:ok, topics} ->
          insert_or_update_topic_to_list(topics, topic)
      end

    add_topics_list(topics)
  end

  ## Utils

  def get_topic_from_cache_or_db(id), do: get_topic_from_cache_or_db_internal(id, false)

  def get_topic_from_cache_or_db!(id), do: get_topic_from_cache_or_db_internal(id, true)

  def get_topics_list_from_cache_or_db() do
    case get_topics_list() do
      {:not_in_cache} ->
        topics = Persist.list_topics()
        add_topics_list(topics)
        topics

      {:ok, cached} ->
        cached

      unhandled ->
        raise "Error: unhandled response #{inspect(unhandled)}"
    end
  end

  ## Privates

  # Adds or updates Topic struct in list (recursively)
  defp insert_or_update_topic_to_list([], %Topic{} = new_topic) do
    [new_topic]
  end

  defp insert_or_update_topic_to_list([_head = %Topic{id: id} | tail], %Topic{id: id} = new_topic) do
    [new_topic | tail]
  end

  defp insert_or_update_topic_to_list([head | tail], %Topic{} = new_topic) do
    [head | insert_or_update_topic_to_list(tail, new_topic)]
  end

  # Gets topic form cache or from db and saves to cache afterwards, `bang` - can raise an :not_found error
  defp get_topic_from_cache_or_db_internal(id, bang) when is_boolean(bang) do
    case get_topic(id) do
      {:not_in_cache} ->
        topic =
          if bang do
            Persist.get_topic!(id)
          else
            Persist.get_topic(id)
          end

        add_topic(topic)
        topic

      {:ok, cached} ->
        cached

      unhandled ->
        raise "Error: unhandled response #{inspect(unhandled)}"
    end
  end

  defp not_in_cache_response(), do: {:not_in_cache}

  defp topics_list_cache_key(), do: "topics_list"
end
