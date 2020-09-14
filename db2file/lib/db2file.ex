defmodule Db2file do
  alias Db2file.Repo
  import Ecto.Query, only: [from: 2]
  import Timex
  import MonthList

  @hours 1
  @sleep_interval 250
  @moduledoc """
  Documentation for Db2file.
  """
  def getSensordataList(date, x) do
    # maxtime = Db2file.Query.getMaxtime(date)

    # query = ~s[select e.baseymd, e.basetime, e.sensorid, e.svalue from esensordata e
    #   where e.baseymd = '#{date}' and e.basetime = '#{maxtime}' and rownum < 4]
    query =
      ~s[select e.baseymd, e.basetime, e.sensorid, e.svalue from esensordata e
      where e.baseymd = '#{date}'
       AND SDATETIME >= TO_CHAR(TO_DATE('#{date}000000','YYYYMMDDHH24MISS') + INTERVAL '#{
        x - @hours
      }' HOUR, 'YYYYMMDDHH24MISS')
       AND SDATETIME < TO_CHAR(TO_DATE('#{date}000000','YYYYMMDDHH24MISS') + INTERVAL '#{x}' HOUR, 'YYYYMMDDHH24MISS')
      ]

    case Ecto.Adapters.SQL.query(Db2file.Repo, query, []) do
      {:ok, %{rows: []}} ->
        {:empty, []}

      {:ok, %{rows: rows}} ->
        {:ok, rows |> make_maplistSensordata()}

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

  def make_fileSensorData(date, x, new_path) do
    receive do
      {:ok, msg} ->
        IO.inspect(self())
        local_now = NaiveDateTime.from_erl!(:calendar.local_time())
        IO.puts("[#{local_now}] exporting... : #{msg}")

        # DateTime.utc_now() |> Timex.shift(months: 3) |> Timex.format("{YYYY}{0M}{0D}-{am}.{h24}:{m}:{s}")
    end

    # {:ok, file} = File.open(path, [:write])

    try do
      case getSensordataList(date, x) do
        {:ok, map_list} ->
          json_list =
            for item <- map_list do
              tobe = %{
                account: String.split(Map.get(item, "sensorid"), "|") |> Enum.at(0),
                data: %{name: Map.get(item, "sensorid"), value: Map.get(item, "svalue")},
                path: nil,
                source: String.split(Map.get(item, "sensorid"), "|") |> Enum.at(1),
                ts:
                  (String.slice(Map.get(item, "baseymd"), 2, 8) <>
                     Map.get(item, "basetime") <> "Z")
                  |> to_utcTime()
                  |> DateTime.to_unix()
              }

              tobe
            end

          # IO.inspect(json_list)
          path = new_path |> Path.dirname()
          filename = new_path |> Path.split() |> List.last()
          total_cnt = json_list |> Enum.count()

          new_path =
            ~s[#{path}/#{Path.basename(filename, ".json")}_(#{total_cnt})#{Path.extname(filename)}]

          {:ok, file_new} = File.open(new_path, [:write, :binary])

          IO.write(
            file_new,
            # Jason.encode!(json_list)
            Jason.encode!(json_list) |> to_string() |> String.replace("},{", "},\n{")
          )

          File.close(file_new)

          # self() |> IO.inspect()

          IO.puts(
            "[#{NaiveDateTime.from_erl!(:calendar.local_time())}] <#{new_path}> Exported Completed! count : #{
              json_list |> Enum.count()
            }"
          )

          :ok

        {:empty, []} ->
          IO.puts("조회 데이터없음")
          :empty
      end
    rescue
      e in File.Error -> IO.puts("File Error:" <> e.reason)
    after
      # File.close(file)
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
    # processList =
    1..24
    |> Enum.to_list()
    |> Enum.filter(fn x -> rem(x, @hours) == 0 end)
    |> Enum.with_index()
    |> Enum.each(fn {x, i} ->
      new_path = ~s[../_data/import/#{date}/sensordata_#{i + 1}.json]
      # IO.puts("path =>  #{new_path}" <> "\n")

      # if checkDir(path) == :ok && checkDir(new_path) == :ok do
      if checkDir(new_path) == :ok do
        pid = spawn(Db2file, :make_fileSensorData, [date, x, new_path])
        send(pid, {:ok, ~s[#{new_path}]})
      end
    end)

    # case make_fileSensorData(date, path) do
    #   [:ok] -> [:ok]
    #   _ -> nil
    # end
    # IO.inspect(processList)

    # for p <- processList do
    #   if Process.alive?(p) do
    #     IO.puts("???궁금")
    #     Process.exit(p, :exit)
    #   end

    # send p, :stop
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

  def batchExport_2019_1Q() do
    list_1 = getdatesList(~D[2019-01-01])
    list_2 = getdatesList(~D[2019-02-01])
    list_3 = getdatesList(~D[2019-03-01])

    list_1Q = list_1 ++ list_2 ++ list_3

    for date <- list_1Q do
      IO.puts(
        "[#{NaiveDateTime.from_erl!(:calendar.local_time())}] ____ exportData2File start === <#{
          date
        }>"
      )

      exportData2File(date)
      # p_list = exportData2File(date)
      # IO.inspect(p_list)
      Process.sleep(1000 * @sleep_interval)

      "[#{NaiveDateTime.from_erl!(:calendar.local_time())}] ____ exportData2File end === <#{date}>"
    end
  end
end
