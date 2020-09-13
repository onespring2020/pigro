defmodule MonthList do
  def getdatesList(first_date \\ ~D[2020-05-01]) do
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
