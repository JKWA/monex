defmodule Monex.Either.Left do
  @enforce_keys [:value]
  defstruct [:value]

  @type t(value) :: %__MODULE__{value: value}

  def pure(value), do: %__MODULE__{value: value}

  defimpl Monex.Monad do
    alias Monex.Either.Left

    @spec ap(Left.t(value), Left.t(value)) :: Left.t(value)
          when value: term()
    def ap(%Left{} = left, _), do: left

    @spec ap(Left.t(value), term()) :: Left.t(value)
          when value: term()
    def ap(_, %Left{} = left), do: left

    @spec bind(Left.t(value), (term() -> Left.t(result))) :: Left.t(value)
          when value: term(), result: term()
    def bind(%Left{} = left, _func), do: left

    @spec map(Left.t(value), (term() -> term())) :: Left.t(value)
          when value: term()
    def map(%Left{} = left, _func), do: left
  end

  defimpl String.Chars do
    alias Monex.Either.{Left}

    def to_string(%Left{value: value}), do: "Left(#{value})"
  end

  defimpl Monex.Foldable do
    alias Monex.Either.Left

    def fold(%Left{value: value}, _right_func, left_func) do
      left_func.(value)
    end
  end

  defimpl Monex.Eq do
    alias Monex.Either.{Left, Right}
    def equals?(%Left{value: v1}, %Left{value: v2}), do: v1 == v2
    def equals?(%Left{}, %Right{}), do: false
  end

  defimpl Monex.Ord do
    alias Monex.Either.{Left, Right}
    def lt?(%Left{value: v1}, %Left{value: v2}), do: v1 < v2
    def lt?(%Left{}, %Right{}), do: true
    def le?(a, b), do: not Monex.Ord.gt?(a, b)
    def gt?(a, b), do: Monex.Ord.lt?(b, a)
    def ge?(a, b), do: not Monex.Ord.lt?(a, b)
  end
end
