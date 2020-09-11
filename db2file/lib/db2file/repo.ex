defmodule Db2file.Repo do
  use Ecto.Repo,
    otp_app: :db2file,
    adapter: Ecto.Adapters.Jamdb.Oracle
end
