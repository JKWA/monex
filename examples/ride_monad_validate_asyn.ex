defmodule Examples.RideMonadValidationAsync do
  import Monex.Monad, only: [ap: 2, bind: 2, map: 2]

  alias Monex.LazyTaskEither
  alias Examples.Patron

  @type task_either_t :: LazyTaskEither.t(String.t(), Patron.t())

  @spec register_patron(String.t(), integer(), integer()) :: task_either_t()
  def register_patron(name, height, tickets) do
    LazyTaskEither.pure(Patron.new(name, height, tickets))
  end

  @spec check_valid_height(task_either_t()) :: task_either_t()
  def check_valid_height(patron) do
    patron
    |> LazyTaskEither.lift_predicate(
      fn p ->
        :timer.sleep(2000)
        Patron.valid_height?(p)
      end,
      fn -> "Patron's height is not valid" end
    )
  end

  @spec check_ticket_availability(task_either_t()) :: task_either_t()
  def check_ticket_availability(patron) do
    patron
    |> LazyTaskEither.lift_predicate(
      fn p ->
        :timer.sleep(2000)
        Patron.has_ticket?(p)
      end,
      fn -> "Patron is out of tickets" end
    )
  end

  # @spec validate_patron(Patron.t()) :: either_t
  def validate_patron(patron) do
    patron
    |> LazyTaskEither.validate([
      &check_valid_height/1,
      &check_ticket_availability/1
    ])
  end

  @spec take_ride(task_either_t()) :: task_either_t()
  def take_ride(patron) do
    patron
    |> bind(&validate_patron/1)
    |> map(&Patron.decrement_ticket/1)
  end

  @spec add_ticket(task_either_t()) :: task_either_t()
  def add_ticket(patron) do
    LazyTaskEither.pure(&Patron.increment_ticket/1)
    |> ap(patron)
  end
end
