defmodule Despamilator.Filter.SpammyTLDs do
  use Despamilator.Filter,
    name: "Spammy TLDs",
    description: "Detects TLDs that are more commonly associated with spam."

  alias Despamilator.Subject

  @impl true
  def parse(%Subject{} = subject) do
    matches = Subject.count(subject.text, ~r/\w{5,}\.(info|biz|xxx)\b/)

    if matches > 0,
      do: Subject.register_match(subject, __MODULE__, 0.05 * matches),
      else: subject
  end
end
