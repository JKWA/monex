defprotocol Monex.Eq do
  @moduledoc """
  The `Monex.Eq` protocol defines an equality function, `equals?/2`, for comparing two values.

  Types that implement this protocol can define custom equality logic for comparing instances of their type.

  ## Fallback
  The protocol uses `@fallback_to_any true`, meaning that if a specific type does not implement `Monex.Eq`,
  it falls back to the default implementation for `Any`, which uses Elixir's built-in equality operator (`==`).
  """

  @fallback_to_any true

  @doc """
  Returns `true` if `a` is equal to `b`, otherwise returns `false`.

  ## Examples

      iex> Monex.Eq.equals?(Monex.Maybe.just(3), Monex.Maybe.just(3))
      true

      iex> Monex.Eq.equals?(Monex.Maybe.just(3), Monex.Maybe.just(5))
      false

      iex> Monex.Eq.equals?(Monex.Maybe.nothing(), Monex.Maybe.nothing())
      true

      iex> Monex.Eq.equals?(Monex.Maybe.nothing(), Monex.Maybe.just(5))
      false
  """
  def equals?(a, b)
end

defimpl Monex.Eq, for: Any do
  @moduledoc """
  Provides a default implementation of the `Monex.Eq` protocol for all types that fall back to the `Any` type.

  This implementation uses Elixir's built-in equality operator (`==`) to compare values.
  """

  @doc """
  Returns `true` if `a` is equal to `b`, otherwise returns `false`.

  Uses Elixir's `==` operator for comparison.

  ## Examples

      iex> Monex.Eq.equals?(Monex.Maybe.just(3), Monex.Maybe.just(3))
      true

      iex> Monex.Eq.equals?(Monex.Maybe.just(3), Monex.Maybe.just(5))
      false

      iex> Monex.Eq.equals?(Monex.Maybe.nothing(), Monex.Maybe.nothing())
      true
  """
  def equals?(a, b), do: a == b
end
