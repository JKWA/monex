defmodule Monex.LazyTask do
  @moduledoc """
  The `Monex.LazyTask` module provides an implementation of a lazily evaluated task monad.
  This monad allows for deferred execution of tasks, wrapping a function that can be executed asynchronously and awaited later.

  The `LazyTask` monad supports mapping, binding, and function application on asynchronous computations.
  """

  defstruct [:func]

  @type t(value) :: %__MODULE__{
          func: (-> Task.t(value))
        }

  @doc """
  Creates a `LazyTask` that wraps a value, returning a task that, when run, resolves to that value.

  ## Examples

      iex> task = Monex.LazyTask.pure(42)
      iex> Monex.LazyTask.run(task)
      42
  """
  @spec pure(value) :: t(value) when value: any()
  def pure(value) do
    %__MODULE__{
      func: fn -> Task.async(fn -> value end) end
    }
  end

  @doc """
  Runs the `LazyTask`, awaiting the task and returning its resolved value.

  ## Examples

      iex> task = Monex.LazyTask.pure(42)
      iex> Monex.LazyTask.run(task)
      42
  """
  @spec run(t(value)) :: value when value: any()
  def run(%__MODULE__{func: func}) do
    Task.await(func.())
  end

  defimpl Monex.Monad do
    alias Monex.LazyTask

    @doc """
    Applies a function to the value inside the `LazyTask`, producing a new `LazyTask` with the result.

    ## Examples

        iex> task = Monex.LazyTask.pure(10)
        iex> mapped_task = Monex.Monad.map(task, fn x -> x * 2 end)
        iex> Monex.LazyTask.run(mapped_task)
        20
    """
    @spec map(
            LazyTask.t(value),
            (value -> result)
          ) :: LazyTask.t(result)
          when value: any(), result: any()
    def map(%LazyTask{func: func}, mapper) do
      %LazyTask{
        func: fn ->
          Task.async(fn ->
            value = Task.await(func.())
            mapper.(value)
          end)
        end
      }
    end

    @doc """
    Binds a `LazyTask` to a function that returns a new `LazyTask`, chaining the computations.

    ## Examples

        iex> task = Monex.LazyTask.pure(10)
        iex> bound_task = Monex.Monad.bind(task, fn x -> Monex.LazyTask.pure(x + 5) end)
        iex> Monex.LazyTask.run(bound_task)
        15
    """
    @spec bind(
            LazyTask.t(value),
            (value -> LazyTask.t(result))
          ) :: LazyTask.t(result)
          when value: any(), result: any()
    def bind(%LazyTask{func: func}, binder) do
      %LazyTask{
        func: fn ->
          Task.async(fn ->
            value = Task.await(func.())
            %LazyTask{func: next_func} = binder.(value)
            Task.await(next_func.())
          end)
        end
      }
    end

    @doc """
    Applies a function from one `LazyTask` to the value in another `LazyTask`, producing a new `LazyTask` with the result.

    ## Examples

        iex> func_task = Monex.LazyTask.pure(fn x -> x * 2 end)
        iex> value_task = Monex.LazyTask.pure(10)
        iex> result_task = Monex.Monad.ap(func_task, value_task)
        iex> Monex.LazyTask.run(result_task)
        20
    """
    @spec ap(
            LazyTask.t((value -> result)),
            LazyTask.t(value)
          ) :: LazyTask.t(result)
          when value: any(), result: any()
    def ap(%LazyTask{func: func_task}, %LazyTask{func: value_task}) do
      %LazyTask{
        func: fn ->
          Task.async(fn ->
            func = Task.await(func_task.())
            value = Task.await(value_task.())
            func.(value)
          end)
        end
      }
    end
  end
end
