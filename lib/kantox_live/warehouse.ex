defmodule SuperMarkex.Warehouse do
  @moduledoc """
  The Warehouse context.
  This module handles all operations related to products and product storage.
  """

  alias SuperMarkex.Warehouse.ProductStore

  @doc """
  Initializes the product store.
  """
  def initialize_store(opts \\ []) do
    ProductStore.init(opts)
  end

  @doc """
  Retrieves a product by its code.
  """
  def get_product(code) do
    ProductStore.get_product(code)
  end

  @doc """
  Lists all products in the store.
  """
  def list_products do
    ProductStore.list_all()
  end

  @doc """
  Checks if a product exists in the store.
  """
  def product_exists?(code) do
    case get_product(code) do
      {:ok, _} -> true
      {:error, :not_found} -> false
    end
  end
end
