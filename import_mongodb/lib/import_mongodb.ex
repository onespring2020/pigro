defmodule ImportMongodb do
  import FileUtil
  import ListUtil

  @max_num_insertMany 10000
  def importSensordata(date) do
    path = "../_data/import/" <> date <> "/"

    case File.ls(path) do
      {:ok, []} ->
        :not_exist_importfile

      {:ok, files} ->
        case files |> Enum.filter(fn x -> x |> Path.extname() == ".json" end) do
          [] ->
            :not_exist_importfile

          files ->
            processList =
              for filename <- files do
                pid = spawn(ImportMongodb, :doImportSensordata, [path <> filename])
                send(pid, {:ing, ~s[#{path}#{filename}]})
                Process.sleep(1000)
                # send(pid, {self(), ~s[#{path}#{filename}]})
                pid
              end

            IO.inspect(processList)
        end

      {:error, error} ->
        IO.puts(error.message)
    end
  end

  def doImportSensordata(path) do
    receive do
      {:ing, path} ->
        # IO.inspect(self())
        IO.puts("importing... : #{path}")

        # {sender, msg} ->
        #   IO.inspect(sender)
    end

    {:ok, file} = File.open(path, [:read, :binary])

    done_path = path |> String.replace("/import/", "/import_done/") |> Path.dirname()
    filename = path |> Path.split() |> List.last()
    # IO.puts(path)
    # IO.puts(done_path)
    case IO.read(file, :all) |> Jason.decode() do
      {:ok, map_list} ->
        count = map_list |> Enum.count()
        # IO.inspect(map_list)

        case insert_filedata(map_list, []) do
          {:done, total} ->
            move_file(path, ~s[#{done_path}/ok/#{count}_#{total}_#{filename}])

          _ ->
            nil
        end
    end

    File.close(file)
  end

  defp insert_filedata([], cnt_list) do
    total_cnt = cnt_list |> ListUtil.sum()
    IO.inspect(cnt_list)
    IO.puts("----------> done : #{total_cnt} <-----------------")
    {:done, total_cnt}
  end

  defp insert_filedata(map_list, cnt_list) do
    sub_list = map_list |> Enum.split(@max_num_insertMany) |> Tuple.to_list() |> List.first()
    map_list = map_list -- sub_list

    case insert_many(sub_list) do
      {:ok_insert, inserted_ids_cnt} ->
        cnt_list = cnt_list ++ [inserted_ids_cnt]
        insert_filedata(map_list, cnt_list)

      _ ->
        nil
    end
  end

  defp insert_many([]) do
    {:no_insert_data, 0}
  end

  defp insert_many(list, coll \\ "esensordata") do
    conn = connect_url()

    case Mongo.insert_many(conn, coll, list) do
      {:ok, result} ->
        inserted_ids_cnt = result.inserted_ids |> Enum.count()
        {:ok_insert, inserted_ids_cnt}

      {:error, error} ->
        # move_file(path, ~s[#{done_path}/error/#{filename}])
        IO.puts("오류: #{error.message}")
        {:error, error}

      _ ->
        nil
    end
  end

  # defp connect_auth_on_db do
  #   {:ok, pid} =
  #     Mongo.start_link(
  #       hostname: "pigro.bitzflex.com:27017",
  #       database: "onespring",
  #       username: "bhseong",
  #       password: "100hoon",
  #       auth_source: "admin"
  #       # connect_timeout_ms: 500_000,
  #       # pool_timeout: 500_000,
  #       # timeout: 1500_000,
  #       # pool: DBConnection.Poolboy,
  #       # pool_size: 50,
  #       # pool_overflow: 30
  #     )

  #   pid
  # end

  defp connect_url do
    {:ok, pid} =
      Mongo.start_link(
        url:
          "mongodb://bhseong:100hoon@pigro.bitzflex.com:27017/onespring?authSource=admin&keepAlive=true&poolSize=30&autoReconnect=true&socketTimeoutMS=11500000&connectTimeoutMS=11500000"
      )

    pid
  end
end
