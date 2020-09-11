defmodule Db2file do
  alias Db2file.Repo
  alias Db2file.AsIs.Esensordata
  alias Db2file.Query
  import Ecto.Query, only: [from: 2]
  import Timex

  @moduledoc """
  Documentation for Db2file.
  """
  # defp getMaxtime(date) do
  #   query = ~s[select max(e.basetime) from esensordata e where e.baseymd = '#{date}']

  #   case Ecto.Adapters.SQL.query(Db2file.Repo, query, []) do
  #     {:ok, %{rows: rows}} -> rows |> Enum.at(0) |> List.to_string()
  #     # {:ok, %{rows: [[basetime | _] | _]}} -> basetime
  #     _ -> nil
  #   end
  # end

  def getSensordataList(date) do
    # maxtime = Db2file.Query.getMaxtime(date)

    # query = ~s[select e.baseymd, e.basetime, e.sensorid, e.svalue from esensordata e
    #   where e.baseymd = '#{date}' and e.basetime = '#{maxtime}' and rownum < 4]
    query = ~s[select e.baseymd, e.basetime, e.sensorid, e.svalue from esensordata e
      where e.baseymd = '#{date}' ]

    #        columns |> Enum.map(&String.to_atom(&1)) |> IO.inspect()
    case Ecto.Adapters.SQL.query(Db2file.Repo, query, []) do
      {:ok, %{rows: rows}} ->
        rows |> make_maplistSensordata()

      {:error, %{message: message}} ->
        message |> IO.inspect()
    end
  end

  defp make_maplistSensordata(rows) do
    # rows = [
    #   ["20200817", "235956", "sungwoo@sungwoo.com|modbus_gw_13|1|4|0", 27.8],
    #   ["20200817", "235956", "sungwoo@sungwoo.com|modbus_gw_13|1|4|1", 99.0],
    #   ["20200817", "235956", "sungwoo@sungwoo.com|modbus_gw_13|1|4|2", 99.0]
    # ]

    # columns = ["baseymd", "basetime", "sensorid", "svalue", "regdt", "sdatetime", "extdatayn"]
    columns = ["baseymd", "basetime", "sensorid", "svalue"]

    Enum.map(rows, fn row ->
      columns
      |> Enum.zip(row)
      |> Enum.into(%{})
      |> Map.new()
    end)

    # |> IO.inspect()
  end

  defp make_dir_p(path) do
    case File.mkdir_p(Path.dirname(path)) do
      :ok ->
        :ok

      {:error, reason} ->
        raise File.Error, reason: reason, action: "make directory_p", path: path
    end
  end

  defp make_fileSensorData(date, path) do
    {:ok, file} = File.open(path, [:write])
    new_path = "../import/" <> date <> "/sensordata.json"

    case checkDir(new_path) do
      :ok -> :ok
      _ -> nil
    end

    {:ok, file_new} = File.open(new_path, [:write, :binary])

    try do
      map_list = getSensordataList(date)

      for item <- map_list do
        IO.write(file, inspect(item) <> ",")
        # IO.puts(inspect(item))

        # IO.puts(Map.get(item, "sensorid"))
        # date = %Data{name:}
        data = %Data{name: Map.get(item, "sensorid"), value: Map.get(item, "svalue")}

        tobe = %ToBe{
          account: String.split(Map.get(item, "sensorid"), "|") |> Enum.at(0),
          data: data,
          path: nil,
          source: String.split(Map.get(item, "sensorid"), "|") |> Enum.at(1),
          ts:
            (String.slice(Map.get(item, "baseymd"), 2, 8) <> Map.get(item, "basetime") <> "Z")
            |> to_utcTime()
        }

        # tobe_list = tobe_list ++ (tobe |> List.wrap())
        # tobe_list |> inspect() |> IO.puts()
        # tobe_list = tobe_list |> List.insert_at(-1, tobe)
        if item == List.first(map_list) do
          IO.write(file_new, "[ \n" <> Jason.encode!(tobe) <> " ,\n")
        end

        if item != List.first(map_list) && item != List.last(map_list) do
          IO.write(file_new, Jason.encode!(tobe) <> " ,\n")
        end

        if item == List.last(map_list) do
          IO.write(file_new, Jason.encode!(tobe) <> "\n]")
        end
      end

      # tobe |> Jason.encode() |> inspect() |> IO.puts()
      # tobe_list |> IO.inspect()
    rescue
      e in File.Error -> IO.puts("File Error:" <> e.reason)
    after
      File.close(file)
      File.close(file_new)
    end
  end

  defp to_utcTime(ts) do
    case Timex.parse(ts, "{ASN1:UTCtime}") do
      {:ok, date} ->
        date

      _ ->
        nil
    end
  end

  def exportData2File(date) do
    path = "./export/" <> date <> "/sensordata.txt"

    case checkDir(path) do
      :ok -> make_fileSensorData(date, path)
      _ -> nil
    end

    # case make_fileSensorData(date, path) do
    #   [:ok] -> [:ok]
    #   _ -> nil
    # end
  end

  def checkDir(path) do
    case path |> Path.dirname() |> File.stat() do
      {:ok, _} -> :ok
      {:error, :enoent} -> make_dir_p(path)
      {:error, :emfile} -> nil
      {:error, :enomem} -> nil
      {:error, reason} -> IO.puts(reason)
    end
  end
end
