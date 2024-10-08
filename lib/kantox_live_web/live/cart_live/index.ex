defmodule SuperMarkexWeb.CartLive.Index do
  use SuperMarkexWeb, :live_view
  alias SuperMarkex.Market
  alias SuperMarkex.Warehouse

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, cart_ids: [], carts: %{}, products: Warehouse.list_products())}
  end

  @impl true
  def handle_event("create-cart", _params, socket) do
    {:ok, cart_id} = Market.create_cart()
    new_cart = %{items: %{}, total: Decimal.new(0)}

    socket =
      socket
      |> update(:cart_ids, fn ids -> ids ++ [cart_id] end)
      |> update(:carts, &Map.put(&1, cart_id, new_cart))

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete-cart", %{"id" => cart_id}, socket) do
    Market.clear_cart(cart_id)

    socket =
      socket
      |> update(:cart_ids, &List.delete(&1, cart_id))
      |> update(:carts, &Map.delete(&1, cart_id))

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "adjust-quantity",
        %{"cart-id" => cart_id, "product-code" => product_code, "action" => action},
        socket
      ) do
    case action do
      "increase" -> Market.add_to_cart(cart_id, product_code, 1)
      "decrease" -> Market.remove_from_cart(cart_id, product_code, 1)
    end

    new_items = Market.get_cart_contents(cart_id)
    new_total = Market.calculate_cart_total(cart_id)

    socket =
      update(socket, :carts, fn carts ->
        Map.update!(carts, cart_id, fn cart ->
          %{cart | items: new_items, total: new_total}
        end)
      end)

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-[95%] mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold mb-6">Shopping Carts</h1>
      <button
        phx-click="create-cart"
        class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded mb-6"
      >
        Create New Cart
      </button>
      <div class="grid grid-cols-1 lg:grid-cols-2 2xl:grid-cols-3 gap-6">
        <%= for cart_id <- @cart_ids do %>
          <% cart = @carts[cart_id] %>
          <div class="cart bg-white shadow-lg rounded-lg p-6">
            <div class="flex justify-between items-center mb-4">
              <h2 class="text-xl font-semibold">Cart <%= cart_id %></h2>
              <button
                phx-click="delete-cart"
                phx-value-id={cart_id}
                class="text-red-500 hover:text-red-700"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-6 w-6"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                  />
                </svg>
              </button>
            </div>
            <div class="cart-items mb-4 space-y-2">
              <%= for {product_code, product} <- @products do %>
                <% quantity = Map.get(cart.items, product_code, 0) %>
                <div class="flex justify-between items-center py-2 border-b">
                  <span class="font-medium"><%= product.name %></span>
                  <div class="flex items-center">
                    <button
                      phx-click="adjust-quantity"
                      phx-value-cart-id={cart_id}
                      phx-value-product-code={product_code}
                      phx-value-action="decrease"
                      class="bg-red-500 hover:bg-red-700 text-white font-bold py-1 px-2 rounded-l"
                    >
                      -
                    </button>
                    <span class="bg-gray-200 px-3 py-1"><%= quantity %></span>
                    <button
                      phx-click="adjust-quantity"
                      phx-value-cart-id={cart_id}
                      phx-value-product-code={product_code}
                      phx-value-action="increase"
                      class="bg-green-500 hover:bg-green-700 text-white font-bold py-1 px-2 rounded-r"
                    >
                      +
                    </button>
                  </div>
                </div>
              <% end %>
            </div>
            <div class="cart-total text-right mb-4">
              <span class="font-bold">Total:</span>
              <span class="text-lg text-green-600 ml-2">
                £<%= Decimal.round(cart.total, 2) |> Decimal.to_string() %>
              </span>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
