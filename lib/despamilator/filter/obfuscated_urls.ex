defmodule Despamilator.Filter.ObfuscatedURLs do
  use Despamilator.Filter,
    name: "Obfuscated URLs",
    description: "Finds lame attempts at obfuscating urls."

  alias Despamilator.Subject

  @impl true
  def parse(%Subject{} = subject) do
    text =
      subject.text
      |> Subject.without_uris()
      |> String.downcase()

    count = space_separated_parts(text) + space_separated_characters(text)

    if count > 0,
      do: Subject.register_match(subject, __MODULE__, 4.0 * count / 10),
      else: subject
  end

  defp space_separated_parts(text) do
    Subject.count(text, ~r/www\s+\w+\s+com/)
  end

  defp space_separated_characters(text) do
    Regex.split(~r/[a-z][a-z]/, text)
    |> Enum.count(fn segment ->
      candidate =
        segment
        |> String.trim()
        |> String.replace(~r/\s+/, "")

      Regex.match?(~r/\w{5,}\.\w{2,3}/, candidate)
    end)
  end
end
