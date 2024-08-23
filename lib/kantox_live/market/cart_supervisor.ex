defmodule SuperMarkex.Market.CartSupervisor do
  @moduledoc """
  A dynamic supervisor for managing cart processes.

  This supervisor is responsible for starting and stopping individual cart processes,
  allowing for dynamic creation and termination of carts during runtime.

  The CartSupervisor is automatically started as part of the application's supervision tree,
  so there's no need to start it manually.
  """

  use DynamicSupervisor

  @doc """
  Starts the CartSupervisor.

  Note: This function is called automatically by the application supervisor.
  You don't need to call it manually in your application code.
  """
  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Starts a new cart process with the given cart_id.

  Returns `{:ok, pid}` if the cart is successfully started, or `{:error, reason}` if it fails.

  ## Examples

  Assuming the CartSupervisor is already started:

      iex> {:ok, pid} = SuperMarkex.Market.CartSupervisor.start_cart("new_cart")
      iex> is_pid(pid)
      true

  """
  def start_cart(cart_id) do
    DynamicSupervisor.start_child(__MODULE__, {SuperMarkex.Market.CartServer, cart_id})
  end

  @doc """
  Stops the cart process with the given cart_id.

  Returns `:ok` if the cart is successfully stopped, `{:error, :not_found}` if the cart doesn't exist,
  or `{:error, :not_terminated}` if the cart couldn't be terminated.

  ## Examples

  Assuming a cart has been started:

      iex> {:ok, _} = SuperMarkex.Market.CartSupervisor.start_cart("cart_to_stop")
      iex> SuperMarkex.Market.CartSupervisor.stop_cart("cart_to_stop")
      :ok
      iex> SuperMarkex.Market.CartSupervisor.stop_cart("nonexistent_cart")
      {:error, :not_found}

  """
  def stop_cart(cart_id) do
    case Registry.lookup(SuperMarkex.CartRegistry, cart_id) do
      [{pid, _}] ->
        case DynamicSupervisor.terminate_child(__MODULE__, pid) do
          :ok -> :ok
          {:error, :not_found} -> {:error, :not_terminated}
        end

      [] ->
        {:error, :not_found}
    end
  end
end

