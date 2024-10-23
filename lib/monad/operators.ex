defmodule Monex.Operators do
  defmacro left <<~ right do
    quote do
      Monex.Monad.ap(unquote(left), unquote(right))
    end
  end

  defmacro left ~>> right do
    quote do
      Monex.Monad.bind(unquote(left), unquote(right))
    end
  end

  defmacro left ~> right do
    quote do
      Monex.Monad.map(unquote(left), unquote(right))
    end
  end
end
