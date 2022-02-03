defmodule StickyBug.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      # StickyBug.Repo,
      # Start the Telemetry supervisor
      StickyBugWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: StickyBug.PubSub},
      # Start the Endpoint (http/https)
      StickyBugWeb.Endpoint
      # Start a worker by calling: StickyBug.Worker.start_link(arg)
      # {StickyBug.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: StickyBug.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    StickyBugWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
