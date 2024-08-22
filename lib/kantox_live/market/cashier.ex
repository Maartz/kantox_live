defmodule SuperMarkex.Market.Cashier do
  alias SuperMarkex.Warehouse.{Product, ProductStore}
  require Logger

  # TODO: maybe worth extracting into some config injected at application start
  @rules [
    {"GR1", :buy_one_get_one_free},
    {"SR1", {:bulk_discount, 3, Decimal.new("4.50")}},
    {"CF1", {:bulk_discount_percentage, 3, Decimal.new("0.6667")}}
  ]

  def calculate_total(basket) do
    Logger.debug("Calculating total for basket: #{inspect(basket)}")

    total =
      basket
      |> Enum.group_by(& &1)
      |> Enum.map(fn {product_code, items} ->
        quantity = length(items)
        subtotal = calculate_product_total(product_code, quantity)
        Logger.debug("Subtotal for #{product_code} (quantity: #{quantity}): #{inspect(subtotal)}")
        subtotal
      end)
      |> Enum.reduce(Decimal.new(0), &Decimal.add/2)
      |> Decimal.round(2)

    Logger.debug("Total calculated: #{inspect(total)}")
    total
  end

  defp calculate_product_total(product_code, quantity) do
    Logger.debug("Calculating total for product: #{product_code}, quantity: #{quantity}")

    with {:ok, %Product{} = product} <- ProductStore.get_product(product_code),
         {_, rule} <- find_rule(product_code) do
      Logger.debug("Product found: #{inspect(product)}, Rule: #{inspect(rule)}")
      total = apply_rule(rule, product, quantity)
      Logger.debug("Total for #{product_code}: #{inspect(total)}")
      total
    else
      error ->
        Logger.error("Error calculating product total: #{inspect(error)}")
        Decimal.new(0)
    end
  end

  defp find_rule(product_code) do
    Enum.find(@rules, {product_code, :regular_price}, fn {code, _rule} -> code == product_code end)
  end

  defp apply_rule(:buy_one_get_one_free, %Product{price: price}, quantity) do
    Logger.debug(
      "Applying buy-one-get-one-free rule. Price: #{inspect(price)}, Quantity: #{quantity}"
    )

    total = Decimal.mult(price, Decimal.new(ceil(quantity / 2)))
    Logger.debug("Buy-one-get-one-free total: #{inspect(total)}")
    total
  end

  defp apply_rule({:bulk_discount, min_quantity, discounted_price}, _product, quantity)
       when quantity >= min_quantity do
    Logger.debug(
      "Applying bulk discount rule. Discounted price: #{inspect(discounted_price)}, Quantity: #{quantity}"
    )

    total = Decimal.mult(discounted_price, Decimal.new(quantity))
    Logger.debug("Bulk discount total: #{inspect(total)}")
    total
  end

  defp apply_rule(
         {:bulk_discount_percentage, min_quantity, discount_factor},
         %Product{price: price},
         quantity
       )
       when quantity >= min_quantity do
    Logger.debug(
      "Applying bulk discount percentage rule. Price: #{inspect(price)}, Discount factor: #{inspect(discount_factor)}, Quantity: #{quantity}"
    )

    discounted_price = Decimal.mult(price, discount_factor)
    total = Decimal.mult(discounted_price, Decimal.new(quantity))
    Logger.debug("Bulk discount percentage total: #{inspect(total)}")
    total
  end

  defp apply_rule(:regular_price, %Product{price: price}, quantity) do
    Logger.debug("Applying regular price rule. Price: #{inspect(price)}, Quantity: #{quantity}")
    total = Decimal.mult(price, Decimal.new(quantity))
    Logger.debug("Regular price total: #{inspect(total)}")
    total
  end

  defp apply_rule(_, %Product{price: price}, quantity) do
    Logger.debug("Applying default rule. Price: #{inspect(price)}, Quantity: #{quantity}")
    total = Decimal.mult(price, Decimal.new(quantity))
    Logger.debug("Default rule total: #{inspect(total)}")
    total
  end
end
