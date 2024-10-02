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
end
