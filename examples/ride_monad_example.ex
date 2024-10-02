defmodule Examples.RideMonad do
  import Monex.Monad, only: [ap: 2, bind: 2, map: 2]

  alias Monex.Either
  alias Examples.Person

  @type either_t :: Either.t(String.t(), Person.t())

  @spec register_person(String.t(), integer(), integer()) :: either_t()
  def register_person(name, height, tickets) do
    Either.pure(Person.new(name, height, tickets))
  end

  @spec check_valid_height(either_t()) :: either_t()
  def check_valid_height(person) do
    person
    |> Either.lift_predicate(&Person.is_valid_height/1, fn -> "Person's height is not valid" end)
  end

  @spec check_ticket_availability(either_t()) :: either_t()
  def check_ticket_availability(person) do
    person
    |> Either.lift_predicate(&Person.has_ticket/1, fn -> "Person is out of tickets" end)
  end

  @spec take_ride(either_t()) :: either_t()
  def take_ride(person) do
    person
    |> bind(&check_valid_height/1)
    |> bind(&check_ticket_availability/1)
    |> map(&Person.decrement_ticket/1)
  end

  @spec add_ticket(either_t()) :: either_t()
  def add_ticket(person) do
    Either.pure(&Person.increment_ticket/1)
    |> ap(person)
  end
end
