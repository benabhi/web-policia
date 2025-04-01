defmodule Policia.Repo do
  # use Ecto.Repo,
  #  otp_app: :policia,
  #  adapter: Ecto.Adapters.Postgres
  use Ecto.Repo, otp_app: :policia, adapter: Ecto.Adapters.SQLite3
end
