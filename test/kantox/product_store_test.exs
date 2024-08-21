defmodule SuperMarkex.ProductStoreTest do
  use ExUnit.Case
  alias SuperMarkex.ProductStore
  require Logger

  @moduletag :capture_log

  setup do
    on_exit(fn ->
      ProductStore.reset()
    end)

    :ok
  end

  test "init/1 loads data from CSV" do
    assert :ok = ProductStore.init()

    assert {:ok, %{code: "GR1", name: "Green tea", price: price}} =
             ProductStore.get_product("GR1")

    assert Decimal.equal?(price, Decimal.new("3.11"))

    assert {:ok, %{code: "SR1", name: "Strawberries", price: price}} =
             ProductStore.get_product("SR1")

    assert Decimal.equal?(price, Decimal.new("5.00"))

    assert {:ok, %{code: "CF1", name: "Coffee", price: price}} = ProductStore.get_product("CF1")
    assert Decimal.equal?(price, Decimal.new("11.23"))
  end

  test "get_product/1 returns product when it exists" do
    ProductStore.init()

    assert {:ok, %{code: "GR1", name: "Green tea", price: price}} =
             ProductStore.get_product("GR1")

    assert Decimal.equal?(price, Decimal.new("3.11"))
  end

  test "get_product/1 returns error when product doesn't exist" do
    ProductStore.init()
    assert {:error, :not_found} = ProductStore.get_product("NONEXISTENT")
  end

  test "reset/0 clears all products" do
    ProductStore.init()
    assert {:ok, _} = ProductStore.get_product("GR1")

    ProductStore.reset()

    assert {:error, :not_found} = ProductStore.get_product("GR1")
  end

  test "init/1 handles missing CSV file" do
    result = ProductStore.init(csv_file: "nonexistent.csv")
    assert result == {:error, :csv_not_found}
  end
end

