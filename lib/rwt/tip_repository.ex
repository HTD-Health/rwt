defmodule Rwt.TipRepository do
  use GenServer

  require Logger

  alias Rwt.Persistence

  #  %{
  #    id: 1,
  #    content: "Lorem Ipsum"
  #  }

  @state %{
    tips: []
  }

  # Client

  def start_link(default) do
    GenServer.start_link(__MODULE__, @state, name: Rwt.TipRepositoryServer)
  end

  def insert(tips) do
    GenServer.cast(Rwt.TipRepositoryServer, {:insert_tips, tips})
  end

  def find() do
    GenServer.call(Rwt.TipRepositoryServer, :find_tips)
  end

  def find_one(id) do
    GenServer.call(Rwt.TipRepositoryServer, {:find_tip, id})
  end

  # Callbacks

  @impl true
  def init(state) do
    persistor()
    {:ok, Rwt.Persistence.read(:tip_repository) || state}
  end

  @impl true
  def handle_call(:find_tips, _from, state) do
    {:reply, state.tips, state}
  end

  @impl true
  def handle_call({:find_tip, id}, _from, state) do
    {:reply, Enum.find(state.tips, &(&1.id === id)), state}
  end

  @impl true
  def handle_cast({:insert_tips, tips}, state) do
    tips =
      tips
      |> Jason.decode!()
      |> Enum.map(
        &%{
          id: &1["id"],
          content: &1["content"]
        }
      )

    {:noreply, %{state | tips: tips}}
  end

  @impl true
  def handle_info(:persist, state) do
    Rwt.Persistence.save(:tip_repository, state)
    persistor()
    {:noreply, state}
  end

  @impl true
  def terminate(_reason, state) do
    Rwt.Persistence.save(:tip_repository, state)
  end

  # Private

  defp persistor() do
    Process.send_after(self(), :persist, 60 * 1000)
  end
end
