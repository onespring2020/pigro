defmodule File2db do
  @moduledoc """
  Documentation for File2db.
  """

  @doc """
  Hello world.

  ## Examples

      iex> File2db.hello()
      :world

  """
  def hello do
    :world
  end

  defp checkDir(path) do
    case path |> Path.dirname() |> File.stat() do
      {:ok, _} -> :ok
      {:error, :enoent} -> make_dir_p(path)
      {:error, :emfile} -> nil
      {:error, :enomem} -> nil
      {:error, reason} -> IO.puts(reason)
    end
  end

  defp make_dir_p(path) do
    case File.mkdir_p(Path.dirname(path)) do
      :ok ->
        :ok

      {:error, reason} ->
        raise File.Error, reason: reason, action: "make directory_p", path: path
    end
  end

  def importFile2DB(date) do
    path = "../import/" <> date <> "/sensordata.json"
    path |> IO.puts()

    case checkDir(path) do
      :ok -> get_json(path)
      _ -> nil
    end
  end

  defp connect_auth_on_db do
    {:ok, pid} =
      Mongo.start_link(
        hostname: "pigro.bitzflex.com:27017",
        database: "onespring",
        username: "bhseong",
        password: "100hoon",
        auth_source: "admin"
      )

    pid
  end

  def insert do
    pid = connect_auth_on_db()
    {:ok, conn, _, _} = Mongo.select_server(pid, :write)

    # struct_to_insert = %Sensordata{}
    # {:ok, _} = Mongo.insert_one(pid, "pSensorData", struct_to_insert, [])
    # assert_raise Protocol.UndefinedError, fn ->
    #   Mongo.insert_one(pid, coll, struct_to_insert, [])
    # end
  end

  defp get_json(path) do
    {:ok, file} = File.open(path, [:read, :binary])

    case IO.read(file, :all) |> Jason.decode() do
      {:ok, map_list} ->
        map_list |> IO.inspect()

      err ->
        1
        IO.puts("Json Decoding 실패 : #{inspect(err)}")
    end

    File.close(file)
  end
end

defmodule CustomStructWithoutProtocol do
  @fields [:a, :b, :c, :id]
  @enforce_keys @fields
  defstruct @fields
end
