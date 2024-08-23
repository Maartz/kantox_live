defmodule SuperMarkex.Market.CartServer do
  @moduledoc """
  A GenServer implementation for managing a shopping cart.
  """

  use GenServer
  alias SuperMarkex.Market.Cart
  alias SuperMarkex.{CartRegistry, Warehouse}

  @behaviour Cart

  # Client API

  @spec start_link(String.t()) :: GenServer.on_start()
  def start_link(cart_id) do
    GenServer.start_link(__MODULE__, cart_id, name: via_tuple(cart_id))
  end

  @impl Cart
  def add_item(cart, product_code, quantity) do
    GenServer.call(via_tuple(cart), {:add_item, product_code, quantity})
  end

  @impl Cart
  def remove_item(cart, product_code, quantity) do
    GenServer.call(via_tuple(cart), {:remove_item, product_code, quantity})
  end

  @impl Cart
  def get_items(cart) do
    GenServer.call(via_tuple(cart), :get_items)
  end

  @impl Cart
  def clear(cart) do
    GenServer.cast(via_tuple(cart), :clear)
  end

  # Server Callbacks

  @impl GenServer
  def init(cart_id) do
    {:ok, %Cart{id: cart_id}}
  end

  @impl GenServer
  def handle_call({:add_item, product_code, quantity}, _from, %Cart{items: items} = cart) do
    if Warehouse.product_exists?(product_code) do
      updated_items = Map.update(items, product_code, quantity, &(&1 + quantity))
      {:reply, :ok, %{cart | items: updated_items}}
    else
      {:reply, {:error, "Product not found"}, cart}
    end
  end

  @impl GenServer
  def handle_call({:remove_item, product_code, quantity}, _from, %Cart{items: items} = cart) do
    case Map.fetch(items, product_code) do
      {:ok, current_quantity} ->
        new_quantity = max(0, current_quantity - quantity)

        updated_items =
          if new_quantity == 0,
            do: Map.delete(items, product_code),
            else: Map.put(items, product_code, new_quantity)

        {:reply, :ok, %{cart | items: updated_items}}

      :error ->
        {:reply, {:error, "Product not in cart"}, cart}
    end
  end

  @impl GenServer
  def handle_call(:get_items, _from, %Cart{items: items} = cart) do
    {:reply, items, cart}
  end

  @impl GenServer
  def handle_cast(:clear, cart) do
    {:noreply, %{cart | items: %{}}}
  end

  defp via_tuple(cart_id), do: CartRegistry.via_tuple(cart_id)
end
