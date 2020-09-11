defmodule MongoTest do
  # use MongoTest.Case, async: false
  use ExUnit.Case
  alias Mongo

  # doctest Mongo

  defp connect_url do
    assert {:ok, pid} =
             Mongo.start_link(
               url: "mongodb://bhseong:100hoon@pigro.bitzflex.com:27017/AsIs?authSource=admin"
             )

    pid
  end

  defp connect do
    assert {:ok, pid} =
             Mongo.start_link(
               hostname: "bhseong:100hoon@pigro.bitzflex.com:27017",
               database: "AsIs"
             )

    pid
  end

  defp connect_auth_on_db do
    assert {:ok, pid} =
             Mongo.start_link(
               hostname: "pigro.bitzflex.com:27017",
               database: "AsIs",
               username: "bhseong",
               password: "100hoon",
               auth_source: "admin"
             )

    pid
  end

  test "url" do
    pid = connect_url()
    {:ok, conn, _, _} = Mongo.select_server(pid, :read)

    assert {:ok, %{docs: [%{"ok" => 1.0}]}} =
             Mongo.raw_find(conn, "$cmd", %{ping: 1}, %{}, batch_size: 1)
  end

  test "auth on db" do
    pid = connect_auth_on_db()
    {:ok, conn, _, _} = Mongo.select_server(pid, :read)

    assert {:ok, %{docs: [%{"ok" => 1.0}]}} =
             Mongo.raw_find(conn, "$cmd", %{ping: 1}, %{}, batch_size: 1)
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

  # test "insert encoded struct with protocol" do
  #   pid = connect_auth_on_db()
  #   coll = unique_name()
  #   {:ok, conn, _, _} = Mongo.select_server(pid, :write)

  #   struct_to_insert = %CustomStruct{a: 10, b: 20, c: 30, id: "5ef27e73d2a57d358f812001"}

  #   assert {:ok, _} = Mongo.insert_one(pid, coll, struct_to_insert, [])

  #   assert {:ok,
  #           %{
  #             cursor_id: 0,
  #             from: 0,
  #             num: 1,
  #             docs: [
  #               %{
  #                 "a" => 10,
  #                 "b" => 20,
  #                 "custom_encoded" => true,
  #                 "_id" => "5ef27e73d2a57d358f812001"
  #               }
  #             ]
  #           }} = Mongo.raw_find(conn, coll, %{}, nil, skip: 0)
  # end
  defmacro unique_name do
    {function, _arity} = __CALLER__.function
    "#{__CALLER__.module}.#{function}.#{System.unique_integer([:positive])}"
  end

  defmodule CustomStructWithoutProtocol do
    @fields [:a, :b, :c, :id]
    @enforce_keys @fields
    defstruct @fields
  end

  test "insert encoded struct without protocol" do
    pid = connect_auth_on_db()
    coll = unique_name()
    {:ok, conn, _, _} = Mongo.select_server(pid, :write)

    struct_to_insert = %CustomStructWithoutProtocol{a: 10, b: 20, c: 30, id: "x"}
    assert {:ok, _} = Mongo.insert_one(pid, coll, struct_to_insert, [])
    # assert_raise Protocol.UndefinedError, fn ->
    #   Mongo.insert_one(pid, coll, struct_to_insert, [])
    # end
  end
end
