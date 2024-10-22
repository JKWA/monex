defmodule Examples.RideMonadOperator do
  import Monex.Operators, only: [~>: 2, >>>: 2, <<~: 2]

  alias Monex.Either
  alias Examples.Patron

  @type either_t :: Either.t(String.t(), Patron.t())

  @spec register_patron(String.t(), integer(), integer()) :: either_t()
  def register_patron(name, height, tickets) do
    Either.pure(Patron.new(name, height, tickets))
  end

  @spec check_valid_height(either_t()) :: either_t()
  def check_valid_height(patron) do
    patron
    |> Either.lift_predicate(&Patron.valid_height?/1, fn -> "Patron's height is not valid" end)
  end

  @spec check_ticket_availability(either_t()) :: either_t()
  def check_ticket_availability(patron) do
    patron
    |> Either.lift_predicate(&Patron.has_ticket?/1, fn -> "Patron is out of tickets" end)
  end

  @spec take_ride(either_t()) :: either_t()
  def take_ride(patron) do
    patron >>>
      (&check_valid_height/1) >>>
      (&check_ticket_availability/1)
    ~> (&Patron.decrement_ticket/1)
  end

  @spec add_ticket(either_t()) :: either_t()
  def add_ticket(patron) do
    Either.pure(&Patron.increment_ticket/1)
    <<~ patron
  end
end
