defmodule StickyBug.Repo do
  use Ecto.Repo,
    otp_app: :sticky_bug,
    adapter: Ecto.Adapters.Postgres
end
