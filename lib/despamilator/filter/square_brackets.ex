defmodule Despamilator.Filter.SquareBrackets do
  use Despamilator.Filter,
    name: "Square Brackets",
    description: "Detects each square bracket in a string"

  alias Despamilator.Subject

  @impl true
  def parse(%Subject{} = subject) do
    matches = Subject.count(subject.text, ~r/[\[\]]/)

    Enum.reduce(1..matches//1, subject, fn _, acc ->
      Subject.register_match(acc, __MODULE__, 0.05)
    end)
  end
end
