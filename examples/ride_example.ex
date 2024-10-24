defmodule Examples.Ride do
  @moduledoc """
  The `Examples.Ride` module demonstrates how to manage patrons taking a ride at an amusement park,
  focusing on checking their height and ticket availability before allowing them to take the ride.

  This module uses common Elixir patterns such as:
  - **Pattern matching**: For handling different outcomes, like whether the patron meets height and ticket requirements.
  - **The `with` construct**: To chain multiple validations before taking a ride.
  - **Tagged tuples (`{:ok, _}` and `{:error, _}`)**: To indicate success or failure.

  The module provides functions to:
  - Register a new patron with `register_patron/3`.
  - Validate a patron’s height with `check_valid_height/1`.
  - Check if a patron has enough tickets with `check_ticket_availability/1`.
  - Take a ride with `take_ride/1`.
  - Add a ticket to a patron with `add_ticket/1`.
  """

  alias Examples.Patron

  @type error_message :: String.t()
  @type patron_context :: {:ok, Patron.t()} | {:error, error_message}

  @doc """
  Registers a new patron with a name, height, and number of tickets. This function returns an `{:ok, patron}` tuple.

  ## Examples

      iex> {:ok, patron} = Examples.Ride.register_patron("John", 170, 2)
      iex> patron.name
      "John"

  """
  @spec register_patron(String.t(), integer(), integer()) :: patron_context()
  def register_patron(name, height, tickets) do
    {:ok, Patron.new(name, height, tickets)}
  end

  @doc """
  Validates that a patron’s height is within the valid range (150-200 cm).
  Returns `{:ok, patron}` if the height is valid, or `{:error, reason}` otherwise.

  ## Examples

      iex> {:ok, patron} = Examples.Ride.register_patron("Jane", 170, 1)
      iex> Examples.Ride.check_valid_height(patron)
      {:ok, patron}

      iex> {:ok, patron} = Examples.Ride.register_patron("Shorty", 140, 1)
      iex> Examples.Ride.check_valid_height(patron)
      {:error, "Patron's height is not valid"}

  """
  @spec check_valid_height(Patron.t()) :: patron_context()
  def check_valid_height(%Patron{height: height} = patron) when height >= 150 and height <= 200 do
    IO.inspect(height, label: "Validating height")
    {:ok, patron}
  end

  def check_valid_height(_patron) do
    {:error, "Patron's height is not valid"}
  end

  @doc """
  Checks if the patron has enough tickets (at least 1).
  Returns `{:ok, patron}` if the patron has tickets, or `{:error, reason}` otherwise.

  ## Examples

      iex> {:ok, patron} = Examples.Ride.register_patron("Jane", 170, 1)
      iex> Examples.Ride.check_ticket_availability(patron)
      {:ok, patron}

      iex> {:ok, patron} = Examples.Ride.register_patron("No Tickets", 175, 0)
      iex> Examples.Ride.check_ticket_availability(patron)
      {:error, "Patron is out of tickets"}

  """
  @spec check_ticket_availability(Patron.t()) :: patron_context()
  def check_ticket_availability(%Patron{tickets: tickets} = patron) when tickets > 0 do
    IO.inspect(tickets, label: "Checking ticket availability")
    {:ok, patron}
  end

  def check_ticket_availability(_patron) do
    {:error, "Patron is out of tickets"}
  end

  @doc """
  Processes a patron to take a ride by first checking if they have a valid height and enough tickets.
  If both checks pass, it decrements the number of tickets they have and returns `{:ok, patron}`.
  If any check fails, it returns the corresponding `{:error, reason}`.

  This function uses the `with` construct to chain validations.

  ## Examples

      iex> {:ok, patron} = Examples.Ride.register_patron("John", 170, 2)
      iex> Examples.Ride.take_ride({:ok, patron})
      {:ok, %Examples.Patron{tickets: 1}}

      iex> {:ok, patron} = Examples.Ride.register_patron("John", 140, 2)
      iex> Examples.Ride.take_ride({:ok, patron})
      {:error, "Patron's height is not valid"}

  """
  @spec take_ride(patron_context()) :: patron_context()
  def take_ride({:ok, patron}) do
    with {:ok, patron} <- check_valid_height(patron),
         {:ok, patron} <- check_ticket_availability(patron) do
      {:ok, Patron.decrement_ticket(patron)}
    else
      error -> error
    end
  end

  def take_ride(error = {:error, _reason}), do: error

  @doc """
  Adds a ticket to a patron if they are successfully registered.
  Returns `{:ok, patron}` with the updated number of tickets, or the existing `{:error, reason}` if adding a ticket isn't possible.

  ## Examples

      iex> {:ok, patron} = Examples.Ride.register_patron("Jane", 170, 1)
      iex> {:ok, patron} = Examples.Ride.add_ticket({:ok, patron})
      iex> patron.tickets
      2

      iex> {:error, reason} = Examples.Ride.add_ticket({:error, "Failed to register"})
      {:error, "Failed to register"}

  """
  @spec add_ticket(patron_context()) :: patron_context()
  def add_ticket({:ok, patron}) do
    {:ok, Patron.increment_ticket(patron)}
  end

  def add_ticket(error = {:error, _reason}), do: error
end
