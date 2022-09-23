defmodule Kiwi.Cache do
  use Nebulex.Cache,
    otp_app: :kiwi,
    adapter: Nebulex.Adapters.Local

  alias Kiwi.Persist

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

  # TODO:
  def update_topic(topic) do
    case get_topic(topic.id) do
      {:not_in_cache} ->
        not_in_cache_response()

      topic ->
        add_topic_to_list(topic)

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

  # appends the new topic to list cache only if it already exists
  def add_topic_to_list(topic) do
    key = topics_list_cache_key()

    update(key, nil, fn prev ->
      prev ++ [topic]
    end)
  end

  ## Utils

  def get_topic_from_cache_or_db(id), do: get_topic_from_cache_or_db_internal(id, false)

  def get_topic_from_cache_or_db!(id), do: get_topic_from_cache_or_db_internal(id, true)

  @docs """
  gets topic form cache or from db and saves to cache afterwards, `bang` - can raise an :not_found error
  """
  defp get_topic_from_cache_or_db_internal(id, bang) when is_boolean(bang) do
    topic =
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

  defp not_in_cache_response(), do: {:not_in_cache}

  defp topics_list_cache_key(), do: "topics_list"
end
