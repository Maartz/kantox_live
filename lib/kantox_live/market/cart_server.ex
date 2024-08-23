defmodule SuperMarkex.Market.CartServer do
  @moduledoc """
  A GenServer implementation for managing a shopping cart.

  This module provides a stateful server for each shopping cart,
  implementing the `SuperMarkex.Market.Cart` behavior.
  """

  use GenServer
  alias SuperMarkex.Market.Cart
  alias SuperMarkex.{CartRegistry, Warehouse}
  @behaviour Cart

  # Client API

  @doc """
  Starts a new CartServer process.

  ## Parameters

    * `cart_id` - A unique identifier for the cart.

  ## Returns

    * `{:ok, pid}` if the server started successfully.
    * `{:error, reason}` if the server failed to start.

  ## Examples

      iex> SuperMarkex.Market.CartServer.start_link("cart_123")
      {:ok, #PID<0.123.0>}
  """
  @spec start_link(String.t()) :: GenServer.on_start()
  def start_link(cart_id) do
    GenServer.start_link(__MODULE__, cart_id, name: via_tuple(cart_id))
  end

  @doc """
  Adds an item to the cart.

  ## Parameters

    * `cart` - The cart identifier.
    * `product_code` - The code of the product to add.
    * `quantity` - The quantity of the product to add.

  ## Returns

    * `:ok` if the item was successfully added.
    * `{:error, reason}` if the item could not be added.

  ## Examples

      iex> SuperMarkex.Market.CartServer.add_item("cart_123", "PROD1", 2)
      :ok
  """
  @impl Cart
  @spec add_item(String.t(), String.t(), non_neg_integer()) :: :ok | {:error, String.t()}
  def add_item(cart, product_code, quantity) do
    GenServer.call(via_tuple(cart), {:add_item, product_code, quantity})
  end

  @doc """
  Removes an item from the cart.

  ## Parameters

    * `cart` - The cart identifier.
    * `product_code` - The code of the product to remove.
    * `quantity` - The quantity of the product to remove.

  ## Returns

    * `:ok` if the item was successfully removed.
    * `{:error, reason}` if the item could not be removed.

  ## Examples

      iex> SuperMarkex.Market.CartServer.remove_item("cart_123", "PROD1", 1)
      :ok
  """
  @impl Cart
  @spec remove_item(String.t(), String.t(), non_neg_integer()) :: :ok | {:error, String.t()}
  def remove_item(cart, product_code, quantity) do
    GenServer.call(via_tuple(cart), {:remove_item, product_code, quantity})
  end

  @doc """
  Retrieves all items in the cart.

  ## Parameters

    * `cart` - The cart identifier.

  ## Returns

    A map where keys are product codes and values are quantities.

  ## Examples

      iex> SuperMarkex.Market.CartServer.get_items("cart_123")
      %{"PROD1" => 1, "PROD2" => 3}
  """
  @impl Cart
  @spec get_items(String.t()) :: %{String.t() => non_neg_integer()}
  def get_items(cart) do
    GenServer.call(via_tuple(cart), :get_items)
  end

  @doc """
  Clears all items from the cart.

  ## Parameters

    * `cart` - The cart identifier.

  ## Returns

    `:ok`

  ## Examples

      iex> SuperMarkex.Market.CartServer.clear("cart_123")
      :ok
  """
  @impl Cart
  @spec clear(String.t()) :: :ok
  def clear(cart) do
    GenServer.cast(via_tuple(cart), :clear)
  end

  # Server Callbacks

  @doc false
  @impl GenServer
  def init(cart_id) do
    {:ok, %Cart{id: cart_id}}
  end

  @doc false
  @impl GenServer
  def handle_call({:add_item, product_code, quantity}, _from, %Cart{items: items} = cart) do
    if Warehouse.product_exists?(product_code) do
      updated_items = Map.update(items, product_code, quantity, &(&1 + quantity))
      {:reply, :ok, %{cart | items: updated_items}}
    else
      {:reply, {:error, "Product not found"}, cart}
    end
  end

  @doc false
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

  @doc false
  @impl GenServer
  def handle_call(:get_items, _from, %Cart{items: items} = cart) do
    {:reply, items, cart}
  end

  @doc false
  @impl GenServer
  def handle_cast(:clear, cart) do
    {:noreply, %{cart | items: %{}}}
  end

  @doc false
  defp via_tuple(cart_id), do: CartRegistry.via_tuple(cart_id)
end
