defmodule Angel.Accounts.Relation do
  use Ash.Resource,
    domain: Angel.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource]

  postgres do
    schema("accounts")
    table("relations")
    repo(Angel.Repo)
  end

  attributes do
    create_timestamp(:inserted_at)
    update_timestamp(:updated_at)

    attribute :circle, :atom do
      allow_nil?(false)
      constraints(one_of: [:inner_circle, :outer_circle, :contact])
      default(:contact)
      public?(true)
    end
  end

  relationships do
    belongs_to(:source, Angel.Accounts.User, allow_nil?: false, primary_key?: true)

    belongs_to(:destination, Angel.Accounts.User,
      allow_nil?: false,
      primary_key?: true,
      public?: true
    )
  end

  identities do
    identity(:source_destination_pair, [:source_id, :destination_id])
  end

  policies do
    policy action_type(:read) do
      authorize_if(expr(source_id == ^actor(:id)))
    end

    policy action_type(:create) do
      authorize_if(always())
    end

    policy action_type(:update) do
      authorize_if(expr(source_id == ^actor(:id)))
    end

    policy action_type(:destroy) do
      authorize_if(expr(source_id == ^actor(:id)))
    end
  end

  graphql do
    type(:relation)
  end

  actions do
    defaults([:update])

    read :list do
      primary?(true)
      prepare(build(load: :destination))
    end

    read :get do
      get?(true)
      get_by([:source_id, :destination_id])
      prepare(build(load: :destination))
    end

    create :create do
      accept([])
      primary?(true)

      argument :source_id, :uuid do
        allow_nil?(false)
      end

      argument :destination_id, :uuid do
        allow_nil?(false)
      end

      change(set_attribute(:source_id, arg(:source_id)))
      change(set_attribute(:destination_id, arg(:destination_id)))
    end
  end
end
