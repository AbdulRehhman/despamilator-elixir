defmodule Despamilator.Filter.LongWords do
  use Despamilator.Filter,
    name: "Long Words",
    description: "Detects long and unbroken strings"

  alias Despamilator.Subject

  @impl true
  def parse(%Subject{} = subject) do
    subject.text
    |> Subject.without_uris()
    |> Subject.words()
    |> Enum.reduce(subject, fn word, acc ->
      if String.length(word) > 20,
        do: Subject.register_match(acc, __MODULE__, 0.1),
        else: acc
    end)
  end
end
