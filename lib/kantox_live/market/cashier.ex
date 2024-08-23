defmodule SuperMarkex.Market.Cashier do
  @moduledoc """
  The Cashier module handles the calculation of total prices for shopping baskets,
  applying various pricing rules and discounts.

  It uses a set of predefined rules for special pricing and discounts on specific products.
  """

  alias SuperMarkex.Warehouse.{Product, ProductStore}
  require Logger

  @doc """
  Calculates the total price for a given basket of products.

  This function applies the appropriate pricing rules and discounts to each product
  in the basket and returns the total price.

  ## Parameters

    * `basket` - A list of product codes representing the items in the basket.

  ## Returns

    A `Decimal` representing the total price of the basket after applying all rules and discounts.

  ## Examples

      iex> SuperMarkex.Market.Cashier.calculate_total(["GR1", "SR1", "GR1", "GR1", "CF1"])
      Decimal.new("22.45")

  """
  @spec calculate_total([String.t()]) :: Decimal.t()
  def calculate_total(basket) do
    total =
      basket
      |> Enum.group_by(& &1)
      |> Enum.map(fn {product_code, items} ->
        quantity = length(items)
        subtotal = calculate_product_total(product_code, quantity)
        subtotal
      end)
      |> Enum.reduce(Decimal.new(0), &Decimal.add/2)
      |> Decimal.round(2)

    total
  end

  @doc false
  @spec calculate_product_total(String.t(), non_neg_integer()) :: Decimal.t()
  defp calculate_product_total(product_code, quantity) do
    with {:ok, %Product{} = product} <- ProductStore.get_product(product_code),
         {_, rule} <- find_rule(product_code) do
      total = apply_rule(rule, product, quantity)
      total
    else
      _ ->
        Decimal.new(0)
    end
  end

  @doc false
  @spec find_rule(String.t()) :: {String.t(), any()}
  defp find_rule(product_code) do
    Application.get_env(:kantox_live, :pricing_rules, [])
    |> Enum.find({product_code, :regular_price}, fn {code, _rule} ->
      code == product_code
    end)
  end

  @doc false
  @spec apply_rule(:buy_one_get_one_free, Product.t(), non_neg_integer()) :: Decimal.t()
  @spec apply_rule(
          {:bulk_discount, non_neg_integer(), Decimal.t()},
          Product.t(),
          non_neg_integer()
        ) :: Decimal.t()
  @spec apply_rule(
          {:bulk_discount_percentage, non_neg_integer(), Decimal.t()},
          Product.t(),
          non_neg_integer()
        ) :: Decimal.t()
  @spec apply_rule(:regular_price, Product.t(), non_neg_integer()) :: Decimal.t()
  @spec apply_rule(any(), Product.t(), non_neg_integer()) :: Decimal.t()
  defp apply_rule(:buy_one_get_one_free, %Product{price: price}, quantity) do
    Decimal.mult(price, Decimal.new(ceil(quantity / 2)))
  end

  @doc false
  defp apply_rule({:bulk_discount, min_quantity, discounted_price}, _product, quantity)
       when quantity >= min_quantity do
    Decimal.mult(discounted_price, Decimal.new(quantity))
  end

  @doc false
  defp apply_rule(
         {:bulk_discount_percentage, min_quantity, discount_factor},
         %Product{price: price},
         quantity
       )
       when quantity >= min_quantity do
    Decimal.mult(price, discount_factor)
    |> Decimal.mult(Decimal.new(quantity))
  end

  @doc false
  defp apply_rule(:regular_price, %Product{price: price}, quantity) do
    Decimal.mult(price, Decimal.new(quantity))
  end

  @doc false
  defp apply_rule(_, %Product{price: price}, quantity) do
    Decimal.mult(price, Decimal.new(quantity))
  end
end
