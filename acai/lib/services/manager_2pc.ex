defmodule Acai.Services.Manager2Pc do
  alias Acai.ServicesAgent
  alias Acai.Services

  @recv_timeout 1000

  def create_notification_2pc(socket, notification) do
    # 1 Phase - prepare
    prepare_tasks = [
      Task.async(fn ->
        Services.Persist.init_2pc(socket, notification)
      end),
      Task.async(fn ->
        Services.Counter.init_2pc(socket)
      end)
    ]

    prepare_responses = Task.await_many(prepare_tasks)
    # 2 Phase - commit/rollback
    second_phase(prepare_responses)
  end

  ## Privates

  @doc """
  Generic 2 phase execution for 2 phase commit.
  Based on first phase response ({:ok, commit_fn, rollback_fn}/{:error, error}) will
  invoke the right action and return
    {:commit, is_success_commit}
    {:rollback, is_success_rollback}
  """
  defp second_phase(prepare_responses) do
    can_commit = all_tasks_success_init_response(prepare_responses)
    dbg(prepare_responses)
    dbg("can_commit: #{inspect(can_commit)}")

    if can_commit do
      commit_tasks =
        Enum.reduce(prepare_responses, [], fn response, tasks_acc ->
          {:ok, commit_fn, _rollback_fn} = response
          task = Task.async(commit_fn)
          [task | tasks_acc]
        end)

      commit_responses = Task.await_many(commit_tasks)
      success = all_tasks_success_second_phase(commit_responses)

      dbg("commit_responses: #{inspect(commit_responses)}, success: #{inspect(success)}")
      {:commit, success}
    else
      rollback_tasks =
        Enum.reduce(prepare_responses, [], fn response, tasks_acc ->
          case response do
            {:ok, _commit_fn, rollback_fn} ->
              task = Task.async(rollback_fn)
              [task | tasks_acc]

            _ ->
              tasks_acc
          end
        end)

      rollback_responses = Task.await_many(rollback_tasks)
      success = all_tasks_success_second_phase(rollback_responses)

      dbg("rollback_responses: #{inspect(rollback_responses)}, success: #{inspect(success)}")
      {:rollback, success}
    end
  end

  defp all_tasks_success_init_response(list) do
    Enum.all?(list, fn x ->
      case x do
        {:ok, _commit_fn, _rollback_fn} -> true
        _ -> false
      end
    end)
  end

  defp all_tasks_success_second_phase(list) do
    Enum.all?(list, fn x ->
      case x do
        {:ok, _data} -> true
        _ -> false
      end
    end)
  end

  defp get_headers(socket),
    do: [
      "content-type": "application/json",
      "durian-token": socket.assigns.user.token
    ]

  defp get_options(), do: [recv_timeout: @recv_timeout]
end
