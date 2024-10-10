defmodule Examples.Ride do
  alias Examples.Patron

  @type error_message :: String.t()
  @type patron_context :: {:ok, Patron.t()} | {:error, error_message}

  @spec register_patron(String.t(), integer(), integer()) :: patron_context()
  def register_patron(name, height, tickets) do
    {:ok, Patron.new(name, height, tickets)}
  end

  @spec check_valid_height(Patron.t()) :: patron_context()
  def check_valid_height(%Patron{height: height} = patron) when height >= 150 and height <= 200 do
    IO.inspect(height, label: "Validating height")
    {:ok, patron}
  end

  def check_valid_height(_patron) do
    {:error, "Patron's height is not valid"}
  end

  @spec check_ticket_availability(Patron.t()) :: patron_context()
  def check_ticket_availability(%Patron{tickets: tickets} = patron) when tickets > 0 do
    IO.inspect(tickets, label: "Checking ticket availability")
    {:ok, patron}
  end

  def check_ticket_availability(_patron) do
    {:error, "Patron is out of tickets"}
  end

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

  @spec add_ticket(patron_context()) :: patron_context()
  def add_ticket({:ok, patron}) do
    {:ok, Patron.increment_ticket(patron)}
  end

  def add_ticket(error = {:error, _reason}), do: error
end
