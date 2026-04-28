defmodule Despamilator.Filter.ScriptTag do
  use Despamilator.Filter,
    name: "Script tag",
    description: "Searches for variations for the HTML script tag"

  alias Despamilator.Subject

  @impl true
  def parse(%Subject{} = subject) do
    if Regex.match?(~r{<\/?script(>|\s+|\n|\r)}, String.downcase(subject.text)) do
      Subject.register_match(subject, __MODULE__, 1)
    else
      subject
    end
  end
end
