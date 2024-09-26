defmodule Angel.Schema do
  use Absinthe.Schema

  use AshGraphql,
    domains: [
      Angel.Accounts
    ]

  query do
  end

  mutation do
  end
end
