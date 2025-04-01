defmodule Policia.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PoliciaWeb.Telemetry,
      Policia.Repo,
      {DNSCluster, query: Application.get_env(:policia, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Policia.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Policia.Finch},
      # Start a worker by calling: Policia.Worker.start_link(arg)
      # {Policia.Worker, arg},
      # Start to serve requests, typically the last entry
      PoliciaWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Policia.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PoliciaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
