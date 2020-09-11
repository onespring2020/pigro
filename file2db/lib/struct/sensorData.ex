defmodule File2DB.Struct.CustomStructWithoutProtocol do
  @fields [:a, :b, :c, :id]
  @enforce_keys @fields
  defstruct @fields
end

# defmodule CustomStruct do
#   @fields [:a, :b, :c, :id]
#   @enforce_keys @fields
#   defstruct @fields

#   defimpl Mongo.Encoder do
#     def encode(%{a: a, b: b, id: id}) do
#       %{
#         _id: id,
#         a: a,
#         b: b,
#         custom_encoded: true
#       }
#     end
#   end
# end
defmodule Data do
  @fields [:name, :value]
  @enforce_keys @fields

  defstruct @fields
end

defmodule Sensordata do
  @fields [:account, :data, :path, :source, :ts]
  @enforce_keys @fields

  defstruct @fields
  # defstruct account: "",
  #           data: %Data{},
  #           path: nil,
  #           source: "",
  #           ts: DateTime
end
