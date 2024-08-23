defmodule SuperMarkex.Warehouse.ProductStore do
  @moduledoc """
  The ProductStore module manages the storage and retrieval of product information using ETS (Erlang Term Storage).
  It provides functionality to initialize the store from a CSV file, retrieve products, list all products, and reset the store.

  The module uses an ETS table named `:product_store` to store product information for fast in-memory access.
  """

  alias SuperMarkex.Warehouse.Product
  require Logger

  @ets_table_name :product_store
  @default_csv_file "products_matrix.csv"

  @doc """
  Initializes the product store.

  This function creates an ETS table (if it doesn't exist) and loads product data from a CSV file.

  ## Options

    * `:csv_file` - The name of the CSV file to load products from. Defaults to "products_matrix.csv".

  ## Returns

    * `:ok` if the initialization is successful.
    * `{:error, reason}` if there's an error during initialization.

  ## Examples

      iex> SuperMarkex.Warehouse.ProductStore.init()
      :ok

      iex> SuperMarkex.Warehouse.ProductStore.init(csv_file: "custom_products.csv")
      :ok
  """
  @spec init(keyword()) :: :ok | {:error, atom()}
  def init(opts \\ []) do
    csv_file = Keyword.get(opts, :csv_file, @default_csv_file)

    case :ets.info(@ets_table_name) do
      :undefined ->
        :ets.new(@ets_table_name, [:set, :public, :named_table, {:read_concurrency, true}])

      _ ->
        :ok
    end

    load_from_csv(csv_file)
  end

  @doc """
  Retrieves a product by its code.

  ## Parameters

    * `code` - The product code to look up.

  ## Returns

    * `{:ok, product}` if the product is found.
    * `{:error, :not_found}` if the product is not found.

  ## Examples

      iex> SuperMarkex.Warehouse.ProductStore.get_product("GR1")
      {:ok, %SuperMarkex.Warehouse.Product{code: "GR1", name: "Green Tea", price: Decimal.new("3.11")}}

      iex> SuperMarkex.Warehouse.ProductStore.get_product("NONEXISTENT")
      {:error, :not_found}
  """
  @spec get_product(String.t()) :: {:ok, Product.t()} | {:error, :not_found}
  def get_product(code) do
    case :ets.lookup(@ets_table_name, code) do
      [{^code, product}] -> {:ok, product}
      [] -> {:error, :not_found}
    end
  end

  @doc """
  Lists all products in the store.

  ## Returns

    A list of tuples, where each tuple contains a product code and its corresponding Product struct.

  ## Examples

      iex> SuperMarkex.Warehouse.ProductStore.list_all()
      [
        {"GR1", %SuperMarkex.Warehouse.Product{code: "GR1", name: "Green Tea", price: Decimal.new("3.11")}},
        {"SR1", %SuperMarkex.Warehouse.Product{code: "SR1", name: "Strawberries", price: Decimal.new("5.00")}}
      ]
  """
  @spec list_all() :: [{String.t(), Product.t()}]
  def list_all, do: :ets.tab2list(@ets_table_name)

  @doc """
  Resets the product store by removing all products.

  ## Returns

    * `:ok`

  ## Examples

      iex> SuperMarkex.Warehouse.ProductStore.reset()
      :ok
  """
  @spec reset() :: true
  def reset, do: :ets.delete_all_objects(@ets_table_name)

  @doc false
  defp load_from_csv(csv_file) do
    csv_path = Path.join(:code.priv_dir(:kantox_live), csv_file)
    Logger.info("Loading products from CSV: #{csv_path}")

    if File.exists?(csv_path) do
      try do
        csv_path
        |> File.stream!()
        |> CSV.decode!(headers: true)
        |> Enum.each(fn row ->
          case row do
            %{"Product code" => code, "Name" => name, "Price" => price} ->
              product = Product.new(code, name, price)
              :ets.insert(@ets_table_name, {code, product})

            _ ->
              Logger.warning("Skipping invalid row: #{inspect(row)}")
          end
        end)

        Logger.info("Products loaded successfully")
        :ok
      rescue
        e in CSV.RowLengthError ->
          Logger.error("CSV parsing error: #{Exception.message(e)}")
          {:error, :csv_parse_error}

        e ->
          Logger.error("Unexpected error while parsing CSV: #{Exception.message(e)}")
          {:error, :unexpected_error}
      end
    else
      Logger.error("CSV file not found: #{csv_path}")
      {:error, :csv_not_found}
    end
  end
end
