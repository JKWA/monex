defmodule Monex.LazyTaskEither.Left do
  @enforce_keys [:task]
  defstruct [:task]

  @type t(left) :: %__MODULE__{task: (-> Task.t(%Monex.Either.Left{value: left}))}

  @spec pure(left) :: t(left) when left: term()
  def pure(value) do
    %__MODULE__{
      task: fn -> Task.async(fn -> %Monex.Either.Left{value: value} end) end
    }
  end

  defimpl Monex.Monad do
    alias Monex.LazyTaskEither.Left

    @spec bind(Left.t(left), (any() -> LazyTaskEither.t(left, result))) :: Left.t(left)
          when left: term(), result: term()
    def bind(%Left{task: task}, _binder) do
      %Left{
        task: fn ->
          Task.async(fn ->
            Task.await(task.())
          end)
        end
      }
    end

    # @spec map(Left.t(left), (any() -> any())) :: Left.t(left)
    def map(%Left{task: task}, _mapper) do
      %Left{task: task}
    end

    @spec ap(Left.t(left), LazyTaskEither.t(left, right)) :: Left.t(left)
          when left: term(), right: term()
    def ap(%Left{} = left, _), do: left
  end

  defimpl String.Chars do
    alias Monex.LazyTaskEither.Left

    def to_string(%Left{task: task}) do
      "Left(#{Task.await(task.())})"
    end
  end
end
