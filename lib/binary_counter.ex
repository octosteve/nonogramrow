defmodule BinaryCounter do
  defstruct sets: [], processed: []

  defmodule ContiguousSet do
    defstruct positive_bits: []

    def new() do
      %__MODULE__{}
    end

    def add_bit(%__MODULE__{} = struct) do
      update_in(struct.positive_bits, &prepend/1)
    end

    def to_integer(%__MODULE__{positive_bits: positive_bits}) do
      positive_bits |> Enum.sum()
    end

    defp prepend(list) do
      [1 | list]
    end
  end

  def new_set(%__MODULE__{} = struct) do
    update_in(struct.sets, &[ContiguousSet.new() |> ContiguousSet.add_bit() | &1])
  end

  def add_to_set(%__MODULE__{} = struct) do
    update_in(struct.sets, &increment_set/1)
  end

  defp increment_set([newest | rest]) do
    [ContiguousSet.add_bit(newest) | rest]
  end

  def new, do: %__MODULE__{}

  def nonogramrow(list \\ []) do
    list
    |> Enum.reduce(new(), fn bit, struct ->
      last_element = List.first(struct.processed)

      struct =
        case({last_element, bit}) do
          {off, 1} when off in [nil, 0] ->
            struct |> new_set

          {1, 1} ->
            struct |> add_to_set

          _ ->
            struct
        end

      update_in(struct.processed, &[bit | &1])
    end)
    |> to_list
  end

  def to_list(%__MODULE__{sets: []}) do
    []
  end

  def to_list(%__MODULE__{sets: sets}) do
    for set <- sets do
      ContiguousSet.to_integer(set)
    end
    |> Enum.reverse()
  end
end
