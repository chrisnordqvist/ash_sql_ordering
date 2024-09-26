defmodule Angel.Accounts.ConnectionRequest do
  use Ash.Resource,
    domain: Angel.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource]

  postgres do
    schema("accounts")
    table("connection_requests")
    repo(Angel.Repo)

    references do
      reference(:source, on_delete: :delete, on_update: :update)
      reference(:destination, on_delete: :delete, on_update: :update)
    end
  end

  attributes do
    uuid_primary_key(:id)

    create_timestamp(:inserted_at, public?: true)
    update_timestamp(:updated_at)

    attribute :status, :atom do
      allow_nil?(false)
      constraints(one_of: [:pending, :accepted, :declined])
      default(:pending)
      public?(true)
    end
  end

  relationships do
    belongs_to(:source, Angel.Accounts.User, allow_nil?: false, public?: true)
    belongs_to(:destination, Angel.Accounts.User, allow_nil?: false, public?: true)
  end

  identities do
    identity(:source_destination_pair, [:source_id, :destination_id])
  end

  policies do
    # Can be read by both the sender and reciever
    policy action_type(:read) do
      authorize_if(expr(source_id == ^actor(:id) || destination_id == ^actor(:id)))
    end

    # Accepting and declining is only permitted by the reciever
    policy changing_attributes(status: [to: :accepted]) do
      authorize_if(expr(destination_id == ^actor(:id)))
    end

    policy changing_attributes(status: [to: :declined]) do
      authorize_if(expr(destination_id == ^actor(:id)))
    end

    # Revoking is only allowed by the sender
    policy action_type(:destroy) do
      authorize_if(expr(source_id == ^actor(:id)))
    end

    # Creation is allowed and passed to the validators
    policy action_type(:create) do
      authorize_if(actor_present())
    end
  end

  graphql do
    type(:connection_request)
  end

  actions do
    read :read do
      primary?(true)
    end

    read :incoming do
      filter(destination_id: actor(:id), status: :pending)
      prepare(build(load: [:source]))
    end

    read :sent do
      filter(source_id: actor(:id), status: [in: [:declined, :pending]])
    end

    create :connect do
      accept([])

      argument :destination_id, :uuid do
        allow_nil?(false)
      end

      change(set_attribute(:source_id, actor(:id)))
      change(set_attribute(:destination_id, arg(:destination_id)))

      validate({Angel.Accounts.Validators.ConnectionRequestValidator, []})
    end

    update :accept do
      accept([])
      require_atomic?(false)

      change(set_attribute(:status, :accepted))
    end

    update :decline do
      accept([])
      change(set_attribute(:status, :declined))
    end

    destroy :revoke do
      accept([])
    end
  end
end
