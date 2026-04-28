defmodule Despamilator.Filter.NumbersAndWords do
  use Despamilator.Filter,
    name: "Numbers next to words",
    description: "Detects unusual number/word combinations"

  alias Despamilator.Subject

  @patterns [~r/\w\d+/, ~r/\d+\w/, ~r/\d+($|\b)/]

  @impl true
  def parse(%Subject{} = subject) do
    text = tidy_text(subject.text)

    {final_subject, _} =
      Enum.reduce(@patterns, {subject, text}, fn regex, {acc, txt} ->
        matches = Regex.scan(regex, txt) |> Enum.map(&hd/1)

        case matches do
          [] ->
            {acc, txt}

          ms ->
            Enum.reduce(ms, {acc, txt}, fn raw, {a, t} ->
              to_remove = to_string(raw)

              new_t =
                if to_remove == "",
                  do: t,
                  else: replace_first(t, to_remove)

              {Subject.register_match(a, __MODULE__, 0.1), new_t}
            end)
        end
      end)

    final_subject
  end

  defp tidy_text(raw) do
    raw
    |> Subject.without_uris()
    |> String.downcase()
    |> String.replace(~r/h[1-6]/, "")
    |> String.replace(~r/(^|\b)\d+($|\b)/, "")
    |> String.replace(~r/(^|\b)\d+(,|\.)\d+($|\b)/, "")
    |> String.replace(~r/(^|\b)\d+(st|nd|rd|th)($|\b)/, "")
  end

  defp replace_first(text, needle) do
    case :binary.match(text, needle) do
      :nomatch ->
        text

      {start, len} ->
        <<head::binary-size(start), _::binary-size(len), tail::binary>> = text
        head <> tail
    end
  end
end
