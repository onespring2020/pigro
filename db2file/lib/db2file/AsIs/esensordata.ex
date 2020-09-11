defmodule Db2file.AsIs.Esensordata do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:baseymd, :basetime, :sensorid, :svalue]}
  schema "esensordata" do
    field(:baseymd, :string)
    field(:basetime, :string)
    field(:sensorid, :string)
    field(:svalue, :float)
    field(:regdt, :string)
    # field(:sdatetime, :time)
    field(:sdatetime, :decimal)
    field(:extdatayn, :string)

    field(:sensorid_parse, :string, virtual: true)
    # field(:sdatetime, Ecto.DateTime)
    # belongs_to(:sensordata, Sensordata)
    # timestamps()
  end

  # @required_fields ~w(baseymd basetime sensorid)
  # @optional_fields ~w()

  # def changeset(esensordata, params \\ :empty) do
  #   esensordata
  #   |> cast(params, @required_fields, @optional_fields)

  #   # |> unique_constraint(:baseymd, :basetime, :sensorid)
  # end
  def changeset(esensordata, params \\ %{}) do
    esensordata
    |> cast(params, [:baseymd, :basetime, :sensorid, :value])
    |> validate_required([:baseymd, :basetime, :sensorid])
    # |> validate_format(:email, ~r/@/)
    |> validate_inclusion(:value, 0..99999)
  end
end
