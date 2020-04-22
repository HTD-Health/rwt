defmodule Rwt.Server do
  use GenServer

  require Logger

  alias Rwt.RecipientRepository

  #  %{
  #    uuid: UUID.v4()
  #    recipient_id: 1,
  #    tip_id: 1,
  #    send_time: ~U[2019-01-01 10:30:00Z]
  #  }

  @state %{
    weekdays: Enum.to_list(1..5),
    hours: %{
      start: 8,
      end: 13
    },
    sent_tips: [],
    scheduled_tips: []
  }

  # Client

  def start_link(default) do
    GenServer.start_link(__MODULE__, @state, name: Rwt.Server)
  end

  def schedule_tips() do
    GenServer.cast(Rwt.Server, :schedule_tips)
  end

  def get_scheduled_tips() do
    GenServer.call(Rwt.Server, :get_scheduled_tips)
  end

  def get_sent_tips() do
    GenServer.call(Rwt.Server, :get_sent_tips)
  end

  def send_tips() do
    GenServer.cast(Rwt.Server, :send_tips)
  end

  # Callbacks

  @impl true
  def init(state) do
    persistor()
    {:ok, state}
  end

  @impl true
  def handle_cast(:schedule_tips, state) do
    recipients = Rwt.RecipientRepository.find()
    tips = Rwt.TipRepository.find()

    scheduled_tips =
      recipients
      |> Enum.map(fn recipient -> schedule_tip_for_recipient(recipient, tips, state) end)
      |> Enum.filter(&(&1 !== nil))

    {:noreply, %{state | scheduled_tips: scheduled_tips}}
  end

  @impl true
  def handle_cast(:send_tips, state) do
    tips_to_send = state.scheduled_tips
                   |> Enum.filter(&(Timex.after?(Timex.now, &1.send_time)))

    Enum.each(tips_to_send, &send_tip/1)

    IO.inspect(state.scheduled_tips)
    IO.inspect(tips_to_send)

    tips_to_send_uuids = Enum.map(tips_to_send, &(&1.uuid))

    new_state = %{
      state |
      scheduled_tips: Enum.reject(state.scheduled_tips, &(Enum.member?(tips_to_send_uuids, &1.uuid))),
      sent_tips: state.sent_tips ++ tips_to_send
    }

    {:noreply, new_state}
  end

  @impl true
  def handle_call(:get_scheduled_tips, _from, state) do
    {:reply, state.scheduled_tips, state}
  end

  @impl true
  def handle_call(:get_sent_tips, _from, state) do
    {:reply, state.sent_tips, state}
  end

  @impl true
  def handle_info(:persist, state) do
    Rwt.Persistence.save(:server, state)
    persistor()
    {:noreply, state}
  end

  # Private

  defp schedule_tip_for_recipient(recipient, tips, state) do
    already_sent_tips =
      state.sent_tips
      |> Enum.filter(
           &(&1.recipient_id === recipient.id && Timex.diff(Timex.now(), &1.send_time, :days) < 14)
         )

    tips
    |> Enum.shuffle()
    |> Enum.reduce(
         nil,
         fn tip, scheduled_tip ->
           with nil <- Enum.find(already_sent_tips, &(&1.tip_id === tip.id)),
                nil <- scheduled_tip do
             %{
               uuid: UUID.uuid4(),
               tip_id: tip.id,
               recipient_id: recipient.id,
               send_time: randomize_hour(state.hours.start, state.hours.end)
             }
           else
             _ -> scheduled_tip
           end
         end
       )
  end

  defp randomize_hour(from, to) do
    random_offset = :rand.uniform((to - from) * 60 - 1) + 1

    Timex.now()
    |> Timex.set(hour: from, minute: 0)
    |> Timex.shift(minutes: random_offset)
  end

  defp send_tip(tip) do
    IO.inspect(tip, label: :send)
    # TODO: implement me
  end

  defp persistor() do
    IO.inspect(:hehe)
    Process.send_after(self(), :persist, 6 * 1000)
  end
end
