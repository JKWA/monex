defmodule LazyTaskTest do
  use ExUnit.Case, async: true
  alias LazyTask
  import Monex.Monad, only: [map: 2, bind: 2, ap: 2]

  describe "pure/1" do
    test "creates a LazyTask with a value" do
      lazy = LazyTask.pure(42)
      assert LazyTask.run(lazy) == 42
    end
  end

  describe "ap/2" do
    test "applies a lazy function to a lazy value" do
      lazy_func = LazyTask.pure(&(&1 + 1))
      lazy_value = LazyTask.pure(41)

      result =
        lazy_func |> ap(lazy_value) |> LazyTask.run()

      assert result == 42
    end
  end

  describe "bind/2" do
    test "chains lazy tasks together" do
      lazy = LazyTask.pure(42)

      result =
        lazy
        |> bind(fn x -> LazyTask.pure(x * 2) end)
        |> LazyTask.run()

      assert result == 84
    end
  end

  describe "map/2" do
    test "maps over a lazy task" do
      lazy = LazyTask.pure(42)
      result = lazy |> map(&(&1 + 1)) |> LazyTask.run()
      assert result == 43
    end
  end
end
