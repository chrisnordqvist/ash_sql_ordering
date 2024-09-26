defmodule Angel.MixProject do
  use Mix.Project

  def project do
    [
      app: :angel,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Angel.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7.10"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.20.1"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.2"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},
      {:exsync, "~> 0.2", only: :dev},
      {:swoosh, "~> 1.3"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, ">= 0.0.0"},
      {:ash, "~> 3.0"},
      {:ash_postgres, "~> 2.0"},
      {:ash_authentication, "~> 4.0"},
      {:ash_authentication_phoenix, "~> 2.0"},
      {:ash_phoenix, "~> 2.0"},
      {:ash_graphql, "~> 1.2"},
      {:ash_json_api, "~> 1.0"},
      {:faker, "~> 0.17", only: :dev},
      {:ex_aws, "~> 2.0"},
      {:ex_aws_s3, "~> 2.0"},
      {:poison, "~> 5.0"},
      {:hackney, "~> 1.9"},
      {:sweet_xml, "~> 0.7"},
      {:briefly, "~> 0.5.0"},
      {:image, "~> 0.37"},
      {:req, "~> 0.5.0"},
      {:picosat_elixir, "~> 0.2"},
      {:nimble_totp, "~> 1.0"},
      {:tesla, "~> 1.12"},
      {:ex_phone_number, "~> 0.4.5"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      # Allows us to use `mix ci` locally for the same checks as CI
      ci: ["format --check-formatted", "compile --warnings-as-errors"],
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end
