defmodule SuperMarkex.Product do
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
  Creates a new Product struct.
  """
  def new(code, name, price) when is_binary(code) and is_binary(name) do
    %__MODULE__{
      code: code,
      name: name,
      price: Decimal.new(price)
    }
  end
end

