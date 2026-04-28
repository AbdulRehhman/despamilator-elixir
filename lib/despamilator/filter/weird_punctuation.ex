defmodule Despamilator.Filter.WeirdPunctuation do
  use Despamilator.Filter,
    name: "Weird Punctuation",
    description: "Detects unusual use of punctuation."

  alias Despamilator.Subject

  @punctuation_chars ~w(~ ` ! @ # $ % ^ & * _ - + = , / ? | \\ : ;)
  @punct_alt @punctuation_chars |> Enum.map(&Regex.escape/1) |> Enum.join("|")

  @impl true
  def parse(%Subject{} = subject) do
    text =
      subject.text
      |> Subject.without_uris()
      |> String.downcase()
      |> String.replace(~r/\w&\w/, "xx")
      |> String.replace(~r/[a-z](!|\?)(\s|$)/, "x")
      |> String.replace(~r/(?:#{@punct_alt}){20,}/, "")

    {text, total} = {text, 0}

    {text, total} = remove_count(text, total, ~r/(?:\W|\s|^)(#{@punct_alt})/)
    {text, total} = remove_count(text, total, ~r/\w,\w/)
    {text, total} = remove_count(text, total, ~r/\w\w\.\w/)
    {text, total} = remove_count(text, total, ~r/\w\.\w\w/)
    {text, total} = remove_count(text, total, ~r/(#{@punct_alt})(#{@punct_alt})/)
    {text, total} = remove_count(text, total, ~r/(#{@punct_alt})$/)
    {_text, total} = remove_count(text, total, ~r/(?:\W|\s|^)\d+(#{@punct_alt})/)

    if total > 0,
      do: Subject.register_match(subject, __MODULE__, 0.03 * total),
      else: subject
  end

  defp remove_count(text, total, regex) do
    {n, new_text} = Subject.remove_and_count(text, regex)
    {new_text, total + n}
  end
end
