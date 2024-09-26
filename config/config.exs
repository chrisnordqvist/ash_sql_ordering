# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :angel,
  ecto_repos: [Angel.Repo],
  generators: [timestamp_type: :utc_datetime],
  ash_domains: [
    Angel.Accounts
  ]

config :ash, :utc_datetime_type, :datetime

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :angel, Angel.Mailer,
  adapter: Swoosh.Adapters.Local,
  from: {"Nordic Angels", "team@app.nordicangels.com"}

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.3.2",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ash_graphql, :default_managed_relationship_type_name_template, :action_name
config :ash_graphql, :allow_non_null_mutation_arguments?, true

config :spark, :formatter,
  remove_parens?: true,
  "Ash.Resource": [
    type: Ash.Resource,
    section_order: [
      :postgres,
      :attributes,
      :calculations,
      :relationships,
      :identities,
      :policies,
      :field_policies,
      :code_interface,
      :graphql,
      :actions,
      :authentication,
      :token
    ]
  ],
  "Ash.Domain": [
    type: Ash.Domain,
    section_order: [
      :authorization,
      :resources,
      :graphql,
      :jsonapi
    ]
  ]

config :mime, :types, %{
  "application/vnd.api+json" => ["json"]
}

config :mime, :extensions, %{
  "json" => "application/vnd.api+json"
}

config :tesla, :adapter, Tesla.Adapter.Hackney

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
