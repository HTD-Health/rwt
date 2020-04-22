defmodule Rwt.RecipientRepository do
  use GenServer

  require Logger

  alias Rwt.Persistence

  #  %{
  #    id: "SUA1ZU",
  #    email: "john.doe@htdevelopers.com"
  #  }

  @state %{
    recipients: []
  }

  # Client

  def start_link(default) do
    GenServer.start_link(__MODULE__, @state, name: Rwt.RecipientRepositoryServer)
  end

  def insert(recipients) do
    GenServer.cast(Rwt.RecipientRepositoryServer, {:insert_recipients, recipients})
  end

  def find() do
    GenServer.call(Rwt.RecipientRepositoryServer, :find_recipients)
  end

  # Callbacks

  @impl true
  def init(state) do
    persistor()
    {:ok, Rwt.Persistence.read(:recipent_repository) || state}
  end

  @impl true
  def handle_call(:find_recipients, _from, state) do
    {:reply, state.recipients, state}
  end

  @impl true
  def handle_cast({:insert_recipients, recipients}, state) do
    recipients =
      recipients
      |> Jason.decode!()
      |> Enum.map(
        &%{
          id: &1["id"],
          email: &1["email"]
        }
      )

    new_state = %{state | recipients: recipients}

    {:noreply, new_state}
  end

  @impl true
  def handle_info(:persist, state) do
    Rwt.Persistence.save(:recipent_repository, state)
    persistor()
    {:noreply, state}
  end

  @impl true
  def terminate(_reason, state) do
    Rwt.Persistence.save(:recipent_repository, state)
  end

  # Private

  defp persistor() do
    Process.send_after(self(), :persist, 6 * 1000)
  end
end
