defmodule Monex.IdentityTest do
  use ExUnit.Case, async: true
  import Monex.Identity
  import Monex.Monad, only: [ap: 2, bind: 2, map: 2]
  alias Monex.{Identity, Eq, Ord}

  describe "pure/1" do
    test "wraps a value in the Identity monad" do
      assert %Identity{value: 42} = pure(42)
    end
  end

  describe "Identity.extract/1" do
    test "extracts the value from the Identity monad" do
      assert 42 == pure(42) |> extract()
    end
  end

  describe "ap/2" do
    test "applies a function in an Identity monad to a value in another Identity monad" do
      assert ap(pure(&(&1 + 1)), pure(42)) == pure(43)
    end
  end

  describe "bind/2" do
    test "applies a function returning a monad to the value inside the Identity monad" do
      assert %Identity{value: 21} =
               pure(42)
               |> bind(fn x -> pure(div(x, 2)) end)
    end
  end

  describe "map/2" do
    test "applies a function to the value inside the Identity monad" do
      assert %Identity{value: 43} =
               pure(42)
               |> map(&(&1 + 1))
    end
  end

  describe "String.Chars" do
    test "Identity value string representation" do
      identity_value = pure(42)
      assert to_string(identity_value) == "Identity(42)"
    end
  end

  describe "Eq.equals?/2" do
    test "returns true for equal Just values" do
      assert Eq.equals?(pure(1), pure(1)) == true
    end

    test "returns false for different Just values" do
      assert Eq.equals?(pure(1), pure(2)) == false
    end
  end

  describe "get_eq/1" do
    setup do
      number_eq = %{equals?: &Kernel.==/2}
      {:ok, eq: get_eq(number_eq)}
    end

    test "returns true for equal Just values", %{eq: eq} do
      assert eq.equals?.(pure(1), pure(1)) == true
    end

    test "returns false for different Just values", %{eq: eq} do
      assert eq.equals?.(pure(1), pure(2)) == false
    end
  end

  describe "Ord.lt?/2" do
    test "Identity returns true for less value" do
      assert Ord.lt?(pure(1), pure(2)) == true
    end

    test "Identity returns false for more value" do
      assert Ord.lt?(pure(2), pure(1)) == false
    end

    test "Identity returns false for equal values" do
      assert Ord.lt?(pure(1), pure(1)) == false
    end
  end

  describe "Ord.le?/2" do
    test "Identity returns true for less value" do
      assert Ord.le?(pure(1), pure(2)) == true
    end

    test "Identity returns true for equal values" do
      assert Ord.le?(pure(1), pure(1)) == true
    end

    test "Identity returns false for greater value" do
      assert Ord.le?(pure(2), pure(1)) == false
    end
  end

  describe "Ord.gt?/2" do
    test "Identity returns true for greater value" do
      assert Ord.gt?(pure(2), pure(1)) == true
    end

    test "Identity returns false for less value" do
      assert Ord.gt?(pure(1), pure(2)) == false
    end

    test "Identity returns false for equal values" do
      assert Ord.gt?(pure(1), pure(1)) == false
    end
  end

  describe "Ord.ge?/2" do
    test "Identity returns true for greater value" do
      assert Ord.ge?(pure(2), pure(1)) == true
    end

    test "Identity returns true for equal values" do
      assert Ord.ge?(pure(1), pure(1)) == true
    end

    test "Identity returns false for less value" do
      assert Ord.ge?(pure(1), pure(2)) == false
    end
  end

  describe "get_ord/1" do
    setup do
      number_ord = %{lt?: &Kernel.</2}
      {:ok, ord: get_ord(number_ord)}
    end

    test "Orders Identity values based on their contained values", %{ord: ord} do
      assert ord.lt?.(pure(42), pure(43)) == true
      assert ord.gt?.(pure(43), pure(42)) == true
      assert ord.le?.(pure(42), pure(42)) == true
      assert ord.ge?.(pure(42), pure(42)) == true
    end
  end
end
