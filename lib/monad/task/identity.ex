# defmodule LazyAsync do
#   defstruct [:func]

#   @type t(value) :: %__MODULE__{func: (-> Task.t(value))}

#   @spec pure(value) :: t(value) when value: term()
#   def pure(value) do
#     # Return a struct that wraps a function, but doesn't execute it yet
#     %__MODULE__{func: fn -> Task.async(fn -> value end) end}
#   end

#   @spec run(t(value)) :: value when value: term()
#   def run(%__MODULE__{func: func}) do
#     # When run is called, actually start the task and await its result
#     Task.await(func.())
#   end
# end
