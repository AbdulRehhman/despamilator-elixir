defmodule Despamilator.Filter.URLs do
  use Despamilator.Filter,
    name: "URLs",
    description: "Detects each url in a string"

  alias Despamilator.{Allowlist, Subject}

  @impl true
  def parse(%Subject{} = subject) do
    text =
      subject.text
      |> Allowlist.strip()
      |> String.downcase()
      |> String.replace(~r{http://\d+\.\d+\.\d+\.\d+}, "")

    matches = Subject.count(text, ~r{https?://})
    capped = min(matches, 2)

    Enum.reduce(1..capped//1, subject, fn _, acc ->
      Subject.register_match(acc, __MODULE__, 0.4)
    end)
  end
end
