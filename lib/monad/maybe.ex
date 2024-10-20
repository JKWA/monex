defmodule Monex.Maybe do
  import Monex.Monad, only: [bind: 2]
  import Monex.Foldable, only: [fold: 3]
  alias Monex.Maybe.{Just, Nothing}
  alias Monex.Either.{Right, Left}

  @type t(value) :: Just.t(value) | Nothing.t()

  def pure(value), do: Just.pure(value)

  def just(value), do: Just.pure(value)
  def nothing, do: Nothing.pure()

  def filter(maybe, predicate) do
    bind(maybe, fn value ->
      if predicate.(value) do
        pure(value)
      else
        nothing()
      end
    end)
  end

  def just?(%Just{}), do: true
  def just?(_), do: false

  def nothing?(%Nothing{}), do: true
  def nothing?(_), do: false

  def get_or_else(maybe, default) do
    fold(maybe, fn value -> value end, fn -> default end)
  end

  def get_eq(custom_eq) do
    %{
      equals?: fn
        %Just{value: v1}, %Just{value: v2} -> custom_eq.equals?.(v1, v2)
        %Nothing{}, %Nothing{} -> true
        _, _ -> false
      end
    }
  end

  def get_ord(custom_ord) do
    %{
      lt?: fn
        %Nothing{}, %Just{} -> true
        %Just{}, %Nothing{} -> false
        %Just{value: v1}, %Just{value: v2} -> custom_ord.lt?.(v1, v2)
        %Nothing{}, %Nothing{} -> false
      end,
      le?: fn a, b -> not get_ord(custom_ord).gt?.(a, b) end,
      gt?: fn a, b -> get_ord(custom_ord).lt?.(b, a) end,
      ge?: fn a, b -> not get_ord(custom_ord).lt?.(a, b) end
    }
  end

  def sequence([]), do: pure([])

  def sequence([head | tail]) do
    bind(head, fn value ->
      bind(sequence(tail), fn rest ->
        pure([value | rest])
      end)
    end)
  end

  def traverse(func, list) do
    list
    |> Enum.map(func)
    |> sequence()
  end

  def lift_either(either) do
    case either do
      %Right{value: value} -> Just.pure(value)
      %Left{} -> Nothing.pure()
    end
  end

  def lift_predicate(value, predicate) do
    Monex.Foldable.fold(
      fn -> predicate.(value) end,
      fn -> Just.pure(value) end,
      fn -> Nothing.pure() end
    )
  end

  @spec from_nil(nil | value) :: t(value)
        when value: term()
  def from_nil(nil), do: Nothing.pure()
  def from_nil(value), do: Just.pure(value)

  @spec to_nil(t(value)) :: nil | value
        when value: term()
  def to_nil(maybe) do
    fold(maybe, fn value -> value end, fn -> nil end)
  end

  @spec from_try((-> right)) :: t(right) when right: term()
  def from_try(func) do
    try do
      result = func.()
      Just.pure(result)
    rescue
      _exception ->
        Nothing.pure()
    end
  end

  @spec to_try!(t(right), String.t()) :: right | no_return when right: term()
  def to_try!(maybe, message \\ "Nothing value encountered") do
    case maybe do
      %Just{value: value} -> value
      %Nothing{} -> raise message
    end
  end

  @spec from_result({:ok, right} | {:error, term()}) :: t(right) when right: term()
  def from_result({:ok, value}), do: Just.pure(value)
  def from_result({:error, _reason}), do: Nothing.pure()

  @spec to_result(t(right)) :: {:ok, right} | {:error, :nothing} when right: term()
  def to_result(maybe) do
    case maybe do
      %Just{value: value} -> {:ok, value}
      %Nothing{} -> {:error, :nothing}
    end
  end
end
