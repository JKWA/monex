# Monex

Elixir is a dynamically typed language and lacks the static type system typically used in functional languages to enforce monadic patterns. Instead, Elixir leverages pattern matching, `defimpl`, and branded structs to create structured abstractions that behave like monads. Monex builds on these principles to provide useful tools for functional programming.

## Features

Monex provides various tools for working with monads, including constructors, refinements, folding, matching, and more.

### Monads

Monads in Monex support operations like `bind`, `map`, and `ap`, allowing for flexible control over computations:

- **Identity**: A base monad that returns its value unchanged.
- **Maybe**: Encapsulates optional values as `Just` (a value) or `Nothing` (no value).
- **Either**: Represents a computation that can result in either `Right` (success) or `Left` (error).
- **LazyTask**: Handles asynchronous computations that can be deferred.
- **LazyTaskEither**: Handles asynchronous computations that may result in success or failure, with deferred execution.

### Operators

Monex provides operators that offer a more concise syntax for working with monads:

- **`~>/2`**: Functor map. Applies a function to the value in a monad to transform the value within the monad's context.
- **`~>>/2`**: Monad bind. Chains computations, passing the result of one monad to a function that returns another monad of the same type.
- **`<<~/2`**: Applicative apply. Applies a function wrapped in a monad to a value in another monad of the same type.

*Operators make code more compact, but they come with a trade-off in readability compared to Elixir’s standard pipe syntax.*

### Constructors

Monex provides constructors for each monad, allowing values to be wrapped in the appropriate monadic context:

- **`pure/1`**: Wraps a value in a monad, initializing a computation with a known value.
- **`just/1`**: Constructs a `Just` for the `Maybe` monad, representing the presence of a value.
- **`nothing/0`**: Constructs a `Nothing` for the `Maybe` monad, representing the absence of a value.

### Refinements

Refinements allow for inspection of monadic values and the extraction of useful information:

- **`just?/1`**: Checks if a `Maybe` value is a `Just`.
- **`nothing?/1`**: Checks if a `Maybe` value is `Nothing`.

### Comparison

Monex provides tools for comparing monadic values:

- **Equality**: Monads can be compared for equality using custom functions to determine if they represent the same state or value.
- **Order**: Monex supports ordering monads based on their contained values, enabling sorting or comparison between monadic values.

### Folding

Folding collapses a monadic structure into a single result by applying functions in a specific order. Monex defines two core folding operations:

- **`fold_l/3`**: Folds a structure from the left, applying functions sequentially from left to right.
- **`fold_r/3`**: Folds a structure from the right, applying functions from right to left.

Folding is used to reduce monadic or predicate-based structures to a single value, such as success or failure.

### Matching

Matching provides a way to handle different cases of a monadic value (`Right`, `Left`, `Just`, `Nothing`) and define behavior for each scenario:

- **`get_or_else/2`**: Retrieves a value from a monad or provides a default value if the monad represents a failure.
- **`filter_or_else/3`**: Filters the value inside a monad based on a predicate, converting successes to failures if the condition is not met.

### Sequencing

Monads allow for chaining multiple computations in sequence, passing results from one computation to the next:

- **`sequence/1`**: Sequences a list of monads, returning a monad with a list of all `Right` or `Just` values, or the first `Left` or `Nothing` encountered.
- **`traverse/2`**: Applies a function to a list that returns monads, sequencing the results and propagating successes or failures.

### Validation

Monex supports validation workflows by combining multiple checks into a single monadic operation:

- **`sequence_a/1`**: Sequences a list of applicatives without short-circuiting, collecting all successes if all values are valid or accumulating all errors if any failures occur. This ensures that the entire list is processed, even if some elements fail, making it suitable for scenarios where gathering all errors is preferred over stopping at the first failure.

### Lifting

Lifting provides functionality to convert values between monads or wrap non-monadic values in a monadic context:

- **`lift_predicate/3`**: Lifts a value into a monad based on a predicate. If the predicate holds, the value is wrapped in a success; otherwise, it becomes a failure.
- **`lift_option/2`**: Converts a `Maybe` monad into an `Either` monad. If the `Maybe` is `Nothing`, it returns a `Left` with an error message.

### Elixir Interops

Monex integrates with common Elixir idioms and data structures like `{:ok, value}` and `{:error, reason}` tuples:

- **`from_result/1`**: Converts a result tuple (`{:ok, value}` or `{:error, reason}`) into an `Either` monad.
- **`to_result/1`**: Converts an `Either` monad back into a result tuple.
- **`from_try/1`**: Wraps a function in an `Either` monad, catching exceptions as `Left`.
- **`to_try!/1`**: Extracts a value from an `Either` monad or raises an exception if it is a `Left`.

## Installation

To use Monex, add it to the list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:monex, "~> 0.1.0"}
  ]
end
```

Then, run the following command to fetch the dependencies:

```bash
mix deps.get
```

## Documentation

Full documentation is available on [GitHub Pages](https://jkwa.github.io/monex/readme.html).

## Contributing

1. Fork the repository.
2. Create a new branch for the feature or bugfix (`git checkout -b feature-branch`).
3. Commit changes (`git commit -am 'Add new feature'`).
4. Push the branch (`git push origin feature-branch`).
5. Create a pull request.

## License

This project is licensed under the MIT License.
