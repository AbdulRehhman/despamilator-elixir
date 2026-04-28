# Despamilator

[![Hex.pm](https://img.shields.io/hexpm/v/despamilator.svg)](https://hex.pm/packages/despamilator)
[![Hex.pm](https://img.shields.io/hexpm/dt/despamilator.svg)](https://hex.pm/packages/despamilator)
[![Hex Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/despamilator)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Plugin-based heuristic spam scanner for free-text input — designed for web
form submissions, contact forms, comment fields, and the like. An Elixir port
of the original [Ruby despamilator gem][upstream] by Stephen Hardisty.

A score of `1.0` and above is a reasonable spam threshold. Tune to taste.

[upstream]: https://github.com/moowahaha/despamilator

## Installation

Add `:despamilator` to your `mix.exs`:

```elixir
def deps do
  [
    {:despamilator, "~> 2.1"}
  ]
end
```

Then:

```bash
mix deps.get
```

No runtime supervision tree, no GenServers, no external services. Pure
function calls.

## Quickstart

```elixir
result = Despamilator.scan("Visit http://12.34.56.78/ <script>alert(1)</script>")

result.score
#=> 1.9

Despamilator.Subject.matches(result)
#=> [
#     %{filter: Despamilator.Filter.ScriptTag, score: 1.0},
#     %{filter: Despamilator.Filter.IPAddressURL, score: 0.5},
#     %{filter: Despamilator.Filter.URLs, score: 0.4}
#   ]
```

Convenience helpers when you only want one piece:

```elixir
Despamilator.score("hello there")           #=> 0.0
Despamilator.matches("FREE VIAGRA NOW")     #=> [%{filter: ..., score: ...}]
Despamilator.gtubs_test_string()            #=> magic string that scores 100+
```

Each match is a plain map: `%{filter: module, score: float}`. The filter
module exposes `name/0` and `description/0` for display:

```elixir
Despamilator.matches(text)
|> Enum.each(fn m ->
  IO.puts("#{m.filter.name()} (#{m.score})")
  IO.puts("  #{m.filter.description()}")
end)
```

## Threshold

```
0.0     clean
< 1.0   probably fine
≥ 1.0   likely spam (recommended threshold)
≥ 100   GTUBS test string
```

```elixir
def spam?(text), do: Despamilator.score(text) >= 1.0
```

## Built-in filters

| Filter | What it catches | Score per hit |
|--------|-----------------|---------------|
| `GtubsTestFilter` | Magic test string | +100 |
| `ScriptTag` | `<script>` variants | +1.0 |
| `HtmlTags` | Opening/closing HTML element pairs | +0.6 each |
| `IPAddressURL` | `http://X.X.X.X/` URLs | +0.5 |
| `URLs` | First two http(s) URLs | +0.4 each |
| `VeryLongDomainName` | Domain label > 20 chars | +0.4 |
| `Shouting` | Proportion of all-caps text | up to +0.5 |
| `MixedCase` | `cAmElCaSe` words | +0.1 per pair |
| `LongWords` | Non-URL words > 20 chars | +0.1 each |
| `NaughtyWords` | English profanity + Roman & Urdu-script gaaliyan | +0.8 each |
| `NoVowels` | Pseudo-words with no vowels | n²/100 |
| `NumbersAndWords` | Digits adjacent to letters | +0.1 each |
| `ObfuscatedURLs` | `b a l l s . c o m` style | +0.4 per chunk |
| `Prices` | `$N` occurrences | +0.075 each |
| `SpammyTLDs` | `.info` / `.biz` / `.xxx` | +0.05 each |
| `SquareBrackets` | Every `[` or `]` | +0.05 each |
| `TrailingNumber` | Cache-busting trailing digits | +0.1 |
| `UnusualCharacters` | Odd 2/3-char n-grams | +0.05 each |
| `WeirdPunctuation` | Odd punctuation patterns | +0.03 per match |

## URL allow-list

Stop the URL-aware filters (`URLs`, `IPAddressURL`, `SpammyTLDs`,
`VeryLongDomainName`) from penalising your own domains:

```elixir
# config/config.exs
import Config

config :despamilator,
  url_allowlist: [
    "pakwheels.com",          # exact host or any subdomain
    "your-app.com",
    ~r/\.gov$/                # regex matched against the lowercased host
  ]
```

* String entries match the host exactly **or** as a suffix —
  `"pakwheels.com"` allows `pakwheels.com`, `www.pakwheels.com`, and
  `forums.pakwheels.com` but not `evilpakwheels.com`.
* Regex entries are tested against the lowercased host. Anchor with `^`
  and `$` if you need exact matching.

Programmatic API:

```elixir
Despamilator.Allowlist.host_allowed?("www.pakwheels.com")  #=> true
Despamilator.Allowlist.entries()                            #=> configured list
Despamilator.Allowlist.strip(text)                          #=> text with allow-listed URLs blanked
```

## Custom filters

Filters are plain modules implementing the `Despamilator.Filter` behaviour.
The `use` macro wires `name/0` and `description/0` from the keyword opts:

```elixir
defmodule MyApp.Filter.AllCapsWords do
  use Despamilator.Filter,
    name: "All-caps words",
    description: "Counts SHOUTED words"

  alias Despamilator.Subject

  @impl true
  def parse(%Subject{} = subject) do
    matches = Subject.count(subject.text, ~r/\b[A-Z]{4,}\b/)

    if matches > 0,
      do: Subject.register_match(subject, __MODULE__, 0.05 * matches),
      else: subject
  end
end
```

Register it via config so `Despamilator.scan/1` picks it up alongside the
built-ins:

```elixir
# config/config.exs
import Config

config :despamilator,
  filters: Despamilator.filters() ++ [MyApp.Filter.AllCapsWords]
```

Or replace the entire list outright (e.g. if you want to drop `NaughtyWords`):

```elixir
config :despamilator,
  filters: [
    Despamilator.Filter.HtmlTags,
    Despamilator.Filter.ScriptTag,
    Despamilator.Filter.URLs,
    MyApp.Filter.AllCapsWords
  ]
```

## Phoenix / Plug example

```elixir
defmodule MyAppWeb.ContactController do
  use MyAppWeb, :controller

  @spam_threshold 1.0

  def create(conn, %{"message" => params}) do
    text = params["body"] || ""

    if Despamilator.score(text) >= @spam_threshold do
      conn
      |> put_status(:bad_request)
      |> json(%{error: "Looks like spam"})
    else
      # ...persist + send email...
      json(conn, %{ok: true})
    end
  end
end
```

## CLI

A small score runner is bundled at `scripts/despamilator_score.exs`:

```bash
mix run scripts/despamilator_score.exs path/to/email.txt
mix run scripts/despamilator_score.exs 'corpus/*.txt'
```

It prints the file contents, total score, per-filter breakdown, and a
sorted summary across all files.

## Subject helpers

If you write your own filter, `Despamilator.Subject.Text` has the same
helpers the built-ins use:

```elixir
alias Despamilator.Subject.Text

Text.without_uris("hello http://example.com world")  #=> "hello world"
Text.words("hello-there you   rule")                  #=> ["hello", "there", "you", "rule"]
Text.count("yXyXy", ~r/X/)                            #=> 2
Text.remove_and_count("yXyXy", ~r/X/)                 #=> {2, "yyy"}
```

## License

MIT — see [LICENSE](LICENSE). Original Ruby gem © 2011 Stephen Hardisty,
also MIT.
