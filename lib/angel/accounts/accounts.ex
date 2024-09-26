defmodule Angel.Accounts do
  use Ash.Domain,
    extensions: [
      AshGraphql.Domain
    ]

  authorization do
    authorize :by_default
    require_actor? false
  end

  resources do
    resource Angel.Accounts.User do
      define :list_users, action: :list
      define :get_user, action: :show, args: [:id]
      define :register, action: :register
      define :update_user, action: :update

      define :get_user_by_invite_code, action: :for_invite, args: [:invite_code]
    end

    resource Angel.Accounts.Token

    resource Angel.Accounts.Relation do
      define :list_relations, action: :list
      define :get_relation, action: :get
    end

    resource Angel.Accounts.ConnectionRequest do
      define :send_connection_request, action: :connect, args: [:destination_id]
      define :incoming_connection_requests, action: :incoming
      define :sent_connection_requests, action: :sent
      define :accept_connection_request, action: :accept
      define :decline_connection_request, action: :decline
      define :revoke_connection_request, action: :revoke
    end
  end

  graphql do
    queries do
      list Angel.Accounts.User, :users, action: :list
      get Angel.Accounts.User, :user, action: :show

      read_one(Angel.Accounts.User, :myself, action: :myself)

      list Angel.Accounts.Relation, :relations, action: :list

      list Angel.Accounts.ConnectionRequest, :incoming_connection_requests, action: :incoming
      list Angel.Accounts.ConnectionRequest, :sent_connection_requests, action: :sent
    end

    mutations do
      update(Angel.Accounts.User, :update_profile, action: :update)

      create(Angel.Accounts.ConnectionRequest, :send_connection_request, action: :connect)
      update(Angel.Accounts.ConnectionRequest, :accept_connection_request, action: :accept)
      update(Angel.Accounts.ConnectionRequest, :decline_connection_request, action: :decline)
      destroy(Angel.Accounts.ConnectionRequest, :revoke_connection_request, action: :revoke)
    end
  end
end
