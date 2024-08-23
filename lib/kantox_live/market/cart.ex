defmodule SuperMarkex.Market.Cart do
  @moduledoc """
  Defines the structure and behavior for a shopping cart in the SuperMarkex system.

  This module provides a struct representing a cart and specifies a behavior
  for cart operations through callbacks.
  """

  @typedoc """
  Represents a shopping cart.

  Fields:
    * `:id` - A unique identifier for the cart.
    * `:items` - A map where keys are product codes and values are quantities.
  """
  @type t :: %__MODULE__{
          id: String.t(),
          items: %{String.t() => non_neg_integer()}
        }

  @doc """
  Adds an item to the cart.

  ## Parameters

    * `cart_id` - The cart identifier.
    * `product_code` - The code of the product to add.
    * `quantity` - The quantity of the product to add.

  ## Returns

    * `:ok` if the item was successfully added.
    * `{:error, reason}` if the item could not be added.
  """
  @callback add_item(String.t(), String.t(), non_neg_integer()) :: :ok | {:error, String.t()}

  @doc """
  Removes an item from the cart.

  ## Parameters

    * `cart_id` - The cart identifier.
    * `product_code` - The code of the product to remove.
    * `quantity` - The quantity of the product to remove.

  ## Returns

    * `:ok` if the item was successfully removed.
    * `{:error, reason}` if the item could not be removed.
  """
  @callback remove_item(String.t(), String.t(), non_neg_integer()) :: :ok | {:error, String.t()}

  @doc """
  Retrieves all items in the cart.

  ## Parameters

    * `cart_id` - The cart identifier.

  ## Returns

    A map where keys are product codes and values are quantities.
  """
  @callback get_items(String.t()) :: %{String.t() => non_neg_integer()}

  @doc """
  Clears all items from the cart.

  ## Parameters

    * `cart_id` - The cart identifier.

  ## Returns

    `:ok`
  """
  @callback clear(String.t()) :: :ok

  defstruct [:id, items: %{}]
end
