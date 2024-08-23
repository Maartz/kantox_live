defmodule SuperMarkexWeb.CartLive.Index do
  use SuperMarkexWeb, :live_view
  alias SuperMarkex.Market
  alias SuperMarkex.Warehouse

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, carts: %{}, products: Warehouse.list_products())}
  end

  @impl true
  def handle_event("create-cart", _params, socket) do
    {:ok, cart_id} = Market.create_cart()

    {:noreply,
     update(
       socket,
       :carts,
       &Map.put(&1, cart_id, %{items: %{}, total: Decimal.new(0) |> Decimal.to_string()})
     )}
  end

  @impl true
  def handle_event("delete-cart", %{"id" => cart_id}, socket) do
    Market.clear_cart(cart_id)
    {:noreply, update(socket, :carts, &Map.delete(&1, cart_id))}
  end

  @impl true
  def handle_event("add-item", %{"cart-id" => cart_id, "product-code" => product_code}, socket) do
    :ok = Market.add_to_cart(cart_id, product_code, 1)
    new_items = Market.get_cart_contents(cart_id)
    new_total = Market.calculate_cart_total(cart_id)

    {:noreply,
     update(socket, :carts, fn carts ->
       Map.update!(carts, cart_id, fn cart ->
         %{cart | items: new_items, total: new_total}
       end)
     end)}
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
        <%= for {cart_id, cart} <- @carts do %>
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
              <%= if Enum.empty?(cart.items) do %>
                <p class="text-gray-500 italic">Cart is empty</p>
              <% else %>
                <%= for {product_code, quantity} <- cart.items do %>
                  <div class="flex justify-between items-center py-2 border-b">
                    <span class="font-medium"><%= product_code %></span>
                    <span class="bg-gray-200 rounded-full px-3 py-1 text-sm"><%= quantity %></span>
                  </div>
                <% end %>
              <% end %>
            </div>
            <div class="cart-total text-right mb-4">
              <span class="font-bold">Total:</span>
              <span class="text-lg text-green-600 ml-2">
                <%= Decimal.round(cart.total, 2) |> Decimal.to_string() %>
              </span>
            </div>
            <div class="add-items">
              <h3 class="text-lg font-semibold mb-2">Add Items:</h3>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-2">
                <%= for {product_code, product} <- @products do %>
                  <button
                    phx-click="add-item"
                    phx-value-cart-id={cart_id}
                    phx-value-product-code={product_code}
                    class="bg-green-500 hover:bg-green-700 text-white font-bold py-2 px-3 rounded text-sm w-full truncate"
                  >
                    Add <%= product.name %>
                  </button>
                <% end %>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end

