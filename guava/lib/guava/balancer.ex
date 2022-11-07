defmodule Guava.Balancer do
  use GenServer

  def start_link(_opts), do: GenServer.start_link(__MODULE__, 0, name: __MODULE__)

  ## Client API

  def next_node(), do: GenServer.call(__MODULE__, :next_node)

  ## Callbacks

  @impl true
  def init(counter), do: {:ok, counter}

  @impl true
  def handle_call(:next_node, _from, counter) do
    available_nodes = Node.list()
    dbg("[BALANCER] available_nodes: #{inspect(available_nodes)}")

    case available_nodes do
      [] ->
        {:reply, Node.self(), counter + 1}

      nodes ->
        next_node = Enum.at(nodes, rem(counter, length(nodes)))
        {:reply, next_node, counter + 1}
    end
  end
end
