defmodule Monex.Either do
  import Monex.Monad, only: [bind: 2]
  import Monex.Foldable, only: [fold: 3]
  alias Monex.Either.{Left, Right}

  @type t(left, right) :: Left.t(left) | Right.t(right)

  def right(value), do: Right.pure(value)
  def pure(value), do: Right.pure(value)

  def left(value), do: Left.pure(value)

  def either?(%Left{}), do: true
  def either?(%Right{}), do: true

  def left?(%Left{}), do: true
  def left?(_), do: false

  def right?(%Right{}), do: true
  def right?(_), do: false

  def filter_or_else(either, predicate, error_func) do
    fold(
      either,
      fn value ->
        if predicate.(value) do
          either
        else
          Left.pure(error_func.())
        end
      end,
      fn _left_value -> either end
    )
  end

  def get_or_else(either, default) do
    fold(
      either,
      fn value -> value end,
      fn _left_value -> default end
    )
  end

  def get_eq(custom_eq) do
    %{
      equals?: fn
        %Right{value: v1}, %Right{value: v2} -> custom_eq.equals?.(v1, v2)
        %Left{}, %Right{} -> false
        %Right{}, %Left{} -> false
        %Left{value: v1}, %Left{value: v2} -> v1 == v2
      end
    }
  end

  def get_ord(custom_ord) do
    %{
      lt?: fn
        %Left{}, %Right{} -> true
        %Right{}, %Left{} -> false
        %Right{value: v1}, %Right{value: v2} -> custom_ord.lt?.(v1, v2)
        %Left{}, %Left{} -> false
      end,
      le?: fn a, b -> not get_ord(custom_ord).gt?.(a, b) end,
      gt?: fn
        %Right{}, %Left{} -> true
        %Left{}, %Right{} -> false
        %Right{value: v1}, %Right{value: v2} -> custom_ord.lt?.(v2, v1)
        %Left{}, %Left{} -> false
      end,
      ge?: fn a, b -> not get_ord(custom_ord).lt?.(a, b) end
    }
  end

  def sequence([]), do: right([])

  def sequence([head | tail]) do
    bind(head, fn value ->
      bind(sequence(tail), fn rest ->
        right([value | rest])
      end)
    end)
  end

  def traverse(func, list) do
    list
    |> Enum.map(func)
    |> sequence()
  end

  def lift_option(maybe, on_none) do
    maybe
    |> fold(
      fn value -> Right.pure(value) end,
      fn -> Left.pure(on_none.()) end
    )
  end

  def lift_predicate(value, predicate, on_false) do
    fold(
      fn -> predicate.(value) end,
      fn -> Monex.Either.Right.pure(value) end,
      fn -> Monex.Either.Left.pure(on_false.()) end
    )
  end
end
