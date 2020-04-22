defmodule Rwt.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Rwt.Scheduler,
      {Rwt.Server, []},
      {Rwt.RecipientRepository, []},
      {Rwt.TipRepository, []}
    ]

    opts = [strategy: :one_for_one, name: Rwt.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
