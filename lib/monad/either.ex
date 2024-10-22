defmodule Monex.Either do
  import Monex.Monad, only: [bind: 2]
  import Monex.Foldable, only: [fold: 3]
  alias Monex.Either.{Left, Right}

  @type t(left, right) :: Left.t(left) | Right.t(right)

  def right(value), do: Right.pure(value)
  def pure(value), do: Right.pure(value)

  def left(value), do: Left.pure(value)

  def left?(%Left{}), do: true
  def left?(_), do: false

  def right?(%Right{}), do: true
  def right?(_), do: false

  def filter_or_else(either, predicate, error_func) do
    fold(
      either,
      fn value ->
        if predicate.(value) do
          either
        else
          Left.pure(error_func.())
        end
      end,
      fn _left_value -> either end
    )
  end

  def get_or_else(either, default) do
    fold(
      either,
      fn value -> value end,
      fn _left_value -> default end
    )
  end

  def get_eq(custom_eq) do
    %{
      equals?: fn
        %Right{value: v1}, %Right{value: v2} -> custom_eq.equals?.(v1, v2)
        %Left{}, %Right{} -> false
        %Right{}, %Left{} -> false
        %Left{value: v1}, %Left{value: v2} -> v1 == v2
      end
    }
  end

  def get_ord(custom_ord) do
    %{
      lt?: fn
        %Left{}, %Right{} -> true
        %Right{}, %Left{} -> false
        %Right{value: v1}, %Right{value: v2} -> custom_ord.lt?.(v1, v2)
        %Left{}, %Left{} -> false
      end,
      le?: fn a, b -> not get_ord(custom_ord).gt?.(a, b) end,
      gt?: fn
        %Right{}, %Left{} -> true
        %Left{}, %Right{} -> false
        %Right{value: v1}, %Right{value: v2} -> custom_ord.lt?.(v2, v1)
        %Left{}, %Left{} -> false
      end,
      ge?: fn a, b -> not get_ord(custom_ord).lt?.(a, b) end
    }
  end

  @spec sequence([t(error, value)]) :: t(error, [value]) when error: term(), value: term()
  def sequence([]), do: right([])

  def sequence([head | tail]) do
    bind(head, fn value ->
      bind(sequence(tail), fn rest ->
        right([value | rest])
      end)
    end)
  end

  @spec traverse((a -> t(error, b)), [a]) :: t(error, [b])
        when error: term(), a: term(), b: term()
  def traverse(func, list) do
    list
    |> Enum.map(func)
    |> sequence()
  end

  @spec sequence_a([t(error, value)]) :: t([error], [value])
        when error: term(), value: term()
  def sequence_a([]), do: right([])

  def sequence_a([head | tail]) do
    case head do
      %Right{value: value} ->
        sequence_a(tail)
        |> case do
          %Right{value: values} -> right([value | values])
          %Left{value: errors} -> left(errors)
        end

      %Left{value: error} ->
        sequence_a(tail)
        |> case do
          %Right{value: _values} -> left([error])
          %Left{value: errors} -> left([error | errors])
        end
    end
  end

  @spec validate(value, [(value -> t(error, any))]) :: t([error], value)
        when error: term(), value: term()
  def validate(value, validators) when is_list(validators) do
    results = Enum.map(validators, fn validator -> validator.(value) end)

    case sequence_a(results) do
      %Right{} -> right(value)
      %Left{value: errors} -> left(errors)
    end
  end

  def validate(value, validator) when is_function(validator, 1) do
    case validator.(value) do
      %Right{} -> right(value)
      %Left{value: error} -> left([error])
    end
  end

  def lift_option(maybe, on_none) do
    maybe
    |> fold(
      fn value -> Right.pure(value) end,
      fn -> Left.pure(on_none.()) end
    )
  end

  def lift_predicate(value, predicate, on_false) do
    fold(
      fn -> predicate.(value) end,
      fn -> Right.pure(value) end,
      fn -> Left.pure(on_false.()) end
    )
  end

  @spec from_result({:ok, right} | {:error, left}) :: t(left, right)
        when left: term(), right: term()
  def from_result({:ok, value}), do: Right.pure(value)
  def from_result({:error, reason}), do: Left.pure(reason)

  @spec to_result(t(left, right)) :: {:ok, right} | {:error, left}
        when left: term(), right: term()
  def to_result(either) do
    case either do
      %Right{value: value} -> {:ok, value}
      %Left{value: reason} -> {:error, reason}
    end
  end

  @spec from_try((-> right)) :: t(Exception.t(), right) when right: term()
  def from_try(func) do
    try do
      result = func.()
      Right.pure(result)
    rescue
      exception ->
        Left.pure(exception)
    end
  end

  @spec to_try!(t(left, right)) :: right | no_return
        when left: term(), right: term()
  def to_try!(either) do
    case either do
      %Right{value: value} ->
        value

      %Left{value: reason} ->
        raise reason
    end
  end
end
