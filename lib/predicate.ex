defmodule Monex.Predicate do
  defstruct predicate: nil

  def p_and(pred1, pred2) do
    fn value -> pred1.(value) and pred2.(value) end
  end

  def p_or(pred1, pred2) do
    fn value -> pred1.(value) or pred2.(value) end
  end

  def p_not(pred) do
    fn value -> not pred.(value) end
  end
end
