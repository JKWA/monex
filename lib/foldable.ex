defprotocol Monex.Foldable do
  # @spec fold(structure, (term() -> result), (term() -> result)) :: result when result: term()
  def fold(structure, func_a, func_b)
end

defimpl Monex.Foldable, for: Function do
  def fold(predicate, true_func, false_func) do
    case predicate.() do
      true -> true_func.()
      false -> false_func.()
    end
  end
end
