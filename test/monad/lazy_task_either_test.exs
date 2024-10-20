defmodule LazyTaskEitherTest do
  use ExUnit.Case
  alias LazyTaskEither
  alias Monex.{Either, Maybe}

  import Monex.Monad, only: [ap: 2, bind: 2, map: 2]
  import Monex.Foldable, only: [fold: 3]

  describe "ap/2" do
    test "ap applies a function inside a Right monad to a value inside another Right monad" do
      func = LazyTaskEither.right(fn x -> x * 2 end)
      value = LazyTaskEither.right(10)

      result =
        func
        |> ap(value)
        |> LazyTaskEither.run()

      assert result == Either.right(20)
    end

    test "ap returns Left if the function is inside a Left monad" do
      func = LazyTaskEither.left("error")
      value = LazyTaskEither.right(10)

      result =
        func
        |> ap(value)
        |> LazyTaskEither.run()

      assert result == Either.left("error")
    end

    test "ap returns Left if the value is inside a Left monad" do
      func = LazyTaskEither.right(fn x -> x * 2 end)
      value = LazyTaskEither.left("error")

      result =
        func
        |> ap(value)
        |> LazyTaskEither.run()

      assert result == Either.left("error")
    end
  end

  describe "bind/2" do
    test "bind applies a function returning a Right monad to the value inside a Right monad" do
      result =
        LazyTaskEither.right(10)
        |> bind(fn value -> LazyTaskEither.right(value + 5) end)
        |> LazyTaskEither.run()

      assert result == Either.right(15)
    end

    test "bind returns Left when the function returns Left" do
      result =
        LazyTaskEither.right(10)
        |> bind(fn _value -> LazyTaskEither.left("error") end)
        |> LazyTaskEither.run()

      assert result == Either.left("error")
    end

    test "bind does not apply the function for a Left monad" do
      result =
        LazyTaskEither.left("error")
        |> bind(fn _value -> LazyTaskEither.right(42) end)
        |> LazyTaskEither.run()

      assert result == Either.left("error")
    end

    test "bind chains multiple Right monads together" do
      result =
        LazyTaskEither.right(10)
        |> bind(fn value -> LazyTaskEither.right(value + 5) end)
        |> bind(fn value -> LazyTaskEither.right(value * 2) end)
        |> LazyTaskEither.run()

      assert result == Either.right(30)
    end

    test "bind short-circuits when encountering a Left after a Right" do
      result =
        LazyTaskEither.right(10)
        |> bind(fn value -> LazyTaskEither.right(value + 5) end)
        |> bind(fn _value -> LazyTaskEither.left("error occurred") end)
        |> bind(fn _value -> LazyTaskEither.right(42) end)
        |> LazyTaskEither.run()

      assert result == Either.left("error occurred")
    end

    test "bind preserves the first Left encountered in a chain of Lefts" do
      result =
        LazyTaskEither.left("first error")
        |> bind(fn _value -> LazyTaskEither.left("second error") end)
        |> bind(fn _value -> LazyTaskEither.left("third error") end)
        |> LazyTaskEither.run()

      assert result == Either.left("first error")
    end
  end

  describe "map/2" do
    test "map applies a function to the value inside a Right monad" do
      result =
        LazyTaskEither.right(10)
        |> map(fn value -> value * 2 end)
        |> LazyTaskEither.run()

      assert result == Either.right(20)
    end

    test "map does not apply the function for a Left monad" do
      result =
        LazyTaskEither.left("error")
        |> map(fn _value -> raise "Should not be called" end)
        |> LazyTaskEither.run()

      assert result == Either.left("error")
    end
  end

  describe "lift_predicate/3" do
    test "returns Right when predicate returns true" do
      result =
        LazyTaskEither.lift_predicate(10, fn x -> x > 5 end, fn -> "Value is too small" end)
        |> LazyTaskEither.run()

      assert result == Either.right(10)
    end

    test "returns Left when predicate returns false" do
      result =
        LazyTaskEither.lift_predicate(3, fn x -> x > 5 end, fn -> "Value is too small" end)
        |> LazyTaskEither.run()

      assert result == Either.left("Value is too small")
    end
  end

  describe "lift_either/1" do
    test "wraps an Either.Right into a LazyTaskEither.Right" do
      either = %Either.Right{value: 42}

      result =
        LazyTaskEither.lift_either(either)
        |> LazyTaskEither.run()

      assert result == Either.right(42)
    end

    test "wraps an Either.Left into a LazyTaskEither.Left" do
      either = %Either.Left{value: "error"}

      result =
        LazyTaskEither.lift_either(either)
        |> LazyTaskEither.run()

      assert result == Either.left("error")
    end
  end

  describe "lift_option/2" do
    test "wraps a Just value into a LazyTaskEither.Right" do
      maybe = Maybe.just(42)

      result =
        LazyTaskEither.lift_option(maybe, fn -> "No value" end)
        |> LazyTaskEither.run()

      assert result == Either.right(42)
    end

    test "wraps a Nothing value into a LazyTaskEither.Left" do
      maybe = Maybe.nothing()

      result =
        LazyTaskEither.lift_option(maybe, fn -> "No value" end)
        |> LazyTaskEither.run()

      assert result == Either.left("No value")
    end
  end

  describe "fold/3 with results of LazyTaskEither" do
    test "applies right function for a Right value returned by a task" do
      right_value = LazyTaskEither.right(42)

      result =
        right_value
        |> LazyTaskEither.run()
        |> fold(
          fn value -> "Right value is: #{value}" end,
          fn _error -> "This should not be called" end
        )

      assert result == "Right value is: 42"
    end

    test "applies left function for a Left value returned by a task" do
      left_value = LazyTaskEither.left("Something went wrong")

      result =
        left_value
        |> LazyTaskEither.run()
        |> fold(
          fn _value -> "This should not be called" end,
          fn error -> "Error: #{error}" end
        )

      assert result == "Error: Something went wrong"
    end
  end

  describe "sequence/1" do
    test "sequence with all Right values returns a Right with a list" do
      tasks = [
        LazyTaskEither.right(1),
        LazyTaskEither.right(2),
        LazyTaskEither.right(3)
      ]

      result =
        LazyTaskEither.sequence(tasks)
        |> LazyTaskEither.run()

      assert result == Either.right([1, 2, 3])
    end

    test "sequence with a Left value returns the first encountered Left" do
      tasks = [
        LazyTaskEither.right(1),
        LazyTaskEither.left("Error occurred"),
        LazyTaskEither.right(3),
        LazyTaskEither.left("Second Error occurred")
      ]

      result =
        LazyTaskEither.sequence(tasks)
        |> LazyTaskEither.run()

      assert result == Either.left("Error occurred")
    end

    test "sequence with multiple Left values returns the first encountered Left" do
      tasks = [
        LazyTaskEither.left("First error"),
        LazyTaskEither.left("Second error"),
        LazyTaskEither.right(3)
      ]

      result =
        LazyTaskEither.sequence(tasks)
        |> LazyTaskEither.run()

      assert result == Either.left("First error")
    end

    test "sequence with an empty list returns a Right with an empty list" do
      tasks = []

      result =
        LazyTaskEither.sequence(tasks)
        |> LazyTaskEither.run()

      assert result == Either.right([])
    end
  end

  describe "traverse/2" do
    test "traverse with a list of valid values returns a Right with a list" do
      is_positive = fn num ->
        LazyTaskEither.lift_predicate(num, &(&1 > 0), fn -> "#{num} is not positive" end)
      end

      result =
        LazyTaskEither.traverse([1, 2, 3], is_positive)
        |> LazyTaskEither.run()

      assert result == Either.right([1, 2, 3])
    end

    test "traverse with a list containing an invalid value returns a Left" do
      is_positive = fn num ->
        LazyTaskEither.lift_predicate(num, &(&1 > 0), fn -> "#{num} is not positive" end)
      end

      result =
        LazyTaskEither.traverse([1, -2, 3], is_positive)
        |> LazyTaskEither.run()

      assert result == Either.left("-2 is not positive")
    end

    test "traverse with an empty list returns a Right with an empty list" do
      is_positive = fn num ->
        LazyTaskEither.lift_predicate(num, &(&1 > 0), fn -> "#{num} is not positive" end)
      end

      result =
        LazyTaskEither.traverse([], is_positive)
        |> LazyTaskEither.run()

      assert result == Either.right([])
    end
  end

  describe "from_result/1" do
    test "converts {:ok, value} to LazyTaskEither.Right" do
      result = LazyTaskEither.from_result({:ok, 42})
      assert LazyTaskEither.run(result) == Either.right(42)
    end

    test "converts {:error, reason} to LazyTaskEither.Left" do
      result = LazyTaskEither.from_result({:error, "error"})
      assert LazyTaskEither.run(result) == Either.left("error")
    end
  end

  describe "to_result/1" do
    test "converts LazyTaskEither.Right to {:ok, value}" do
      lazy_result = LazyTaskEither.right(42)
      assert LazyTaskEither.to_result(lazy_result) == {:ok, 42}
    end

    test "converts LazyTaskEither.Left to {:error, reason}" do
      lazy_error = LazyTaskEither.left("error")
      assert LazyTaskEither.to_result(lazy_error) == {:error, "error"}
    end
  end

  describe "LazyTaskEither.from_try/1" do
    test "converts a successful function into LazyTaskEither.Right" do
      result = LazyTaskEither.from_try(fn -> 42 end)

      assert LazyTaskEither.run(result) == %Either.Right{value: 42}
    end

    test "converts a raised exception into LazyTaskEither.Left" do
      result = LazyTaskEither.from_try(fn -> raise "error" end)

      assert LazyTaskEither.run(result) == %Either.Left{value: %RuntimeError{message: "error"}}
    end
  end

  describe "LazyTaskEither.to_try!/1" do
    test "returns value from LazyTaskEither.Right" do
      lazy_result = LazyTaskEither.right(42)
      assert LazyTaskEither.to_try!(lazy_result) == 42
    end

    test "raises the reason from LazyTaskEither.Left" do
      exception = %RuntimeError{message: "something went wrong"}
      lazy_error = LazyTaskEither.left(exception)

      assert_raise RuntimeError, "something went wrong", fn ->
        LazyTaskEither.to_try!(lazy_error)
      end
    end
  end
end
