defmodule Monex.LazyTaskEither.Right do
  @enforce_keys [:task]
  defstruct [:task]

  @type t(right) :: %__MODULE__{task: (-> Task.t(%Monex.Either.Right{value: right}))}

  @spec pure(right) :: t(right) when right: term()
  def pure(value) do
    %__MODULE__{
      task: fn -> Task.async(fn -> %Monex.Either.Right{value: value} end) end
    }
  end

  defimpl Monex.Monad do
    alias Monex.LazyTaskEither.{Right, Left}
    alias Monex.Either

    @spec ap(Right.t((right -> result)), LazyTaskEither.t(left, right)) ::
            LazyTaskEither.t(left, result)
          when left: term(), right: term(), result: term()
    def ap(%Right{task: task_func}, %Right{task: task_value}) do
      %Right{
        task: fn ->
          Task.async(fn ->
            %Either.Right{value: func} = Task.await(task_func.())
            %Either.Right{value: value} = Task.await(task_value.())
            %Either.Right{value: func.(value)}
          end)
        end
      }
    end

    def ap(_, %Left{} = left), do: left

    @spec bind(Right.t(right), (right -> LazyTaskEither.t(left, result))) ::
            LazyTaskEither.t(left, result)
          when left: term(), right: term(), result: term()
    def bind(%Right{task: task}, binder) do
      %Right{
        task: fn ->
          Task.async(fn ->
            case Task.await(task.()) do
              %Monex.Either.Right{value: value} ->
                case binder.(value) do
                  %Right{task: next_task} -> Task.await(next_task.())
                  %Left{task: next_task} -> Task.await(next_task.())
                end

              %Either.Left{value: left_value} ->
                %Either.Left{value: left_value}
            end
          end)
        end
      }
    end

    def map(%Right{task: task}, mapper) do
      %Right{
        task: fn ->
          Task.async(fn ->
            case Task.await(task.()) do
              %Either.Right{value: value} ->
                %Either.Right{value: mapper.(value)}

              %Either.Left{value: error} ->
                %Either.Left{value: error}
            end
          end)
        end
      }
    end
  end

  defimpl String.Chars do
    alias Monex.LazyTaskEither.Right

    def to_string(%Right{task: task}) do
      "Right(#{Task.await(task.())})"
    end
  end
end
