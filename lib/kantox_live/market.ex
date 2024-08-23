defmodule SuperMarkex.Market do
  @moduledoc """
  The Market context.
  This module handles all operations related to pricing, discounts, checkout, and cart management.
  """

  alias SuperMarkex.Market.{CartServer, CartSupervisor, Cashier}

  @doc """
  Creates a new cart.
  """
  @spec create_cart() :: {:ok, String.t()} | {:error, term()}
  def create_cart do
    cart_id = UUID.uuid4()

    case CartSupervisor.start_cart(cart_id) do
      {:ok, _pid} -> {:ok, cart_id}
      error -> error
    end
  end

  @doc """
  Adds an item to a cart.
  """
  @spec add_to_cart(String.t(), String.t(), non_neg_integer()) :: :ok | {:error, String.t()}
  def add_to_cart(cart_id, product_code, quantity) do
    CartServer.add_item(cart_id, product_code, quantity)
  end

  @doc """
  Removes an item from a cart.
  """
  @spec remove_from_cart(String.t(), String.t(), non_neg_integer()) :: :ok | {:error, String.t()}
  def remove_from_cart(cart_id, product_code, quantity) do
    CartServer.remove_item(cart_id, product_code, quantity)
  end

  @doc """
  Gets the contents of a cart.
  """
  @spec get_cart_contents(String.t()) :: %{String.t() => non_neg_integer()}
  def get_cart_contents(cart_id) do
    CartServer.get_items(cart_id)
  end

  @doc """
  Clears a cart.
  """
  @spec clear_cart(String.t()) :: :ok
  def clear_cart(cart_id) do
    CartServer.clear(cart_id)
  end

  @doc """
  Calculates the total price for a given cart.
  """
  @spec calculate_cart_total(String.t()) :: Decimal.t()
  def calculate_cart_total(cart_id) do
    cart_id
    |> get_cart_contents()
    |> Enum.flat_map(fn {product_code, quantity} -> List.duplicate(product_code, quantity) end)
    |> Cashier.calculate_total()
  end
end
