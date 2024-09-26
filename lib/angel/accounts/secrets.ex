defmodule Angel.Accounts.Secrets do
  use AshAuthentication.Secret

  def secret_for([:authentication, :tokens, :signing_secret], Angel.Accounts.User, _) do
    case Application.fetch_env(:angel, AngelWeb.Endpoint) do
      {:ok, endpoint_config} ->
        Keyword.fetch(endpoint_config, :secret_key_base)

      :error ->
        :error
    end
  end
end
