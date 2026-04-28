# Despamilator

Plugin-based heuristic spam scanner for free-text web form input. Elixir port
of the [Ruby despamilator gem](https://github.com/moowahaha/despamilator) by
Stephen Hardisty.

Each filter inspects the text and contributes a small score; the totals are
summed. A score of `1.0` is a reasonable spam threshold — tune to taste.

## Installation

```elixir
def deps do
  [
    {:despamilator, "~> 2.1"}
  ]
end
```

## Usage

```elixir
result = Despamilator.scan("some text with an <h2> tag qthhg")

result.score
#=> 0.7

Despamilator.Subject.matches(result)
#=> [%{filter: Despamilator.Filter.HtmlTags, score: 0.6},
#    %{filter: Despamilator.Filter.UnusualCharacters, score: 0.1}]

Despamilator.score("hello")
#=> 0.0

Despamilator.matches(Despamilator.gtubs_test_string())
#=> [%{filter: Despamilator.Filter.GtubsTestFilter, score: 100.0}]
```

Each match is `%{filter: module, score: float}`. The filter module exposes
`name/0` and `description/0`.

## Built-in filters

`GtubsTestFilter`, `HtmlTags`, `IPAddressURL`, `LongWords`, `MixedCase`,
`NaughtyWords`, `NoVowels`, `NumbersAndWords`, `ObfuscatedURLs`, `Prices`,
`ScriptTag`, `Shouting`, `SpammyTLDs`, `SquareBrackets`, `TrailingNumber`,
`UnusualCharacters`, `URLs`, `VeryLongDomainName`, `WeirdPunctuation`.

## Writing a filter

```elixir
defmodule MyApp.Filter.DetectLetterA do
  use Despamilator.Filter,
    name: "Detecting the letter A",
    description: "Adds 0.1 if the text contains the letter a"

  alias Despamilator.Subject

  @impl true
  def parse(%Subject{} = subject) do
    if String.contains?(String.downcase(subject.text), "a") do
      Subject.register_match(subject, __MODULE__, 0.1)
    else
      subject
    end
  end
end
```

Register it via config so `Despamilator.scan/1` picks it up:

```elixir
# config/config.exs
config :despamilator,
  filters:
    Despamilator.filters() |> List.wrap() |> Kernel.++([MyApp.Filter.DetectLetterA])
```

Or set the full list outright in `:despamilator, :filters`.

## License

MIT — same as the original Ruby gem.
