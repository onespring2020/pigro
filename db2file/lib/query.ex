defmodule Db2file.Query do
  alias Db2file.Repo
  alias Db2file.AsIs.Cpy_Esensordata
  alias Db2file.AsIs.Esensordata
  import Ecto.Query, only: [from: 2]

  def getMaxtime(date) do
    Repo.one(
      from(e in Esensordata,
        where: e.baseymd == ^date,
        select: max(e.basetime)
      )
    )

    # |> IO.inspect()
  end

  def getLasttime_esensordata(date) do
    Repo.one(
      from(e in Cpy_Esensordata,
        where: e.baseymd == ^date,
        select: max(e.basetime)
      )
    )

    # |> IO.inspect()
  end

  def getEsensordata(date) do
    Repo.all(
      from(e in Cpy_Esensordata,
        where: e.baseymd == ^date,
        # limit: 10,
        where: fragment("rownum") < 10,
        select: [e.baseymd, e.basetime, e.sensorid, e.svalue]
      )
    )
    |> IO.inspect()
  end
end
