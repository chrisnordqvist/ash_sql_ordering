defmodule Angel.Accounts.User.Senders.SendMagicLink do
  @moduledoc """
  Sends a magic link
  """
  use AshAuthentication.Sender

  @impl AshAuthentication.Sender
  def send(user, token, _) do
    Angel.Accounts.Emails.deliver_magic_link(
      user,
      "http://localhost:4000/auth/user/magic_link/?token=#{token}"
    )
  end
end
