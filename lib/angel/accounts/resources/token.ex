defmodule Angel.Accounts.Token do
  use Ash.Resource,
    domain: Angel.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication.TokenResource]

  postgres do
    schema "accounts"
    table "tokens"
    repo Angel.Repo
  end

  token do
    domain Angel.Accounts
  end

  # If using policies, add the following bypass:
  # policies do
  #   bypass AshAuthentication.Checks.AshAuthenticationInteraction do
  #     authorize_if always()
  #   end
  # end
end
