defmodule ImportMongodbTest do
  use ExUnit.Case
  doctest ImportMongodb

  test "greets the world" do
    assert ImportMongodb.hello() == :world
  end
end
