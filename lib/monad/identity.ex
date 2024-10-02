defmodule Monex.Identity do
  @enforce_keys [:value]
  defstruct [:value]

  @type t(value) :: %__MODULE__{value: value}

  def pure(value), do: %__MODULE__{value: value}

  def extract(%__MODULE__{value: value}), do: value

  def get_eq(custom_eq) do
    %{
      equals?: fn
        %__MODULE__{value: v1}, %__MODULE__{value: v2} -> custom_eq.equals?.(v1, v2)
        _, _ -> false
      end
    }
  end

  def get_ord(custom_ord) do
    %{
      lt?: fn
        %__MODULE__{value: v1}, %__MODULE__{value: v2} -> custom_ord.lt?.(v1, v2)
      end,
      le?: fn a, b -> not get_ord(custom_ord).gt?.(a, b) end,
      gt?: fn a, b -> get_ord(custom_ord).lt?.(b, a) end,
      ge?: fn a, b -> not get_ord(custom_ord).lt?.(a, b) end
    }
  end

  defimpl Monex.Monad do
    alias Monex.Identity

    def bind(%Identity{value: value}, func), do: func.(value)

    def map(%Identity{value: value}, func), do: Identity.pure(func.(value))

    def ap(%Identity{value: func}, %Identity{value: value}), do: Identity.pure(func.(value))
  end

  defimpl String.Chars do
    alias Monex.Identity

    def to_string(%Identity{value: value}), do: "Identity(#{value})"
  end

  defimpl Monex.Eq do
    alias Monex.Identity

    def equals?(%Identity{value: v1}, %Identity{value: v2}) do
      v1 == v2
    end
  end

  defimpl Monex.Ord do
    alias Monex.Identity

    def lt?(%Identity{value: v1}, %Identity{value: v2}) do
      v1 < v2
    end

    def le?(a, b), do: not Monex.Ord.gt?(a, b)
    def gt?(a, b), do: Monex.Ord.lt?(b, a)
    def ge?(a, b), do: not Monex.Ord.lt?(a, b)
  end
end
