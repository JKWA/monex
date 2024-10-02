defmodule Examples.Person do
  alias Monex.Predicate

  defstruct name: "", height: 0, tickets: 0

  @type t :: %__MODULE__{
          name: String.t(),
          height: integer(),
          tickets: integer()
        }

  def new(name, height, tickets) do
    %__MODULE__{name: name, height: height, tickets: tickets}
  end

  @spec is_short(t()) :: boolean()
  def is_short(%__MODULE__{height: height}) do
    height < 150
  end

  @spec is_tall(t()) :: boolean()
  def is_tall(%__MODULE__{height: height}) do
    height > 200
  end

  @spec is_valid_height(t()) :: boolean()
  def is_valid_height(person) do
    valid_height_predicate =
      Predicate.p_and(Predicate.p_not(&is_short/1), Predicate.p_not(&is_tall/1))

    valid_height_predicate.(person)
  end

  @spec has_ticket(t()) :: boolean()
  def has_ticket(%__MODULE__{tickets: tickets}) do
    tickets > 0
  end

  @spec increment_ticket(t()) :: t()
  def increment_ticket(%__MODULE__{tickets: tickets} = person) do
    %{person | tickets: tickets + 1}
  end

  @spec decrement_ticket(t()) :: t()
  def decrement_ticket(%__MODULE__{tickets: tickets} = person) do
    %{person | tickets: tickets - 1}
  end
end
