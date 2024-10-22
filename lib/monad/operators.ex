defmodule Monex.Operators do
  # Map: ~> (Functor map)
  defmacro left ~> right do
    quote do
      Monex.Monad.map(unquote(left), unquote(right))
    end
  end

  # Bind: >>> (Monad bind)
  defmacro left >>> right do
    quote do
      Monex.Monad.bind(unquote(left), unquote(right))
    end
  end

  # Apply: <<~ (Applicative apply)
  defmacro left <<~ right do
    quote do
      Monex.Monad.ap(unquote(left), unquote(right))
    end
  end
end
