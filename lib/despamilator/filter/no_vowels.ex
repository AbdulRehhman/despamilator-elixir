defmodule Despamilator.Filter.NoVowels do
  use Despamilator.Filter,
    name: "No Vowels",
    description: "Detects things that are all letters but no vowels and separated by spaces"

  alias Despamilator.Subject

  @no_vowels_regex ~r/^[b-df-hj-np-tv-xzB-DF-HJ-NP-TV-XZ]+$/

  @impl true
  def parse(%Subject{} = subject) do
    words =
      subject.text
      |> String.split(~r/\s+/, trim: true)
      |> Enum.filter(&Regex.match?(@no_vowels_regex, &1))

    case length(words) do
      0 -> subject
      n -> Subject.register_match(subject, __MODULE__, n * n / 100)
    end
  end
end
