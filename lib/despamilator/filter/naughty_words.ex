defmodule Despamilator.Filter.NaughtyWords do
  use Despamilator.Filter,
    name: "Naughty Words",
    description: "Detects cheeky words"

  alias Despamilator.Subject

  @words ~w(
    underage penis viagra bondage cunt fuck shit dick tits nude dicks
    shemale dildo porn cock pussy clit preteen lolita
  )

  @impl true
  def parse(%Subject{} = subject) do
    text = String.downcase(subject.text)

    Enum.reduce(@words, subject, fn word, acc ->
      if Regex.match?(~r/\b#{word}s?\b/, text),
        do: Subject.register_match(acc, __MODULE__, 0.1),
        else: acc
    end)
  end
end
