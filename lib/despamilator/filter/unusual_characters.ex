defmodule Despamilator.Filter.UnusualCharacters do
  use Despamilator.Filter,
    name: "Unusual Characters",
    description: "Detects and scores each occurrence of an unusual 2 or 3 character combination"

  alias Despamilator.Subject

  @external_resource Path.join([:code.priv_dir(:despamilator) |> to_string(), "unusual_characters.txt"])

  combos =
    @external_resource
    |> File.read!()
    |> String.split(~r/\r?\n/, trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.into(MapSet.new())

  @combos combos

  @impl true
  def parse(%Subject{} = subject) do
    tokens =
      subject.text
      |> Subject.without_uris()
      |> tokenize()

    Enum.reduce(tokens, subject, fn token, acc ->
      if MapSet.member?(@combos, token),
        do: Subject.register_match(acc, __MODULE__, 0.05),
        else: acc
    end)
  end

  # Mirrors the Ruby tokenizer (which has its quirks): the `word[i, i+3]` slice
  # produces a window whose length depends on `i`. We replicate that exactly.
  defp tokenize(text) do
    text
    |> String.downcase()
    |> String.split(~r/[^a-z]/, trim: true)
    |> Enum.flat_map(&tokens_for_word/1)
  end

  defp tokens_for_word(word) do
    chars = String.graphemes(word)
    len = length(chars)

    Enum.flat_map(0..(len - 1)//1, fn i ->
      window_len = i + 3
      take = min(window_len, len - i)
      substr = chars |> Enum.slice(i, take) |> Enum.join()

      tokens = []
      tokens = if String.length(substr) == 3, do: [substr | tokens], else: tokens

      tokens =
        if String.length(substr) > 1,
          do: [String.slice(substr, 0, 2) | tokens],
          else: tokens

      tokens
    end)
  end
end
