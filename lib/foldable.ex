defprotocol Monex.Foldable do
  @moduledoc """
  The `Monex.Foldable` protocol defines two core folding operations: `fold_l/3` (fold left) and `fold_r/3` (fold right).

  These functions allow structures to be collapsed into a single value by applying functions in a specific order.
  Depending on the structure, folding can be done from the left (`fold_l/3`) or from the right (`fold_r/3`).
  """

  @doc """
  Folds the structure from the left, applying `func_a` if a condition is met, otherwise applying `func_b`.

  This function collapses a structure by recursively applying the provided functions from the leftmost element to the rightmost.

  ## Parameters:
  - `structure`: The structure to fold.
  - `func_a`: The function to apply in case of a matching condition.
  - `func_b`: The function to apply if the condition is not met.

  ## Examples

      iex> Monex.Foldable.fold_l(Monex.Maybe.just(5), fn x -> x + 1 end, fn -> 0 end)
      6

      iex> Monex.Foldable.fold_l(Monex.Maybe.nothing(), fn _ -> 1 end, fn -> 0 end)
      0
  """
  def fold_l(structure, func_a, func_b)

  @doc """
  Folds the structure from the right, applying `func_a` if a condition is met, otherwise applying `func_b`.

  This function collapses a structure by recursively applying the provided functions from the rightmost element to the leftmost.

  ## Parameters:
  - `structure`: The structure to fold.
  - `func_a`: The function to apply in case of a matching condition.
  - `func_b`: The function to apply if the condition is not met.

  ## Examples

      iex> Monex.Foldable.fold_r(Monex.Maybe.just(5), fn x -> x + 1 end, fn -> 0 end)
      6

      iex> Monex.Foldable.fold_r(Monex.Maybe.nothing(), fn _ -> 1 end, fn -> 0 end)
      0
  """
  def fold_r(structure, func_a, func_b)
end

defimpl Monex.Foldable, for: Function do
  @moduledoc """
  Provides an implementation of the `Monex.Foldable` protocol for functions (predicates).
  This implementation evaluates a predicate function and applies either `true_func` or `false_func` based on the result.

  Useful for folding over boolean predicates, collapsing them into a single result.
  """

  @doc """
  Folds a predicate function from the left.

  The predicate is evaluated, and if it returns `true`, the `true_func` is applied; otherwise, the `false_func` is applied.

  ## Examples

      iex> Monex.Foldable.fold_l(fn -> true end, fn -> "True case" end, fn -> "False case" end)
      "True case"

      iex> Monex.Foldable.fold_l(fn -> false end, fn -> "True case" end, fn -> "False case" end)
      "False case"
  """
  def fold_l(predicate, true_func, false_func) do
    case predicate.() do
      true -> true_func.()
      false -> false_func.()
    end
  end

  @doc """
  Folds a predicate function from the right.

  The predicate is evaluated, and if it returns `true`, the `true_func` is applied; otherwise, the `false_func` is applied.

  ## Examples

      iex> Monex.Foldable.fold_r(fn -> true end, fn -> "True case" end, fn -> "False case" end)
      "True case"

      iex> Monex.Foldable.fold_r(fn -> false end, fn -> "True case" end, fn -> "False case" end)
      "False case"
  """
  def fold_r(predicate, true_func, false_func) do
    case predicate.() do
      true -> true_func.()
      false -> false_func.()
    end
  end
end
