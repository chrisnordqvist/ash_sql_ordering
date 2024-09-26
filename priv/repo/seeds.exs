# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Angel.Repo.insert!(%Angel.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Angel.Accounts.register!(%{
  email: "test@test.com",
  first_name: "First",
  last_name: "Last",
  phone: "+46700000000"
})
