defmodule Despamilator.Filter.Shouting do
  use Despamilator.Filter,
    name: "Shouting",
    description: "Detects and scores shouting (all caps)"

  alias Despamilator.Subject

  @impl true
  def parse(%Subject{} = subject) do
    text = Regex.replace(~r/<\/?[^>]*>/, subject.text, "")

    cond do
      String.length(text) < 20 ->
        subject

      true ->
        uppercased =
          Regex.scan(~r/[A-Z][A-Z]+/, text)
          |> Enum.map(fn [m] -> String.length(m) end)
          |> Enum.sum()

        lowercased = Subject.count(text, ~r/[a-z]/)

        if uppercased > 0 do
          score = uppercased / (uppercased + lowercased) * 0.5
          Subject.register_match(subject, __MODULE__, score)
        else
          subject
        end
    end
  end
end
