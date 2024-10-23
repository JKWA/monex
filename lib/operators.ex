defmodule Monex.Operators do
  defmacro left ~> right do
    quote do
      Monex.Monad.map(unquote(left), unquote(right))
    end
  end

  defmacro left >>> right do
    quote do
      Monex.Monad.bind(unquote(left), unquote(right))
    end
  end

  defmacro left <<~ right do
    quote do
      Monex.Monad.ap(unquote(left), unquote(right))
    end
  end

  defmacro structure <<< {func_a, func_b} do
    quote do
      Monex.Foldable.fold_r(unquote(structure), unquote(func_a), unquote(func_b))
    end
  end
end
