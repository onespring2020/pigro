defmodule Data do
  @derive [Jason.Encoder]
  defstruct name: "", value: 0
end

# defmodule Foo do
#   @derive [Poison.Encoder]
#   defstruct [:bar]
# end
defmodule ToBe do
  @derive [Jason.Encoder]
  defstruct account: "",
            data: %Data{},
            path: nil,
            source: "",
            ts: DateTime
end

require Protocol

Protocol.derive(Jason.Encoder, Data)
Protocol.derive(Jason.Encoder, ToBe)
# defimpl Jason.Encoder, for: ToBe do
#   def encode(value, opts) do
#     Jason.Encode.map(value, opts)
#   end
# end

# defimpl Jason.Encoder, for: Test do
#   def encode(value, opts) do
#     Jason.Encode.map(Map.take(value, [:foo, :bar, :baz]), opts)
#   end
# end
