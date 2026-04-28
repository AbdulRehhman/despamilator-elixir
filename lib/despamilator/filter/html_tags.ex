defmodule Despamilator.Filter.HtmlTags do
  use Despamilator.Filter,
    name: "HTML tags",
    description: "Detects HTML tags in text"

  alias Despamilator.Subject

  @tags ~w(
    !-- !doctype a abbr acronym address applet area b base basefont bdo big
    blockquote body br button caption center cite code col colgroup dd del
    dfn dir div dl dt em fieldset font form frame frameset h1 h2 h3 h4 h5
    h6 head hr html i iframe img input ins isindex kbd label legend li link
    map menu meta noframes noscript object ol optgroup option p param pre q
    s samp select small span strike strong style sub sup table tbody td
    textarea tfoot th thead title tr tt u ul var xmp
  )

  @impl true
  def parse(%Subject{} = subject) do
    text = String.downcase(subject.text)

    Enum.reduce(@tags, subject, fn tag, acc ->
      opening = count_pattern(text, ~r/<\s*#{Regex.escape(tag)}\W/)
      closing = count_pattern(text, ~r/\W#{Regex.escape(tag)}\s*\/>/)

      if opening > 0 or closing > 0 do
        safest = max(opening, closing)
        Subject.register_match(acc, __MODULE__, 0.6 * safest)
      else
        acc
      end
    end)
  end

  defp count_pattern(text, regex), do: Regex.scan(regex, text) |> length()
end
