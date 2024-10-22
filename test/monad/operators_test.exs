defmodule Monex.OperatorsTest do
  use ExUnit.Case, async: true
  import Monex.Operators

  import Monex.Maybe

  alias Monex.Maybe.{Just, Nothing}

  describe "Functor map operator (~>)" do
    test "maps a function over a Just monad" do
      assert %Just{value: 43} ==
               just(42)
               ~> fn x -> x + 1 end
    end

    test "returns Nothing when mapping over a Nothing monad" do
      assert %Nothing{} ==
               nothing()
               ~> fn x -> x + 1 end
    end
  end

  describe "Monad bind operator (>>> )" do
    test "binds a function returning a monad over a Just monad" do
      assert %Just{value: 21} ==
               just(42) >>>
                 fn x -> just(div(x, 2)) end
    end

    test "returns Nothing when binding over a Nothing monad" do
      assert %Nothing{} ==
               nothing() >>>
                 fn _ -> just(10) end
    end

    test "returns Nothing when the function returns Nothing" do
      assert %Nothing{} ==
               just(42) >>>
                 fn _ -> nothing() end
    end
  end

  describe "Applicative apply operator (<<~)" do
    test "applies a function in Just to a value in Just" do
      assert just(43) ==
               just(fn x -> x + 1 end)
               <<~ just(42)
    end

    test "returns Nothing if the function is in Nothing" do
      assert nothing() ==
               nothing()
               <<~ just(42)
    end

    test "returns Nothing if the value is in Nothing" do
      assert nothing() ==
               just(fn x -> x + 1 end)
               <<~ nothing()
    end

    test "returns Nothing if both are Nothing" do
      assert nothing() ==
               nothing()
               <<~ nothing()
    end
  end
end
