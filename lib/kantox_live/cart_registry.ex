defmodule SuperMarkex.CartRegistry do
  @moduledoc """
  Wrapper around Registry for cart management.
  """

  def child_spec(_opts) do
    Registry.child_spec(
      keys: :unique,
      name: __MODULE__
    )
  end

  def start_link, do: Registry.start_link(keys: :unique, name: __MODULE__)

  def via_tuple(cart_id), do: {:via, Registry, {__MODULE__, cart_id}}

  def list_carts, do: Registry.select(__MODULE__, [{{:"$1", :"$2", :_}, [], [{{:"$1", :"$2"}}]}])
end
