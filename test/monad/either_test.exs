defmodule Monex.EitherTest do
  use ExUnit.Case, async: true
  import Monex.Monad, only: [ap: 2, bind: 2, map: 2]
  import Monex.Foldable, only: [fold: 3]

  alias Monex.{Either, Maybe, Eq, Ord}
  alias Either.{Left, Right}

  describe "Right.pure/1" do
    test "wraps a non-error value in a Right monad" do
      assert %Right{value: 42} = Either.right(42)
    end
  end

  describe "Left.pure/1" do
    test "wraps an error value in a Left monad" do
      assert %Left{value: "error"} = Either.left("error")
    end
  end

  describe "map/2" do
    test "applies a function to the value inside a Right monad" do
      assert %Right{value: 43} =
               Either.right(42)
               |> map(&(&1 + 1))
    end

    test "returns Left when mapping over a Left monad" do
      assert %Left{} =
               Either.left("error")
               |> map(&(&1 + 1))
    end
  end

  describe "bind/2" do
    test "applies a function returning a monad to the value inside a Right monad" do
      assert %Right{value: 21} =
               Either.right(42)
               |> bind(fn x -> Either.right(div(x, 2)) end)
    end

    test "returns Left when binding over a Left monad" do
      assert %Left{value: "error"} =
               Either.left("error")
               |> bind(fn _ -> Either.right(10) end)
    end

    test "returns Left when the function returns Left" do
      assert %Left{value: "error"} =
               Either.right(42)
               |> bind(fn _ -> Either.left("error") end)
    end
  end

  describe "ap/2" do
    test "applies a function in Right to a value in Right" do
      assert ap(Either.right(&(&1 + 1)), Either.right(42)) == Either.right(43)
    end

    test "returns Left if the function is in Left" do
      assert ap(Either.left("error"), Either.right(42)) == Either.left("error")
    end

    test "returns Left if the value is in Left" do
      assert ap(Either.right(&(&1 + 1)), Either.left("error")) == Either.left("error")
    end

    test "returns Left if both are Left" do
      assert ap(Either.left("error"), Either.left("error")) == Either.left("error")
    end
  end

  describe "fold/3" do
    test "applies the right_func to a Right value" do
      result =
        Either.right(42)
        |> fold(fn x -> "Right #{x}" end, fn -> "Left" end)

      assert result == "Right 42"
    end

    test "applies the left_func to a Left value" do
      result =
        Either.left("error")
        |> fold(fn x -> "Right #{x}" end, fn value -> "Left: #{value}" end)

      assert result == "Left: error"
    end
  end

  describe "right?/1" do
    test "returns true for Right values" do
      assert Either.right?(Either.right(42)) == true
    end

    test "returns false for Left values" do
      assert Either.right?(Either.left("error")) == false
    end
  end

  describe "left?/1" do
    test "returns true for Left values" do
      assert Either.left?(Either.left("error")) == true
    end

    test "returns false for Right values" do
      assert Either.left?(Either.right(42)) == false
    end
  end

  describe "String.Chars" do
    test "Right value string representation" do
      right_value = Either.right(42)
      assert to_string(right_value) == "Right(42)"
    end

    test "Left value string representation" do
      left_value = Either.left("error")
      assert to_string(left_value) == "Left(error)"
    end
  end

  describe "filter_or_else/3" do
    test "returns Right value when predicate is true" do
      either_value = Either.right(1)
      assert Either.filter_or_else(either_value, &(&1 > 0), fn -> "error" end) == either_value
    end

    test "returns Left value when predicate is false" do
      either_value = Either.right(-1)

      assert Either.filter_or_else(either_value, &(&1 > 0), fn -> "error" end) ==
               Either.left("error")
    end

    test "returns Left unchanged when already a Left" do
      left_value = Either.left("existing error")

      assert Either.filter_or_else(left_value, fn _ -> true end, fn -> "new error" end) ==
               left_value
    end
  end

  describe "get_or_else/2" do
    test "returns the value in Right when present" do
      assert Monex.Either.get_or_else(Either.right(42), 0) == 42
    end

    test "returns the default value when Left" do
      assert Monex.Either.get_or_else(Either.left("error"), 0) == 0
    end
  end

  describe "traverse/2" do
    test "applies a function and sequences the results" do
      result = Either.traverse(&Either.right/1, [1, 2, 3])
      assert result == Either.right([1, 2, 3])
    end

    test "returns Left if the function returns Left for any element" do
      result =
        Either.traverse(
          fn x ->
            if x > 1,
              do: Either.left("error"),
              else: Either.right(x)
          end,
          [1, 2, 3]
        )

      assert result == Either.left("error")
    end
  end

  describe "sequence/1" do
    test "sequences a list of Right values" do
      result = Either.sequence([Either.right(1), Either.right(2), Either.right(3)])
      assert result == Either.right([1, 2, 3])
    end

    test "returns Left if any value is Left" do
      result = Either.sequence([Either.right(1), Either.left("error"), Either.right(3)])
      assert result == Either.left("error")
    end
  end

  describe "Eq.equals?/2" do
    test "returns true for equal Right values" do
      assert Eq.equals?(Either.right(1), Either.right(1)) == true
    end

    test "returns false for different Right values" do
      assert Eq.equals?(Either.right(1), Either.right(2)) == false
    end

    test "returns true for two Left values" do
      assert Eq.equals?(Either.left(1), Either.left(1)) == true
    end

    test "returns false for Right and Left comparison" do
      assert Eq.equals?(Either.right(1), Either.left(1)) == false
    end

    test "returns false for Left and Right comparison" do
      assert Eq.equals?(Either.left(1), Either.right(1)) == false
    end
  end

  describe "get_eq/1" do
    setup do
      number_eq = %{equals?: &Kernel.==/2}
      {:ok, eq: Either.get_eq(number_eq)}
    end

    test "returns true for equal Right values", %{eq: eq} do
      assert eq.equals?.(Either.right(1), Either.right(1)) == true
    end

    test "returns false for different Right values", %{eq: eq} do
      assert eq.equals?.(Either.right(1), Either.right(2)) == false
    end

    test "returns true for two Left values", %{eq: eq} do
      assert eq.equals?.(Either.left(1), Either.left(1)) == true
    end

    test "returns false for Right and Left comparison", %{eq: eq} do
      assert eq.equals?.(Either.right(1), Either.left(1)) == false
    end

    test "returns false for Left and Right comparison", %{eq: eq} do
      assert eq.equals?.(Either.left(1), Either.right(1)) == false
    end
  end

  describe "Ord.le?/2" do
    test "returns true when Right value is less than or equal to another Right value" do
      assert Ord.le?(Either.right(1), Either.right(2)) == true
      assert Ord.le?(Either.right(2), Either.right(2)) == true
    end

    test "returns false when Right value is greater than another Right value" do
      assert Ord.le?(Either.right(2), Either.right(1)) == false
    end

    test "returns true for Left compared to Right" do
      assert Ord.le?(Either.left(100), Either.right(1)) == true
    end

    test "returns true for Left compared to Left" do
      assert Ord.le?(Either.left(1), Either.left(2)) == true
    end

    test "returns false for Right compared to Left" do
      assert Ord.le?(Either.right(1), Either.left(100)) == false
    end
  end

  describe "Ord.gt?/2" do
    test "returns true when Right value is greater than another Right value" do
      assert Ord.gt?(Either.right(2), Either.right(1)) == true
    end

    test "returns false when Right value is less than or equal to another Right value" do
      assert Ord.gt?(Either.right(1), Either.right(2)) == false
      assert Ord.gt?(Either.right(2), Either.right(2)) == false
    end

    test "returns false for Left compared to Right" do
      assert Ord.gt?(Either.left(100), Either.right(1)) == false
    end

    test "returns true for Right compared to Left" do
      assert Ord.gt?(Either.right(1), Either.left(100)) == true
    end
  end

  describe "Ord.ge?/2" do
    test "returns true when Right value is greater than or equal to another Right value" do
      assert Ord.ge?(Either.right(2), Either.right(1)) == true
      assert Ord.ge?(Either.right(2), Either.right(2)) == true
    end

    test "returns false when Right value is less than another Right value" do
      assert Ord.ge?(Either.right(1), Either.right(2)) == false
    end

    test "returns true for Right compared to Left" do
      assert Ord.ge?(Either.right(1), Either.left(1)) == true
    end

    test "returns true for Left compared to Left" do
      assert Ord.ge?(Either.left(1), Either.left(1)) == true
    end

    test "returns false for Left compared to Right" do
      assert Ord.ge?(Either.left(1), Either.right(1)) == false
    end
  end

  describe "get_ord/1" do
    setup do
      number_ord = %{lt?: &Kernel.</2}
      {:ok, ord: Either.get_ord(number_ord)}
    end

    test "Left is less than any Right", %{ord: ord} do
      assert ord[:lt?].(Either.left(100), Either.right(1)) == true
    end

    test "Right is greater than Left", %{ord: ord} do
      assert ord[:gt?].(Either.right(1), Either.left(100)) == true
    end

    test "Orders Right values based on their contained values", %{ord: ord} do
      assert ord[:lt?].(Either.right(42), Either.right(43)) == true
      assert ord[:gt?].(Either.right(43), Either.right(42)) == true
      assert ord[:le?].(Either.right(42), Either.right(42)) == true
      assert ord[:ge?].(Either.right(42), Either.right(42)) == true
    end

    test "Left is equal to Left in terms of ordering", %{ord: ord} do
      assert ord[:le?].(Either.left(1), Either.left(1)) == true
      assert ord[:ge?].(Either.left(1), Either.left(1)) == true
    end
  end

  describe "lift_option/2" do
    test "returns Right when the function returns Just" do
      result =
        Maybe.just(5)
        |> Either.lift_option(fn -> "Missing value" end)

      assert result == Either.right(5)
    end

    test "returns Left when the function returns Nothing" do
      result =
        Maybe.nothing()
        |> Either.lift_option(fn -> "Missing value" end)

      assert result == Either.left("Missing value")
    end
  end

  describe "lift_predicate/3" do
    test "returns Right when the predicate is true" do
      pred = fn x -> x > 0 end
      false_func = fn -> "Predicate failed" end

      result =
        5
        |> Either.lift_predicate(pred, false_func)

      assert result == Either.right(5)
    end

    test "returns Left when the predicate is false" do
      pred = fn x -> x > 0 end
      false_func = fn -> "Predicate failed" end

      result =
        0
        |> Either.lift_predicate(pred, false_func)

      assert result == Either.left("Predicate failed")
    end
  end
end
