defmodule Monex.MaybeTest do
  use ExUnit.Case, async: true
  import Monex.Monad, only: [ap: 2, bind: 2, map: 2]
  import Monex.Foldable, only: [fold: 3]

  alias Monex.{Maybe, Either, Eq, Ord}
  alias Maybe.{Just, Nothing}

  describe "Just.pure/1" do
    test "wraps a non-nil value in a Just monad" do
      assert %Just{value: 42} = Maybe.pure(42)
    end

    test "raises an error when wrapping nil" do
      assert_raise ArgumentError, "Cannot wrap nil in a Just", fn ->
        Maybe.pure(nil)
      end
    end
  end

  describe "Nothing.pure/0" do
    test "returns the Nothing struct" do
      assert %Nothing{} = Maybe.nothing()
    end
  end

  describe "map/2" do
    test "applies a function to the value inside a Just monad" do
      assert %Just{value: 43} =
               Maybe.pure(42)
               |> map(&(&1 + 1))
    end

    test "returns Nothing when mapping over a Nothing monad" do
      assert %Nothing{} =
               Maybe.nothing()
               |> map(&(&1 + 1))
    end
  end

  describe "bind/2" do
    test "applies a function returning a monad to the value inside a Just monad" do
      assert %Just{value: 21} =
               Maybe.pure(42)
               |> bind(fn x -> Maybe.pure(div(x, 2)) end)
    end

    test "returns Nothing when binding over a Nothing monad" do
      assert %Nothing{} =
               Maybe.nothing()
               |> bind(fn _ -> Maybe.pure(10) end)
    end

    test "returns Nothing when the function returns Nothing" do
      assert %Nothing{} =
               Maybe.pure(42)
               |> bind(fn _ -> Maybe.nothing() end)
    end
  end

  describe "ap/2" do
    test "applies a function in Just to a value in Just" do
      assert ap(Maybe.pure(&(&1 + 1)), Maybe.pure(42)) == Maybe.pure(43)
    end

    test "returns Nothing if the function is in Nothing" do
      assert ap(Maybe.nothing(), Maybe.pure(42)) == Maybe.nothing()
    end

    test "returns Nothing if the value is in Nothing" do
      assert ap(Maybe.pure(&(&1 + 1)), Maybe.nothing()) == Maybe.nothing()
    end

    test "returns Nothing if both are Nothing" do
      assert ap(Maybe.nothing(), Maybe.nothing()) == Maybe.nothing()
    end
  end

  describe "fold/3" do
    test "applies the just_func to a Just value" do
      result =
        Maybe.pure(42)
        |> fold(fn x -> "Just #{x}" end, fn -> "Nothing" end)

      assert result == "Just 42"
    end

    test "applies the nothing_func to a Nothing value" do
      result =
        Maybe.nothing()
        |> fold(fn x -> "Just #{x}" end, fn -> "Nothing" end)

      assert result == "Nothing"
    end
  end

  describe "just?/1" do
    test "returns true for Just values" do
      assert Maybe.just?(Maybe.pure(42)) == true
    end

    test "returns false for Nothing values" do
      assert Maybe.just?(Maybe.nothing()) == false
    end
  end

  describe "nothing?/1" do
    test "returns true for Nothing values" do
      assert Maybe.nothing?(Maybe.nothing()) == true
    end

    test "returns false for Just values" do
      assert Maybe.nothing?(Maybe.pure(42)) == false
    end
  end

  describe "String.Chars" do
    test "Just value string representation" do
      just_value = Maybe.pure(42)
      assert to_string(just_value) == "Just(42)"
    end

    test "Nothing value string representation" do
      nothing_value = Maybe.nothing()
      assert to_string(nothing_value) == "Nothing"
    end
  end

  describe "get_or_else/2" do
    test "returns the value in Just when present" do
      assert Maybe.pure(42) |> Maybe.get_or_else(0) == 42
    end

    test "returns the default value when Nothing" do
      assert Maybe.nothing() |> Maybe.get_or_else(0) == 0
    end
  end

  describe "filter/2" do
    test "returns Just value when predicate is true" do
      maybe_value = Maybe.pure(42)
      assert Maybe.filter(maybe_value, &(&1 > 40)) == maybe_value
    end

    test "returns Nothing when predicate is false" do
      maybe_value = Maybe.pure(42)
      assert Maybe.filter(maybe_value, &(&1 > 50)) == Maybe.nothing()
    end

    test "returns Nothing when given Nothing" do
      nothing_value = Maybe.nothing()
      assert Maybe.filter(nothing_value, fn _ -> true end) == nothing_value
    end
  end

  describe "traverse/2" do
    test "applies a function and sequences the results" do
      result = Maybe.traverse(&Maybe.just/1, [1, 2, 3])
      assert result == Maybe.just([1, 2, 3])
    end

    test "returns Nothing if the function returns Nothing for any element" do
      result =
        Maybe.traverse(
          fn x ->
            if x > 1,
              do: Maybe.nothing(),
              else: Maybe.just(x)
          end,
          [1, 2, 3]
        )

      assert result == Maybe.nothing()
    end
  end

  describe "sequence/1" do
    test "sequences a list of Just values" do
      result = Maybe.sequence([Maybe.just(1), Maybe.just(2), Maybe.just(3)])
      assert result == Maybe.just([1, 2, 3])
    end

    test "returns Nothing if any value is Nothing" do
      result = Maybe.sequence([Maybe.just(1), Maybe.nothing(), Maybe.just(3)])
      assert result == Maybe.nothing()
    end
  end

  # Ord and Eq Tests

  describe "Eq.equals?/2" do
    test "returns true for equal Just values" do
      assert Eq.equals?(Maybe.just(1), Maybe.just(1)) == true
    end

    test "returns false for different Just values" do
      assert Eq.equals?(Maybe.just(1), Maybe.just(2)) == false
    end

    test "returns true for two Nothing values" do
      assert Eq.equals?(Maybe.nothing(), Maybe.nothing()) == true
    end

    test "returns false for Just and Nothing comparison" do
      assert Eq.equals?(Maybe.just(1), Maybe.nothing()) == false
    end

    test "returns false for Nothing and Just comparison" do
      assert Eq.equals?(Maybe.nothing(), Maybe.just(1)) == false
    end
  end

  describe "get_eq/1" do
    setup do
      number_eq = %{equals?: &Kernel.==/2}
      {:ok, eq: Maybe.get_eq(number_eq)}
    end

    test "returns true for equal Just values", %{eq: eq} do
      assert eq.equals?.(Maybe.just(1), Maybe.just(1)) == true
    end

    test "returns false for different Just values", %{eq: eq} do
      assert eq.equals?.(Maybe.just(1), Maybe.just(2)) == false
    end

    test "returns true for two Nothing values", %{eq: eq} do
      assert eq.equals?.(Maybe.nothing(), Maybe.nothing()) == true
    end

    test "returns false for Just and Nothing comparison", %{eq: eq} do
      assert eq.equals?.(Maybe.just(1), Maybe.nothing()) == false
    end

    test "returns false for Nothing and Just comparison", %{eq: eq} do
      assert eq.equals?.(Maybe.nothing(), Maybe.just(1)) == false
    end
  end

  describe "Ord.lt?/2" do
    test "returns true for less Just value" do
      assert Ord.lt?(Maybe.just(1), Maybe.just(2)) == true
    end

    test "returns false for more Just value" do
      assert Ord.lt?(Maybe.just(2), Maybe.just(1)) == false
    end

    test "returns false for equal Just values" do
      assert Ord.lt?(Maybe.just(1), Maybe.just(1)) == false
    end

    test "returns true for Nothing compared to Just value" do
      assert Ord.lt?(Maybe.nothing(), Maybe.just(1)) == true
    end

    test "returns false for Just compared to Nothing value" do
      assert Ord.lt?(Maybe.just(1), Maybe.nothing()) == false
    end

    test "returns false for two Nothing values" do
      assert Ord.lt?(Maybe.nothing(), Maybe.nothing()) == false
    end
  end

  describe "Ord.le?/2" do
    test "returns true when Just value is less than or equal to another Just value" do
      assert Ord.le?(Maybe.just(1), Maybe.just(2)) == true
      assert Ord.le?(Maybe.just(2), Maybe.just(2)) == true
    end

    test "returns false when Just value is greater than another Just value" do
      assert Ord.le?(Maybe.just(2), Maybe.just(1)) == false
    end

    test "returns true for Nothing compared to Just" do
      assert Ord.le?(Maybe.nothing(), Maybe.just(1)) == true
    end

    test "returns true for Nothing compared to Nothing" do
      assert Ord.le?(Maybe.nothing(), Maybe.nothing()) == true
    end

    test "returns false for Just compared to Nothing" do
      assert Ord.le?(Maybe.just(1), Maybe.nothing()) == false
    end
  end

  describe "Ord.gt?/2" do
    test "returns true when Just value is greater than another Just value" do
      assert Ord.gt?(Maybe.just(2), Maybe.just(1)) == true
    end

    test "returns false when Just value is less than or equal to another Just value" do
      assert Ord.gt?(Maybe.just(1), Maybe.just(2)) == false
      assert Ord.gt?(Maybe.just(2), Maybe.just(2)) == false
    end

    test "returns false for Nothing compared to Just" do
      assert Ord.gt?(Maybe.nothing(), Maybe.just(1)) == false
    end

    test "returns false for Nothing compared to Nothing" do
      assert Ord.gt?(Maybe.nothing(), Maybe.nothing()) == false
    end

    test "returns true for Just compared to Nothing" do
      assert Ord.gt?(Maybe.just(1), Maybe.nothing()) == true
    end
  end

  describe "Ord.ge?/2" do
    test "returns true when Just value is greater than or equal to another Just value" do
      assert Ord.ge?(Maybe.just(2), Maybe.just(1)) == true
      assert Ord.ge?(Maybe.just(2), Maybe.just(2)) == true
    end

    test "returns false when Just value is less than another Just value" do
      assert Ord.ge?(Maybe.just(1), Maybe.just(2)) == false
    end

    test "returns true for Just compared to Nothing" do
      assert Ord.ge?(Maybe.just(1), Maybe.nothing()) == true
    end

    test "returns true for Nothing compared to Nothing" do
      assert Ord.ge?(Maybe.nothing(), Maybe.nothing()) == true
    end

    test "returns false for Nothing compared to Just" do
      assert Ord.ge?(Maybe.nothing(), Maybe.just(1)) == false
    end
  end

  describe "get_ord/1" do
    setup do
      number_ord = %{lt?: &Kernel.</2}
      {:ok, ord: Maybe.get_ord(number_ord)}
    end

    test "Nothing is less than any Just", %{ord: ord} do
      assert ord.lt?.(Maybe.nothing(), Maybe.just(42)) == true
    end

    test "Just is greater than Nothing", %{ord: ord} do
      assert ord.gt?.(Maybe.just(42), Maybe.nothing()) == true
    end

    test "Orders Just values based on their contained values", %{ord: ord} do
      assert ord.lt?.(Maybe.just(42), Maybe.just(43)) == true
      assert ord.gt?.(Maybe.just(43), Maybe.just(42)) == true
      assert ord.le?.(Maybe.just(42), Maybe.just(42)) == true
      assert ord.ge?.(Maybe.just(42), Maybe.just(42)) == true
    end

    test "Nothing is equal to Nothing in terms of ordering", %{ord: ord} do
      assert ord.le?.(Maybe.nothing(), Maybe.nothing()) == true
      assert ord.ge?.(Maybe.nothing(), Maybe.nothing()) == true
    end
  end

  describe "lift_either/1" do
    test "converts Right to Just" do
      result = Either.right(42) |> Maybe.lift_either()
      assert result == Maybe.just(42)
    end

    test "converts Left to Nothing" do
      result = Either.left("Error") |> Maybe.lift_either()
      assert result == Maybe.nothing()
    end
  end

  describe "lift_predicate/2" do
    test "returns Just when the predicate is true" do
      pred = fn x -> x > 0 end

      result =
        5
        |> Maybe.lift_predicate(pred)

      assert result == Maybe.just(5)
    end

    test "returns Nothing when the predicate is false" do
      pred = fn x -> x > 0 end

      result =
        0
        |> Maybe.lift_predicate(pred)

      assert result == Maybe.nothing()
    end
  end

  describe "from_nil/1" do
    test "converts nil to Nothing" do
      assert Maybe.from_nil(nil) == %Maybe.Nothing{}
    end

    test "converts non-nil value to Just" do
      assert Maybe.from_nil(42) == %Maybe.Just{value: 42}
    end

    test "converts non-nil value (string) to Just" do
      assert Maybe.from_nil("hello") == %Maybe.Just{value: "hello"}
    end
  end

  describe "to_nil/1" do
    test "converts Just to the contained value" do
      assert Maybe.to_nil(%Maybe.Just{value: 42}) == 42
    end

    test "converts Nothing to nil" do
      assert Maybe.to_nil(%Maybe.Nothing{}) == nil
    end

    test "converts Just (string) to the contained string value" do
      assert Maybe.to_nil(%Maybe.Just{value: "hello"}) == "hello"
    end
  end

  describe "to_try!/2" do
    test "returns value from Maybe.Just" do
      assert Maybe.to_try!(%Maybe.Just{value: 42}) == 42
    end

    test "raises an error for Maybe.Nothing with default message" do
      assert_raise RuntimeError, "Nothing value encountered", fn ->
        Maybe.to_try!(%Maybe.Nothing{})
      end
    end

    test "raises an error for Maybe.Nothing with custom message" do
      assert_raise RuntimeError, "Custom error message", fn ->
        Maybe.to_try!(%Maybe.Nothing{}, "Custom error message")
      end
    end
  end

  describe "from_result/1" do
    test "converts {:ok, value} to Maybe.Just" do
      assert Maybe.from_result({:ok, 42}) == %Maybe.Just{value: 42}
    end

    test "converts {:error, reason} to Maybe.Nothing" do
      assert Maybe.from_result({:error, "some error"}) == %Maybe.Nothing{}
    end
  end

  describe "to_result/1" do
    test "converts Maybe.Just to {:ok, value}" do
      assert Maybe.to_result(%Maybe.Just{value: 42}) == {:ok, 42}
    end

    test "converts Maybe.Nothing to {:error, :nothing}" do
      assert Maybe.to_result(%Maybe.Nothing{}) == {:error, :nothing}
    end
  end
end
