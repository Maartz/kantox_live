defmodule SuperMarkex.ProductStore do
  require Logger

  @ets_table_name :product_store
  @default_csv_file "products_matrix.csv"

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

  def get_product(code) do
    case :ets.lookup(@ets_table_name, code) do
      [{^code, name, price}] -> {:ok, %{code: code, name: name, price: price}}
      [] -> {:error, :not_found}
    end
  end

  def reset do
    :ets.delete_all_objects(@ets_table_name)
  end

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
              :ets.insert(@ets_table_name, {code, name, Decimal.new(price)})

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

