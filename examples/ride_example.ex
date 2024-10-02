defmodule Examples.Ride do
  alias Examples.Person

  @type error_message :: String.t()
  @type person_context :: {:ok, Person.t()} | {:error, error_message}

  @spec register_person(String.t(), integer(), integer()) :: person_context()
  def register_person(name, height, tickets) do
    {:ok, Person.new(name, height, tickets)}
  end

  @spec check_valid_height(Person.t()) :: person_context()
  def check_valid_height(%Person{height: height} = person) when height >= 150 and height <= 200 do
    IO.inspect(height, label: "Validating height")
    {:ok, person}
  end

  def check_valid_height(_person) do
    {:error, "Person's height is not valid"}
  end

  @spec check_ticket_availability(Person.t()) :: person_context()
  def check_ticket_availability(%Person{tickets: tickets} = person) when tickets > 0 do
    IO.inspect(tickets, label: "Checking ticket availability")
    {:ok, person}
  end

  def check_ticket_availability(_person) do
    {:error, "Person is out of tickets"}
  end

  @spec take_ride(person_context()) :: person_context()
  def take_ride({:ok, person}) do
    with {:ok, person} <- check_valid_height(person),
         {:ok, person} <- check_ticket_availability(person) do
      {:ok, Person.decrement_ticket(person)}
    else
      error -> error
    end
  end

  def take_ride(error = {:error, _reason}), do: error

  @spec add_ticket(person_context()) :: person_context()
  def add_ticket({:ok, person}) do
    {:ok, Person.increment_ticket(person)}
  end

  def add_ticket(error = {:error, _reason}), do: error
end
