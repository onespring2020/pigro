defmodule FileUtil do
  def check_dir(path) do
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

  def move_file(path, new_path) do
    if check_dir(new_path) == :ok do
      case File.rename(path, new_path) do
        :ok ->
          :ok

        {:error, reason} ->
          raise File.Error, reason: reason, action: "move_file", path: path
          # IO.puts("오류 : #{reason}")
      end
    end
  end
end

defmodule ListUtil do
  def sum(list), do: _sum(list, 0)
  # private methods
  defp _sum([], total), do: total
  defp _sum([head | tail], total), do: _sum(tail, head + total)

  def getDatesListInMonth(first_date \\ ~D[2020-09-01]) do
    days = Timex.days_in_month(first_date)

    for x <- 0..(days - 1) do
      case Timex.shift(first_date, days: x)
           |> Timex.format("{YYYY}{0M}{0D}") do
        {:ok, date} ->
          date

        _ ->
          nil
      end
    end
  end
end
