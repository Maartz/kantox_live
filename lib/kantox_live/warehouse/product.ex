defmodule SuperMarkex.Warehouse.Product do
  @moduledoc """
  Represents a product in the SuperMarkex system.
  """

  @enforce_keys [:code, :name, :price]
  defstruct [:code, :name, :price]

  @type t :: %__MODULE__{
          code: String.t(),
          name: String.t(),
          price: Decimal.t()
        }

  @doc """
  Creates a new Product struct. Price ought be passed as a `String.t()`.

  ## Examples

      iex> SuperMarkex.Warehouse.Product.new("GR1", "Green Tea", "3.11")
      %SuperMarkex.Warehouse.Product{code: "GR1", name: "Green Tea", price: Decimal.new("3.11")}

      iex> SuperMarkex.Warehouse.Product.new("CF1", "Coffee", "11.23")
      %SuperMarkex.Warehouse.Product{code: "CF1", name: "Coffee", price: Decimal.new("11.23")}

      iex> SuperMarkex.Warehouse.Product.new("SR1", "Strawberries", "5.00")
      %SuperMarkex.Warehouse.Product{code: "SR1", name: "Strawberries", price: Decimal.new("5.00")}

  """
  def new(code, name, price) when is_binary(code) and is_binary(name) do
    %__MODULE__{
      code: code,
      name: name,
      price: Decimal.new(price)
    }
  end
end
