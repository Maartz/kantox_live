defmodule SuperMarkex.CashierTest do
  use ExUnit.Case, async: true
  alias SuperMarkex.Market.Cashier

  describe "calculate_total/1" do
    test "calculates total price for basket: GR1,SR1,GR1,GR1,CF1" do
      basket = ["GR1", "SR1", "GR1", "GR1", "CF1"]
      assert Cashier.calculate_total(basket) == Decimal.new("22.45")
    end

    test "calculates total price for basket: GR1,GR1" do
      basket = ["GR1", "GR1"]
      assert Cashier.calculate_total(basket) == Decimal.new("3.11")
    end

    test "calculates total price for basket: SR1,SR1,GR1,SR1" do
      basket = ["SR1", "SR1", "GR1", "SR1"]
      assert Cashier.calculate_total(basket) == Decimal.new("16.61")
    end

    test "calculates total price for basket: GR1,CF1,SR1,CF1,CF1" do
      basket = ["GR1", "CF1", "SR1", "CF1", "CF1"]
      assert Cashier.calculate_total(basket) == Decimal.new("30.57")
    end
  end
end
