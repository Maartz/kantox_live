defmodule SuperMarkex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    case SuperMarkex.Warehouse.initialize_store() do
      :ok ->
        Logger.info("ProductStore initialized successfully")

      {:error, reason} ->
        Logger.warning(
          "Failed to initialize ProductStore: #{inspect(reason)}. Continuing with empty store."
        )
    end

    children = [
      SuperMarkexWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:kantox_live, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SuperMarkex.PubSub},
      SuperMarkexWeb.Endpoint,
      SuperMarkex.CartRegistry,
      SuperMarkex.Market.CartSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SuperMarkex.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SuperMarkexWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
