defmodule Despamilator.Filter.TrailingNumber do
  use Despamilator.Filter,
    name: "Trailing Number",
    description: "Detects a trailing cache busting number"

  alias Despamilator.Subject

  @impl true
  def parse(%Subject{} = subject) do
    stripped = Subject.without_uris(subject.text)

    if Regex.match?(~r/\b\d+\s*$/, stripped),
      do: Subject.register_match(subject, __MODULE__, 0.1),
      else: subject
  end
end
