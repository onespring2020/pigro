defmodule Db2file.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Db2file.Repo, []}
      # Starts a worker by calling: Db2file.Worker.start_link(arg)
      # {Db2file.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Db2file.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
