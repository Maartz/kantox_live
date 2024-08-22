defmodule SuperMarkex.Market.Cart do
  @type t :: %__MODULE__{
          id: String.t(),
          items: %{String.t() => non_neg_integer()}
        }

  @callback add_item(pid(), String.t(), non_neg_integer()) :: :ok | {:error, String.t()}
  @callback remove_item(pid(), String.t(), non_neg_integer()) :: :ok | {:error, String.t()}
  @callback get_items(pid()) :: %{String.t() => non_neg_integer()}
  @callback clear(pid()) :: :ok

  defstruct [:id, items: %{}]
end

