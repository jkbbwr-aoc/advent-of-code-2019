defmodule Factory do
  use GenServer

  defstruct [:inventory, :inputs, :produced, :batch_size, disabled: false]

  def start_link(name, inventory, inputs, :disabled) do
    GenServer.start_link(
      __MODULE__,
      %Factory{
        batch_size: 0,
        produced: 0,
        inventory: inventory,
        inputs: inputs,
        disabled: true
      },
      name: name
    )
  end

  def start_link(name, batch_size, inputs) do
    GenServer.start_link(
      __MODULE__,
      %Factory{
        batch_size: batch_size,
        produced: 0,
        inventory: 0,
        inputs: inputs
      },
      name: name
    )
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  def state(name) do
    GenServer.call(name, :state, :infinity)
  end

  def request(name, amount) do
    GenServer.call(name, {:request, amount}, :infinity)
  end

  @impl true
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:request, amount}, _from, %Factory{inventory: count} = state) when amount <= count do
    {:reply, amount, %Factory{state | inventory: count - amount}}
  end

  @impl true
  def handle_call({:request, _amount}, _from, %Factory{disabled: true} = state) do
    {:reply, :stop, state}
  end

  @impl true
  def handle_call({:request, amount}, _from, state) do
    amount = amount - state.inventory
    state = %Factory{state | inventory: 0}

    batches = Kernel.trunc(:math.ceil(amount / state.batch_size))

    results =
      Enum.map(
        1..batches,
        fn _ ->
          Enum.map(
            state.inputs,
            fn {item, amount} ->
              Factory.request(item, amount)
            end
          )
        end
      )
      |> List.flatten()

    if Enum.any?(results, fn x -> x == :stop end) do
      {:reply, :stop, %Factory{state | disabled: true}}
    else
      {
        :reply,
        amount,
        %Factory{
          state
          | inventory: batches * state.batch_size - amount,
            produced: state.produced + batches * state.batch_size
        }
      }
    end
  end
end

defmodule Aoc14 do
  @match_components ~r/\d+ \w+/

  # This is a novel solution to part 1 where I actually simulate a factory

  def extract_inputs(line) do
    Regex.scan(@match_components, line)
    |> Enum.map(fn [x] ->
      {count, rest} = Integer.parse(x)
      {String.trim(rest), count}
    end)
  end

  def load_novel() do
    File.read!("input/14")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn x -> String.split(x, "=>") end)
    |> Enum.map(fn [input, output] ->
      {count, rest} = Integer.parse(String.trim(output))
      {{String.trim(rest), count}, extract_inputs(input)}
    end)
    |> Enum.reverse()
  end

  def load_novel(string) do
    string
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn x -> String.split(x, "=>") end)
    |> Enum.map(fn [input, output] ->
      {count, rest} = Integer.parse(String.trim(output))
      {{String.trim(rest), count}, extract_inputs(input)}
    end)
    |> Enum.reverse()
  end

  def build({name, count}) do
    case :ets.lookup(:resource, name) do
      [] -> {name, count, []}
      [{_, _, children}] -> {name, count, Enum.map(children, fn x -> build(x) end)}
    end
  end

  def score(string) do
    map =
      load_novel(string)
      |> Enum.into(%{})

    Enum.each(
      map,
      fn {{name, batch}, children} ->
        Factory.start_link(String.to_atom(name), batch, Enum.map(children, fn {x, y} -> {String.to_atom(x), y} end))
      end
    )

    Factory.request(:FUEL, 1)
  end

  def part1() do
    processes =
      load_novel()
      |> Enum.into(%{})
      |> Enum.map(fn {{name, batch}, children} ->
        Factory.start_link(
          String.to_atom(name),
          batch,
          Enum.map(children, fn {x, y} -> {String.to_atom(x), y} end)
        )
      end)

    {:ok, pid} = Factory.start_link(:ORE, 1, [])
    Factory.request(:FUEL, 1)
    result = Factory.state(:ORE).produced
    Process.exit(pid, :normal)
    Enum.each(processes, fn {:ok, pid} -> Process.exit(pid, :normal) end)
    result
  end

  def loop(:stop, 0) do
    Factory.state(:FUEL)
  end

  def loop(_, count) do
    loop(Factory.request(:FUEL, 1), count - 1)
  end

  # This is a serious solution for part two. As the novel solution is too slow.

  def part2() do
    cookbook =
      parse_input(
        File.read!("input/14")
        |> String.split("\n")
      )

    max = ores(1, cookbook) * 1_000_000_000_000
    binary_search(1, max, cookbook)
  end

  def binary_search(min, max, _cookbook) when min > max, do: max

  def binary_search(min, max, cookbook) do
    fuel = div(min + max, 2)
    ores_quantity = ores(fuel, cookbook)

    case ores_quantity <= 1_000_000_000_000 do
      true ->
        binary_search(fuel + 1, max, cookbook)

      false ->
        binary_search(min, fuel - 1, cookbook)
    end
  end

  def ores(fuel_quantity, cookbook) do
    {_store, ores} = produce([{"FUEL", fuel_quantity}], cookbook, %{}, 0)
    ores
  end

  def produce([{"ORE", need_quantity} | need], cookbook, store, ores) do
    produce(need, cookbook, store, ores + need_quantity)
  end

  def produce([{name, need_quantity} | need], cookbook, store, ores) do
    {store, need_quantity} = take_from_store(store, name, need_quantity)
    {prod_quantity, ingredients} = Map.fetch!(cookbook, name)
    prod_units = div(need_quantity + prod_quantity - 1, prod_quantity)
    ingredients = Enum.map(ingredients, fn {name, q} -> {name, q * prod_units} end)
    {store, ores} = produce(ingredients, cookbook, store, ores)
    actual_quantity = prod_units * prod_quantity
    store = update_store(store, name, actual_quantity - need_quantity)
    produce(need, cookbook, store, ores)
  end

  def produce([], _, store, ores), do: {store, ores}

  def take_from_store(store, name, quantity) do
    case store do
      %{^name => stored_quantity} ->
        taken = min(quantity, stored_quantity)
        {Map.put(store, name, stored_quantity - taken), quantity - taken}

      %{} ->
        {store, quantity}
    end
  end

  def update_store(store, name, quantity) do
    Map.update(store, name, quantity, &(&1 + quantity))
  end

  def parse_input(input) do
    input
    |> Enum.map(&split_line/1)
    |> Map.new()
  end

  def split_line(line) do
    [needed, produces] = String.split(line, " => ")
    needed = String.split(needed, ", ")
    needed = Enum.map(needed, &parse_component/1)
    {name, quantity} = parse_component(produces)
    {name, {quantity, needed}}
  end

  def parse_component(comp) do
    {int, " " <> name} = Integer.parse(comp)
    {name, int}
  end
end
