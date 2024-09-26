defmodule Angel.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Angel.Repo,
      {DNSCluster, query: Application.get_env(:angel, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Angel.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Angel.Finch},

      # Auth
      {AshAuthentication.Supervisor, otp_app: :angel}
      # Start a worker by calling: Angel.Worker.start_link(arg)
      # {Angel.Worker, arg},
      # Start to serve requests, typically the last entry
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Angel.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
