IO.puts("Loading defaults from .iex.exs...")

user = Ash.read!(Angel.Accounts.User, actor: nil, authorize?: false) |> Enum.random()
