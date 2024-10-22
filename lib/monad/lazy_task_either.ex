defmodule Monex.LazyTaskEither do
  alias Monex.LazyTaskEither.{Right, Left}
  alias Monex.Either
  import Monex.Monad, only: [ap: 2, map: 2]
  import Monex.Foldable, only: [fold: 3]

  @type t(left, right) :: Left.t(left) | Right.t(right)

  @spec right(right) :: t(term(), right) when right: term()
  def right(value), do: Right.pure(value)

  @spec pure(right) :: t(term, right) when right: term()
  def pure(value), do: Right.pure(value)

  @spec left(left) :: t(left, term()) when left: term()
  def left(value), do: Left.pure(value)

  @spec run(t(left, right)) :: left | right when left: term(), right: term()

  def run(%Right{task: task}) do
    Task.await(task.())
  end

  def run(%Left{task: task}) do
    Task.await(task.())
  end

  def lift_predicate(value, predicate, on_false) do
    if predicate.(value) do
      Right.pure(value)
    else
      Left.pure(on_false.())
    end
  end

  def lift_either(%Either.Right{value: right_value}) do
    Right.pure(right_value)
  end

  def lift_either(%Either.Left{value: left_value}) do
    Left.pure(left_value)
  end

  def lift_option(maybe, on_none) do
    maybe
    |> fold(
      fn value -> Right.pure(value) end,
      fn -> Left.pure(on_none.()) end
    )
  end

  @spec sequence([t(left, right)]) :: t(left, [right]) when left: term(), right: term()
  def sequence(list) do
    Enum.reduce_while(list, Right.pure([]), fn
      %Left{} = left, _acc ->
        {:halt, left}

      %Right{} = right, acc ->
        {:cont, ap(map(acc, fn acc_value -> fn value -> [value | acc_value] end end), right)}
    end)
    |> map(&Enum.reverse/1)
  end

  @spec traverse([input], (input -> t(left, right))) :: t(left, [right])
        when input: term(), left: term(), right: term()
  def traverse(list, func) do
    list
    |> Enum.map(func)
    |> sequence()
  end

  @spec from_result({:ok, right} | {:error, left}) :: t(left, right)
        when left: term(), right: term()
  def from_result({:ok, value}), do: Right.pure(value)
  def from_result({:error, reason}), do: Left.pure(reason)

  @spec to_result(t(left, right)) :: {:ok, right} | {:error, left}
        when left: term(), right: term()
  def to_result(lazy_task_either) do
    case run(lazy_task_either) do
      %Either.Right{value: value} -> {:ok, value}
      %Either.Left{value: reason} -> {:error, reason}
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
  def to_try!(lazy_task_either) do
    case run(lazy_task_either) do
      %Either.Right{value: value} -> value
      %Either.Left{value: reason} -> raise reason
    end
  end
end
