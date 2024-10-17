defmodule Examples.RideLazyTaskMonad do
  import Monex.Monad, only: [ap: 2, bind: 2, map: 2]

  alias LazyTaskEither
  alias Examples.Patron

  @type task_either_t :: LazyTaskEither.t(String.t(), Patron.t())

  @spec register_patron(String.t(), integer(), integer()) :: task_either_t()
  def register_patron(name, height, tickets) do
    LazyTaskEither.pure(Patron.new(name, height, tickets))
  end

  @spec check_valid_height(task_either_t()) :: task_either_t()
  def check_valid_height(patron) do
    patron
    |> LazyTaskEither.lift_predicate(&Patron.valid_height?/1, fn ->
      "Patron's height is not valid"
    end)
  end

  @spec check_ticket_availability(task_either_t()) :: task_either_t()
  def check_ticket_availability(patron) do
    patron
    |> LazyTaskEither.lift_predicate(&Patron.has_ticket?/1, fn -> "Patron is out of tickets" end)
  end

  @spec take_ride(task_either_t()) :: task_either_t()
  def take_ride(patron) do
    result =
      patron
      |> bind(&check_valid_height/1)
      |> bind(&check_ticket_availability/1)
      |> map(&Patron.decrement_ticket/1)

    result
  end

  @spec add_ticket(task_either_t()) :: task_either_t()
  def add_ticket(patron) do
    LazyTaskEither.pure(&Patron.increment_ticket/1)
    |> ap(patron)
  end
end
