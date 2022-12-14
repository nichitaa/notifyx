defmodule Guava.WorkerDynamicSupervisor do
  use DynamicSupervisor

  def start_link(args), do: DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)

  @impl true
  def init(_init_args),
    do: DynamicSupervisor.init(strategy: :one_for_one, max_children: max_children())

  def terminate_child(pid), do: DynamicSupervisor.terminate_child(__MODULE__, pid)

  def start_child(opts) do
    child_spec = %{
      id: Guava.Worker,
      restart: :temporary,
      start: {Guava.Worker, :start_link, [opts]},
      type: :worker
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  ## Privates

  defp max_children(), do: Application.fetch_env!(:guava, :concurent_task_limit)
end
