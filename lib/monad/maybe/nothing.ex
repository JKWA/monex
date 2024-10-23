defmodule Monex.Maybe.Nothing do
  defstruct []

  @type t :: %__MODULE__{}

  def pure, do: %__MODULE__{}

  defimpl Monex.Monad, for: Monex.Maybe.Nothing do
    alias Monex.Maybe.Nothing

    @spec bind(Nothing.t(), (term() -> Nothing.t())) :: Nothing.t()
    def bind(%Nothing{}, _func), do: %Nothing{}

    @spec map(Nothing.t(), (term() -> term())) :: Nothing.t()
    def map(%Nothing{}, _func), do: %Nothing{}

    @spec ap(Nothing.t(), Nothing.t()) :: Nothing.t()
    def ap(%Nothing{}, _func), do: %Nothing{}
  end

  defimpl String.Chars do
    alias Monex.Maybe.Nothing
    def to_string(%Nothing{}), do: "Nothing"
  end

  defimpl Monex.Foldable do
    alias Monex.Maybe.Nothing

    def fold_l(%Nothing{}, _just_func, nothing_func) do
      nothing_func.()
    end

    def fold_r(%Nothing{}, _just_func, nothing_func) do
      nothing_func.()
    end
  end

  defimpl Monex.Eq do
    alias Monex.Maybe.{Nothing, Just}

    def equals?(%Nothing{}, %Nothing{}), do: true
    def equals?(%Nothing{}, %Just{}), do: false
  end

  defimpl Monex.Ord do
    alias Monex.Maybe.{Nothing, Just}

    def lt?(%Nothing{}, %Just{}), do: true
    def lt?(%Nothing{}, %Nothing{}), do: false

    def le?(a, b), do: not Monex.Ord.gt?(a, b)
    def gt?(a, b), do: Monex.Ord.lt?(b, a)
    def ge?(a, b), do: not Monex.Ord.lt?(a, b)
  end
end
