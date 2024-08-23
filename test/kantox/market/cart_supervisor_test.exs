defmodule SuperMarkex.Market.CartSupervisorTest do
  # fixme: have to find out a better way to handle seamlessly this 
  # as I've to workaround in order to make all the tests pass 
  # if you remove the sleep, you sometimes got the cart still existing 
  # because it was not yet remove when I make the assertion.

  use ExUnit.Case, async: true
  doctest SuperMarkex.Market.CartSupervisor
  alias SuperMarkex.Market.CartSupervisor

  describe "start_cart/1" do
    setup [:delete_all_carts]

    test "starts a new cart process" do
      assert {:ok, pid} = CartSupervisor.start_cart("test_cart")
      assert is_pid(pid)
      assert [{^pid, nil}] = Registry.lookup(SuperMarkex.CartRegistry, "test_cart")
    end

    setup [:delete_all_carts]

    test "returns error when starting a cart with an existing id" do
      assert {:ok, _} = CartSupervisor.start_cart("existing_cart")
      assert {:error, {:already_started, _}} = CartSupervisor.start_cart("existing_cart")
    end
  end

  describe "stop_cart/1" do
    setup [:delete_all_carts]

    test "stops an existing cart process" do
      {:ok, _} = CartSupervisor.start_cart("cart_to_stop")
      assert :ok = CartSupervisor.stop_cart("cart_to_stop")
      Process.sleep(10)
      assert [] = Registry.lookup(SuperMarkex.CartRegistry, "cart_to_stop")
    end

    test "returns error when stopping a non-existent cart" do
      assert {:error, :not_found} = CartSupervisor.stop_cart("nonexistent_cart")
    end
  end

  def delete_all_carts(_context) do
    for {cart_id, _pid} <- SuperMarkex.CartRegistry.list_carts() do
      CartSupervisor.stop_cart(cart_id)
    end

    :ok
  end
end
