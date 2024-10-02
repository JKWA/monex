defmodule Monex.Either.Right do
  @enforce_keys [:value]
  defstruct [:value]

  @type t(value) :: %__MODULE__{value: value}

  def pure(value), do: %__MODULE__{value: value}

  defimpl Monex.Monad do
    alias Monex.Either.{Left, Right}

    @spec ap(Right.t((value -> result)), Right.t(value)) :: Right.t(result)
          when value: term(), result: term()
    def ap(%Right{value: func}, %Right{value: value}), do: Right.pure(func.(value))

    @spec ap(term(), Left.t(value)) :: Left.t(value)
          when value: term()
    def ap(_, %Left{} = left), do: left

    @spec bind(Right.t(value), (value -> Right.t(result))) :: Right.t(result)
          when value: term(), result: term()
    def bind(%Right{value: value}, func), do: func.(value)

    @spec map(Right.t(value), (value -> result)) :: Right.t(result)
          when value: term(), result: term()
    def map(%Right{value: value}, func), do: Right.pure(func.(value))
  end

  defimpl String.Chars do
    alias Monex.Either.{Right}

    def to_string(%Right{value: value}), do: "Right(#{value})"
  end

  defimpl Monex.Foldable do
    alias Monex.Either.{Right}

    def fold(%Right{value: value}, right_func, _left_func) do
      right_func.(value)
    end
  end

  defimpl Monex.Eq do
    alias Monex.Either.{Left, Right}
    def equals?(%Right{value: v1}, %Right{value: v2}), do: v1 == v2
    def equals?(%Right{}, %Left{}), do: false
  end

  defimpl Monex.Ord do
    alias Monex.Either.{Left, Right}
    def lt?(%Right{value: v1}, %Right{value: v2}), do: v1 < v2
    def lt?(%Right{}, %Left{}), do: false
    def le?(a, b), do: not Monex.Ord.gt?(a, b)
    def gt?(a, b), do: Monex.Ord.lt?(b, a)
    def ge?(a, b), do: not Monex.Ord.lt?(a, b)
  end
end
