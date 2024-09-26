defmodule Angel.Accounts.User.Calculations.RelationStatus do
  use Ash.Resource.Calculation

  def expression(_opts, %{actor: nil}), do: :not_available

  def expression(_opts, context) do
    expr(
      cond do
        # If the user is the requesting actor
        id == ^context.actor.id ->
          :self

        # If a relation from the actor to the user exsits, use it's circle
        exists(reverse_relations, source == ^context.actor.id) ->
          reverse_relations.circle

        # Connection requests
        exists(sent_connection_requests, destination_id == ^context.actor.id) ->
          :connection_requested

        exists(incoming_connection_requests, source_id == ^context.actor.id) ->
          :sent_request

        # Fallback
        true ->
          :not_connected
      end
    )
  end
end
