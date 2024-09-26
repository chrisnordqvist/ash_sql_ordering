## Minimum Repo for SQL ordering bug

This is a very stripped down version of the app we use that have some issues with argument ordering when loading Angel.Accounts.User

### Steps to reproduce
1. Setup the repo and run `mix do ecto.setup, run lib/repo/seeds.exs`
2. In an IEx shell, run `Angel.Accounts.list_users(page: [limit: 1], actor: user)` or the Ash native ` Ash.read! Angel.Accounts.User, page: [limit: 1], actor: user` (the user is loaded from .iex.exs)

Notice that the query only fails when the pagination clause is added in this case `Angel.Accounts.list_users(actor: user)` should work just fine.

In the actual application, we've mostly faced this issue through relationship loads and `ash_graphql` queries, so I'm not so sure where and if pagination is applied then.
