defmodule Examples.RideMonadValidationAsync do
  @moduledoc """
  The `Examples.RideMonadValidationAsync` module demonstrates how to manage ride operations using the `LazyTaskEither` monad from the `Monex` library,
  with a focus on asynchronous validation. This module introduces how to handle deferred computations and validate multiple conditions asynchronously.

  This module showcases:
  - Using `LazyTaskEither` to handle asynchronous tasks like validating height or ticket availability.
  - Combining multiple asynchronous validations with `LazyTaskEither.validate/2`.
  - Chaining monadic operations using `bind/2`, `map/2`, and `ap/2`.
  - Simulating asynchronous delays with `:timer.sleep/1` to represent real-world async operations.

  ### Key Functions:
  - `register_patron/3`: Registers a new patron and wraps them in the `LazyTaskEither` monad for asynchronous operations.
  - `check_valid_height/1`: Asynchronously validates a patron’s height.
  - `check_ticket_availability/1`: Asynchronously checks if the patron has enough tickets.
  - `validate_patron/1`: Validates both height and ticket availability asynchronously using `LazyTaskEither.validate/2`.
  - `take_ride/1`: Chains the validation and ticket deduction using monadic operations.
  - `add_ticket/1`: Adds a ticket to the patron using function application in the monad.
  """

  import Monex.Monad, only: [ap: 2, bind: 2, map: 2]

  alias Monex.LazyTaskEither
  alias Examples.Patron

  @type task_either_t :: LazyTaskEither.t(String.t(), Patron.t())

  @doc """
  Registers a new patron with the given name, height, and number of tickets, returning the result wrapped in the `LazyTaskEither` monad.

  ## Examples

      iex> task = Examples.RideMonadValidationAsync.register_patron("John", 170, 2)
      iex> Monex.LazyTaskEither.run(task)
      %Monex.Either.Right{value: %Examples.Patron{name: "John", height: 170, tickets: 2}}

  """
  @spec register_patron(String.t(), integer(), integer()) :: task_either_t()
  def register_patron(name, height, tickets) do
    LazyTaskEither.pure(Patron.new(name, height, tickets))
  end

  @doc """
  Asynchronously checks if the patron’s height is valid (between 150 and 200 cm). If valid, returns `Right(patron)`; otherwise, returns `Left("Patron's height is not valid")`.

  This function simulates an asynchronous check with a 2-second delay using `:timer.sleep/1`.

  ## Examples

      iex> task = Examples.RideMonadValidationAsync.register_patron("John", 170, 2)
      iex> task = Examples.RideMonadValidationAsync.check_valid_height(task)
      iex> Monex.LazyTaskEither.run(task)
      %Monex.Either.Right{value: %Examples.Patron{...}}

      iex> task = Examples.RideMonadValidationAsync.register_patron("Shorty", 140, 1)
      iex> task = Examples.RideMonadValidationAsync.check_valid_height(task)
      iex> Monex.LazyTaskEither.run(task)
      %Monex.Either.Left{value: "Patron's height is not valid"}

  """
  @spec check_valid_height(task_either_t()) :: task_either_t()
  def check_valid_height(patron) do
    patron
    |> LazyTaskEither.lift_predicate(
      fn p ->
        # Simulate async validation delay
        :timer.sleep(2000)
        Patron.valid_height?(p)
      end,
      fn -> "Patron's height is not valid" end
    )
  end

  @doc """
  Asynchronously checks if the patron has enough tickets (at least 1). If the patron has tickets, returns `Right(patron)`; otherwise, returns `Left("Patron is out of tickets")`.

  This function simulates an asynchronous check with a 2-second delay using `:timer.sleep/1`.

  ## Examples

      iex> task = Examples.RideMonadValidationAsync.register_patron("John", 170, 2)
      iex> task = Examples.RideMonadValidationAsync.check_ticket_availability(task)
      iex> Monex.LazyTaskEither.run(task)
      %Monex.Either.Right{value: %Examples.Patron{...}}

      iex> task = Examples.RideMonadValidationAsync.register_patron("Ticketless", 180, 0)
      iex> task = Examples.RideMonadValidationAsync.check_ticket_availability(task)
      iex> Monex.LazyTaskEither.run(task)
      %Monex.Either.Left{value: "Patron is out of tickets"}

  """
  @spec check_ticket_availability(task_either_t()) :: task_either_t()
  def check_ticket_availability(patron) do
    patron
    |> LazyTaskEither.lift_predicate(
      fn p ->
        # Simulate async check delay
        :timer.sleep(2000)
        Patron.has_ticket?(p)
      end,
      fn -> "Patron is out of tickets" end
    )
  end

  @doc """
  Validates that the patron meets all conditions (valid height and ticket availability) asynchronously using `LazyTaskEither.validate/2`.
  If all conditions pass, it returns `Right(patron)`; otherwise, returns `Left` with the appropriate validation error.

  ## Examples

      iex> task = Examples.RideMonadValidationAsync.register_patron("John", 170, 2)
      iex> task = Examples.RideMonadValidationAsync.validate_patron(task)
      iex> Monex.LazyTaskEither.run(task)
      %Monex.Either.Right{value: %Examples.Patron{...}}

      iex> task = Examples.RideMonadValidationAsync.register_patron("Shorty", 140, 1)
      iex> task = Examples.RideMonadValidationAsync.validate_patron(task)
      iex> Monex.LazyTaskEither.run(task)
      %Monex.Either.Left{value: "Patron's height is not valid"}

  """
  @spec validate_patron(task_either_t()) :: task_either_t()
  def validate_patron(patron) do
    patron
    |> LazyTaskEither.validate([
      &check_valid_height/1,
      &check_ticket_availability/1
    ])
  end

  @doc """
  Validates the patron asynchronously and, if successful, decrements the number of tickets they have. If validation fails, returns the `Left` value with the appropriate error message.

  ## Examples

      iex> task = Examples.RideMonadValidationAsync.register_patron("John", 170, 2)
      iex> task = Examples.RideMonadValidationAsync.take_ride(task)
      iex> Monex.LazyTaskEither.run(task)
      %Monex.Either.Right{value: %Examples.Patron{tickets: 1}}

      iex> task = Examples.RideMonadValidationAsync.register_patron("Shorty", 140, 2)
      iex> task = Examples.RideMonadValidationAsync.take_ride(task)
      iex> Monex.LazyTaskEither.run(task)
      %Monex.Either.Left{value: "Patron's height is not valid"}

  """
  @spec take_ride(task_either_t()) :: task_either_t()
  def take_ride(patron) do
    patron
    |> bind(&validate_patron/1)
    |> map(&Patron.decrement_ticket/1)
  end

  @doc """
  Adds a ticket to the patron asynchronously using function application in the `LazyTaskEither` monad.

  ## Examples

      iex> task = Examples.RideMonadValidationAsync.register_patron("John", 170, 2)
      iex> task = Examples.RideMonadValidationAsync.add_ticket(task)
      iex> Monex.LazyTaskEither.run(task)
      %Monex.Either.Right{value: %Examples.Patron{tickets: 3}}

  """
  @spec add_ticket(task_either_t()) :: task_either_t()
  def add_ticket(patron) do
    LazyTaskEither.pure(&Patron.increment_ticket/1)
    |> ap(patron)
  end
end
