defmodule Counter2PCWeb.CounterController do
  use Counter2PCWeb, :controller

  import Ecto.Query, warn: false

  alias Counter2PC.Counter
  alias Counter2PC.Repo

  action_fallback Counter2PCWeb.FallbackController

  def prepare_increment_2pc(conn, %{"user_id" => user_id}) do
    previous_record =
      from(c in Counter, where: c.user_id == ^user_id)
      |> Repo.one([])

    case previous_record do
      nil ->
        # first count record for passed `user_id`
        first_record_inserted =
          %Counter{}
          |> Counter.changeset(%{
            user_id: user_id,
            count_2pc_next: 1,
            is_2pc_locked: true
          })
          |> Repo.insert()

        case first_record_inserted do
          {:ok, r} -> json(conn, %{success: true, message: "first count prepared"})
          _ -> json(conn, %{success: false, message: "error at preparing first count"})
        end

      record ->
        # already existing count record for this `user_id`
        if record.is_2pc_locked do
          json(conn, %{success: false, error: "the record is locked for prepare requests"})
        else
          inc_count = record.count + 1

          update_result =
            from(c in Counter,
              where: c.user_id == ^user_id and c.is_2pc_locked == false,
              update: [set: [count_2pc_next: ^inc_count, is_2pc_locked: true]]
            )
            |> Repo.update_all([])

          case update_result do
            {1, nil} ->
              json(conn, %{
                success: true,
                message: "successfully prepared count, could be committed"
              })

            _ ->
              json(conn, %{success: false, error: "error at preparing count"})
          end
        end
    end
  end

  def commit_2pc(conn, %{"user_id" => user_id}) do
    query_result =
      from(c in Counter, where: c.user_id == ^user_id and c.is_2pc_locked == true)
      |> Repo.one([])

    case query_result do
      nil ->
        json(conn, %{success: false, error: "could not found record to commit"})

      record ->
        update_result =
          from(c in Counter,
            where: c.user_id == ^user_id and c.is_2pc_locked == true,
            update: [
              set: [count: ^record.count_2pc_next, count_2pc_next: nil, is_2pc_locked: false]
            ]
          )
          |> Repo.update_all([])

        case update_result do
          {1, nil} ->
            json(conn, %{
              success: true,
              message: "successfully committed count increment"
            })

          _ ->
            json(conn, %{success: false, error: "error at committing transaction"})
        end
    end
  end

  def rollback_2pc(conn, %{"user_id" => user_id}) do
    query_result =
      from(c in Counter, where: c.user_id == ^user_id and c.is_2pc_locked == true)
      |> Repo.one([])

    case query_result do
      nil ->
        json(conn, %{success: false, error: "could not found record to rollback"})

      record ->
        update_result =
          from(c in Counter,
            where: c.user_id == ^user_id and c.is_2pc_locked == true,
            update: [
              set: [count_2pc_next: nil, is_2pc_locked: false]
            ]
          )
          |> Repo.update_all([])

        case update_result do
          {1, nil} ->
            json(conn, %{
              success: true,
              message: "successfully rollback count increment"
            })

          _ ->
            json(conn, %{success: false, error: "error at rollback transaction"})
        end
    end

    json(conn, %{success: true})
  end

  def get_counter(conn, %{"user_id" => user_id}) do
    query_result =
      from(c in Counter, where: c.user_id == ^user_id)
      |> Repo.one([])

    case query_result do
      nil ->
        json(conn, %{success: false, error: "user_id not found"})

      record ->
        json(conn, %{
          success: true,
          data: %{
            user_id: record.user_id,
            counter: record.count,
            count_2pc_next: record.count_2pc_next,
            is_2pc_locked: record.is_2pc_locked
          }
        })
    end

    json(conn, %{success: true, data: nil})
  end
end
