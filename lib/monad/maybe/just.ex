defmodule Monex.Maybe.Just do
  @enforce_keys [:value]
  defstruct [:value]

  @type t(value) :: %__MODULE__{value: value}

  @spec pure(value) :: Monex.Maybe.Just.t(value) when value: term()
  def pure(nil), do: raise(ArgumentError, "Cannot wrap nil in a Just")
  def pure(value), do: %__MODULE__{value: value}

  defimpl Monex.Monad do
    alias Monex.Maybe.{Just, Nothing}

    @spec ap(Just.t((value -> result)) | Nothing.t(), Just.t(value) | Nothing.t()) ::
            Just.t(result) | Nothing.t()
          when value: term(), result: term()
    def ap(%Just{value: func}, %Just{value: value}),
      do: Just.pure(func.(value))

    def ap(_, %Nothing{}), do: %Nothing{}

    @spec map(Just.t(value), (value -> result)) :: Just.t(result)
          when value: term(), result: term()
    def map(%Just{value: value}, func), do: Just.pure(func.(value))

    @spec bind(Just.t(value), (value -> Just.t(result))) :: Just.t(result)
          when value: term(), result: term()
    def bind(%Just{value: value}, func), do: func.(value)
  end

  defimpl String.Chars do
    alias Monex.Maybe.Just

    def to_string(%Just{value: value}), do: "Just(#{value})"
  end

  defimpl Monex.Foldable do
    alias Monex.Maybe.Just

    @spec fold_l(Just.t(value), (value -> result), (-> result)) :: result
          when value: term(), result: term()
    def fold_l(%Just{value: value}, just_func, _nothing_func) do
      just_func.(value)
    end

    @spec fold_r(Just.t(value), (value -> result), (-> result)) :: result
          when value: term(), result: term()
    def fold_r(%Just{value: value}, just_func, _nothing_func) do
      just_func.(value)
    end
  end

  defimpl Monex.Eq do
    alias Monex.Maybe.{Just, Nothing}

    def equals?(%Just{value: v1}, %Just{value: v2}) do
      v1 == v2
    end

    def equals?(%Just{}, %Nothing{}), do: false
  end

  defimpl Monex.Ord do
    alias Monex.Maybe.{Just, Nothing}

    def lt?(%Just{value: v1}, %Just{value: v2}) do
      v1 < v2
    end

    def lt?(%Just{}, %Nothing{}) do
      false
    end

    def le?(a, b), do: not Monex.Ord.gt?(a, b)
    def gt?(a, b), do: Monex.Ord.lt?(b, a)
    def ge?(a, b), do: not Monex.Ord.lt?(a, b)
  end
end
