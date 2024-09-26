defmodule Angel.Accounts.Validators.ConnectionRequestValidator do
  use Ash.Resource.Validation

  import Ecto.Query, only: [from: 2]

  def init(opts) do
    {:ok, opts}
  end

  def validate(changeset, _context, _opts) do
    {:ok, source} = Ash.Changeset.fetch_argument_or_change(changeset, :source_id)
    {:ok, dest} = Ash.Changeset.fetch_argument_or_change(changeset, :destination_id)

    # Any truthy value will fail the validations, will run in order
    checks = [
      # Don't allow self connecting
      source == dest,

      # Check for existing relation, order should not matter here
      Angel.Repo.exists?(
        from(r in Angel.Accounts.Relation,
          where:
            r.source_id == ^source and
              r.destination_id == ^dest
        ),
        prefix: "accounts"
      ),

      # Check for a reverse connection request
      Angel.Repo.exists?(
        from(r in Angel.Accounts.ConnectionRequest,
          where:
            r.source_id == ^dest and
              r.destination_id == ^source
        ),
        prefix: "accounts"
      )
    ]

    case Enum.any?(checks) do
      true ->
        {:error, field: :destination_id, message: "Relation already present"}

      false ->
        :ok
    end
  end
end
