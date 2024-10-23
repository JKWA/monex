defmodule Monex.OperatorsTest do
  use ExUnit.Case, async: true
  import Monex.Operators

  import Monex.Maybe

  def add_one(x), do: x + 1

  describe "Functor map operator (~>)" do
    test "maps a function over a Just monad" do
      assert just(43) == just(42) ~> (&add_one/1)
    end

    test "returns Nothing when mapping over a Nothing monad" do
      assert nothing() == nothing() ~> (&add_one/1)
    end
  end

  def just_add_one(x), do: just(add_one(x))
  def return_nothing(_), do: nothing()

  describe "Monad bind operator (>>> )" do
    test "binds a function returning a monad over a Just monad" do
      assert just(43) == just(42) >>> (&just_add_one/1)
    end

    test "returns Nothing when binding over a Nothing monad" do
      assert nothing() == nothing() >>> (&just_add_one/1)
    end

    test "returns Nothing when the function returns Nothing" do
      assert nothing() == just(42) >>> (&return_nothing/1)
    end
  end

  describe "Applicative apply operator (<<~)" do
    test "applies a function in Just to a value in Just" do
      assert just(43) == just(&add_one/1) <<~ just(42)
    end

    test "returns Nothing if the function is in Nothing" do
      assert nothing() == nothing() <<~ just(42)
    end

    test "returns Nothing if the value is in Nothing" do
      assert nothing() == just(&add_one/1) <<~ nothing()
    end

    test "returns Nothing if both are Nothing" do
      assert nothing() == nothing() <<~ nothing()
    end
  end

  defp just_func(x), do: "Just #{x}"
  defp nothing_func(), do: "Nothing"

  describe "Fold operator (<<<)" do
    test "folds over Just" do
      assert just(42) <<< {&just_func/1, &nothing_func/0} == "Just 42"
    end

    test "folds over Nothing" do
      assert nothing() <<< {&just_func/1, &nothing_func/0} == "Nothing"
    end
  end
end
