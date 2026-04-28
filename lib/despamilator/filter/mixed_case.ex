defmodule Despamilator.Filter.MixedCase do
  use Despamilator.Filter,
    name: "Mixed Case String",
    description: "Detects mixed case strings."

  alias Despamilator.Subject

  @impl true
  def parse(%Subject{} = subject) do
    text = Subject.without_uris(subject.text)
    {c1, text} = Subject.remove_and_count(text, ~r/[a-z][A-Z]/)
    {c2, _text} = Subject.remove_and_count(text, ~r/[a-z][A-Z][a-z]/)
    count = c1 + c2

    if count > 0,
      do: Subject.register_match(subject, __MODULE__, 0.1 * count),
      else: subject
  end
end
