defmodule SuperMarkex.ProductStore do
  use GenServer
  require Logger

  @ets_table_name __MODULE__.ETS
  @dets_table_name __MODULE__.DETS
  @csv_file "products_matrix.csv"
  @dets_file "products_store.dets"

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def get_product(code) do
    case :ets.lookup(@ets_table_name, code) do
      [{^code, name, price}] -> {:ok, %{code: code, name: name, price: price}}
      [] -> {:error, :not_found}
    end
  end

  @impl true
  def init(_) do
    Logger.info("Initializing ProductStore")

    :ets.new(
      @ets_table_name,
      [:set, :protected, :named_table, {:read_concurrency, true}]
    )

    Logger.info("ETS table created: #{inspect(@ets_table_name)}")

    case hydrate_ets() do
      :ok -> {:ok, nil}
      {:error, reason} -> {:stop, reason}
    end
  end

  defp hydrate_ets do
    case load_from_dets() do
      {:ok, _} ->
        Logger.info("Data loaded from DETS")
        :ok

      {:error, _} ->
        Logger.warning("Failed to load from DETS, attempting to load from CSV")

        case load_from_csv() do
          :ok ->
            save_to_dets()

          {:error, reason} ->
            Logger.error("Failed to load data: #{inspect(reason)}")
            {:error, reason}
        end
    end
  end

  defp load_from_dets do
    dets_file = Path.join(:code.priv_dir(:kantox_live), @dets_file)
    Logger.info("Attempting to open DETS file: #{inspect(dets_file)}")

    case :dets.open_file(@dets_table_name, [{:file, String.to_charlist(dets_file)}, {:type, :set}]) do
      {:ok, @dets_table_name} ->
        Logger.info("DETS file opened successfully")
        :dets.to_ets(@dets_table_name, @ets_table_name)
        {:ok, :loaded_from_dets}

      {:error, reason} ->
        Logger.warning("Failed to open DETS file: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp load_from_csv do
    csv_path = Path.join(:code.priv_dir(:kantox_live), @csv_file)
    Logger.info("Attempting to load CSV file: #{inspect(csv_path)}")

    if File.exists?(csv_path) do
      csv_path
      |> File.stream!()
      |> CSV.decode!(headers: true)
      |> Enum.each(fn %{"Product code" => code, "Name" => name, "Price" => price} ->
        :ets.insert(@ets_table_name, {code, name, Decimal.new(price)})
      end)

      Logger.info("CSV file loaded successfully")
      :ok
    else
      Logger.error("CSV file not found: #{csv_path}")
      {:error, :csv_not_found}
    end
  end

  defp save_to_dets do
    Logger.info("Saving data to DETS")
    :ets.to_dets(@ets_table_name, @dets_table_name)
    Logger.info("Data saved to DETS successfully")
    :ok
  end

  @impl true
  def terminate(_reason, _state) do
    Logger.info("Terminating ProductStore")
    :dets.close(@dets_table_name)
  end
end

