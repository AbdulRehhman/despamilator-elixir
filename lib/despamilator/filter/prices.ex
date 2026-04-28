defmodule Despamilator.Filter.Prices do
  use Despamilator.Filter,
    name: "Prices",
    description: "Detects prices in text."

  alias Despamilator.Subject

  @impl true
  def parse(%Subject{} = subject) do
    count = Subject.count(subject.text, ~r/\$\s*\d+/)

    if count > 0,
      do: Subject.register_match(subject, __MODULE__, 0.075 * count),
      else: subject
  end
end
