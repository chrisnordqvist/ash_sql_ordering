defmodule Angel.Accounts.User do
  use Ash.Resource,
    domain: Angel.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication, AshJsonApi.Resource, AshGraphql.Resource],
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    schema("accounts")
    table("users")
    repo(Angel.Repo)
  end

  attributes do
    uuid_primary_key(:id)

    attribute(:bio, :string, allow_nil?: true, public?: true)

    attribute(:email, :ci_string, allow_nil?: false, sensitive?: true, public?: true)
    attribute(:email_verified, :boolean, allow_nil?: false, default: false)

    attribute(:phone, :ci_string, allow_nil?: false, sensitive?: true, public?: true)
    attribute(:phone_verified, :boolean, allow_nil?: false, default: false)

    attribute :invite_code, :ci_string do
      allow_nil?(false)
      generated?(true)
      writable?(false)
      public?(true)

      default(fn ->
        for _ <- 1..10, into: "", do: <<Enum.random(~c"0123456789abcdefghijklmnopqrstuvwxyz")>>
      end)
    end

    attribute(:first_name, :string, allow_nil?: false, public?: true)
    attribute(:last_name, :string, allow_nil?: false, public?: true)

    create_timestamp(:inserted_at)
    update_timestamp(:updated_at)

    attribute :role, :atom do
      allow_nil?(false)
      constraints(one_of: [:user, :admin])
      default(:user)
      writable?(false)
    end
  end

  json_api do
    type("user")
  end

  calculations do
    calculate(:name, :string, expr(first_name <> " " <> last_name), public?: true)

    calculate(:status, :atom, Angel.Accounts.User.Calculations.RelationStatus, public?: true)

    calculate(
      :degrees_of_separation,
      :integer,
      Angel.Accounts.User.Calculations.DegreesOfSeparation,
      public?: true
    )
  end

  relationships do
    has_many(:relations, Angel.Accounts.Relation,
      destination_attribute: :source_id,
      writable?: false
    )

    # To allow expresion to access the circle of the requesting user
    has_many(:reverse_relations, Angel.Accounts.Relation,
      destination_attribute: :destination_id,
      writable?: false,
      public?: false
    )

    has_many(:sent_connection_requests, Angel.Accounts.ConnectionRequest,
      destination_attribute: :source_id,
      writable?: false
    )

    has_many(:incoming_connection_requests, Angel.Accounts.ConnectionRequest,
      destination_attribute: :destination_id,
      writable?: false
    )

    belongs_to(:invited_by, Angel.Accounts.User, allow_nil?: true)
  end

  identities do
    identity(:email, [:email])
    identity(:phone, [:phone])
    identity(:invite_code, [:invite_code])
  end

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if(always())
    end

    # Allow users to be read by invite code without actor
    bypass action(:for_invite) do
      authorize_if(always())
    end

    policy action_type(:read) do
      # Do not allow nil for actor for users
      forbid_if(expr(is_nil(^actor(:id))))
      # Actor is present, and has an id
      authorize_if(actor_present())
    end

    policy action_type(:create) do
      authorize_unless(actor_present())
    end

    policy action_type(:update) do
      authorize_if(expr(id == ^actor(:id)))
    end
  end

  field_policies do
    field_policy [:email, :phone, :invite_code] do
      # Only allow the actor to read their own email, phone, and invite_code
      authorize_if(expr(id == ^actor(:id)))
      # For these fields, fall back to deny
      forbid_if(always())
    end

    field_policy :* do
      authorize_if(always())
    end
  end

  graphql do
    type(:user)

    # This allows us to return results with null even if the
    # field policies deny access. Errors will still be shown.
    nullable_fields([:email, :phone, :invite_code])
  end

  actions do
    defaults([:destroy])

    read :list do
      primary?(true)

      pagination do
        required?(false)
        offset?(true)
        countable(false)
      end

      prepare(build(load: [:status, :name]))
    end

    read :show do
      get?(true)
      get_by(:id)
      prepare(build(load: [:name, :status, :interests, :markets, :roles, :investment_rounds]))
    end

    read :myself do
      filter(expr(id == ^actor(:id)))
      prepare(build(load: [:name, :status, :interests, :markets, :roles, :investment_rounds]))
    end

    read :for_invite do
      get?(true)
      get_by(:invite_code)

      prepare(build(load: []))
    end

    create :register do
      accept([:email, :phone, :first_name, :last_name])
    end

    update :update do
      primary?(true)
      require_atomic?(false)
      accept([:first_name, :last_name, :bio])
    end
  end

  validations do
    validate({Angel.Accounts.User.Validations.PhoneNumber, attribute: :phone},
      on: [:create, :update]
    )
  end

  authentication do
    domain(Angel.Accounts)

    strategies do
      magic_link do
        identity_field(:email)
        single_use_token?(false)
        token_lifetime({15, :minutes})
        sender(Angel.Accounts.User.Senders.SendMagicLink)
      end
    end

    tokens do
      enabled?(true)
      token_lifetime({30 * 3, :days})
      token_resource(Angel.Accounts.Token)

      signing_secret(Angel.Accounts.Secrets)
    end
  end
end
