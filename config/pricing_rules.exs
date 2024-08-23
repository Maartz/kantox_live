import Config

# Pricing Rules Configuration
#
# This configuration defines special pricing rules for specific products.
# Each rule is represented as a tuple: {product_code, rule_type}
# 
# Available rule types:
# 1. :buy_one_get_one_free
#    Format: {product_code, :buy_one_get_one_free}
#    Description: Customer gets two items for the price of one.
#
# 2. {:bulk_discount, min_quantity, discounted_price}
#    Format: {product_code, {:bulk_discount, min_quantity, discounted_price}}
#    Description: When buying min_quantity or more, each item costs discounted_price.
#    Note: discounted_price is a string representation of a decimal number.
#
# 3. {:bulk_discount_percentage, min_quantity, discount_factor}
#    Format: {product_code, {:bulk_discount_percentage, min_quantity, discount_factor}}
#    Description: When buying min_quantity or more, price is reduced by discount_factor.
#    Note: discount_factor is a string representation of a decimal number (e.g., "0.6667" for 33.33% discount).

config :kantox_live, :pricing_rules, [
  # Green Tea (GR1): Buy-One-Get-One-Free
  {"GR1", :buy_one_get_one_free},

  # Strawberries (SR1): £4.50 each when buying 3 or more
  {"SR1", {:bulk_discount, 3, "4.50"}},

  # Coffee (CF1): 2/3 of the original price when buying 3 or more
  {"CF1", {:bulk_discount_percentage, 3, "0.6667"}}
]

