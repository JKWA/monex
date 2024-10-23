defprotocol Monex.Foldable do
  # @spec fold_r(structure, (term() -> result), (term() -> result)) :: result when result: term()
  def fold_l(structure, func_a, func_b)
  def fold_r(structure, func_a, func_b)
end

defimpl Monex.Foldable, for: Function do
  def fold_l(predicate, true_func, false_func) do
    case predicate.() do
      true -> true_func.()
      false -> false_func.()
    end
  end

  def fold_r(predicate, true_func, false_func) do
    case predicate.() do
      true -> true_func.()
      false -> false_func.()
    end
  end
end
