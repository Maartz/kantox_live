defmodule SuperMarkex.Market.CartTest do
  use ExUnit.Case, async: true
  alias SuperMarkex.Market
  alias SuperMarkex.Warehouse

  setup do
    Warehouse.initialize_store()
    :ok
  end

  describe "cart operations" do
    setup do
      {:ok, cart_id} = Market.create_cart()
      %{cart_id: cart_id}
    end

    test "create_cart/0 creates a new cart", %{cart_id: cart_id} do
      assert is_binary(cart_id)
    end

    test "add_to_cart/3 adds an item to the cart", %{cart_id: cart_id} do
      assert :ok = Market.add_to_cart(cart_id, "GR1", 2)
      assert %{"GR1" => 2} = Market.get_cart_contents(cart_id)
    end

    test "add_to_cart/3 returns error for non-existent product", %{cart_id: cart_id} do
      assert {:error, "Product not found"} = Market.add_to_cart(cart_id, "NONEXISTENT", 1)
    end

    test "remove_from_cart/3 removes an item from the cart", %{cart_id: cart_id} do
      Market.add_to_cart(cart_id, "GR1", 3)
      assert :ok = Market.remove_from_cart(cart_id, "GR1", 2)
      assert %{"GR1" => 1} = Market.get_cart_contents(cart_id)
    end

    test "remove_from_cart/3 removes item entirely if quantity reaches 0", %{cart_id: cart_id} do
      Market.add_to_cart(cart_id, "GR1", 2)
      assert :ok = Market.remove_from_cart(cart_id, "GR1", 2)
      assert %{} = Market.get_cart_contents(cart_id)
    end

    test "clear_cart/1 empties the cart", %{cart_id: cart_id} do
      Market.add_to_cart(cart_id, "GR1", 2)
      Market.add_to_cart(cart_id, "SR1", 1)
      assert :ok = Market.clear_cart(cart_id)
      assert %{} = Market.get_cart_contents(cart_id)
    end

    test "calculate_cart_total/1 calculates the correct total", %{cart_id: cart_id} do
      Market.add_to_cart(cart_id, "GR1", 2)
      Market.add_to_cart(cart_id, "SR1", 1)
      total = Market.calculate_cart_total(cart_id)
      assert Decimal.equal?(total, Decimal.new("8.11"))
    end
  end
end
