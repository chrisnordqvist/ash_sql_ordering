defmodule Angel.Accounts.User.Validations.PhoneNumber do
  use Ash.Resource.Validation

  @impl true
  def init(opts) do
    if is_atom(opts[:attribute]) do
      {:ok, opts}
    else
      {:error, "attribute must be an atom"}
    end
  end

  @impl true
  def validate(changeset, opts, _context) do
    value =
      changeset
      |> Ash.Changeset.get_attribute(opts[:attribute])
      |> case do
        %Ash.ForbiddenField{} -> ""
        value -> value
      end
      |> Ash.CiString.to_comparable_string()

    with {:ok, phone} <- ExPhoneNumber.parse(value, nil),
         true <- ExPhoneNumber.is_valid_number?(phone) do
      :ok
    else
      _error ->
        {:error,
         field: opts[:attribute],
         message: "Must be in international format, starting with + and followed by digits only."}
    end
  end
end
