defmodule Angel.Accounts.User.Calculations.DegreesOfSeparation do
  use Ash.Resource.Calculation

  def expression(_opts, _context) do
    expr(
      cond do
        # If the user is the requesting actor
        id == ^actor(:id) -> 0
        # If a relation from the actor to the user exsits, use it's circle
        exists(relations, destination == id) -> 0
        exists(relations, exists(relations, destination == id)) -> 1
        # Fallback
        true -> nil
      end
    )
  end
end
