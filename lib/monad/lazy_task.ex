defmodule Monex.LazyTask do
  defstruct [:func]

  @type t(value) :: %__MODULE__{func: (-> Task.t(value))}

  @spec pure(value) :: t(value) when value: term()
  def pure(value) do
    %__MODULE__{func: fn -> Task.async(fn -> value end) end}
  end

  @spec run(t(value)) :: value when value: term()
  def run(%__MODULE__{func: func}) do
    Task.await(func.())
  end

  defimpl Monex.Monad do
    alias Monex.LazyTask

    @spec ap(LazyTask.t((value -> result)), LazyTask.t(value)) :: LazyTask.t(result)
          when value: term(), result: term()
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

    @spec bind(LazyTask.t(value), (value -> LazyTask.t(result))) :: LazyTask.t(result)
          when value: term(), result: term()
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

    @spec map(LazyTask.t(value), (value -> result)) :: LazyTask.t(result)
          when value: term(), result: term()
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
  end
end
