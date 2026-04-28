defmodule Despamilator.Filter.GtubsTestFilter do
  use Despamilator.Filter,
    name: "GTubs Test Filter",
    description:
      "Detects the special test string (Despamilator.gtubs_test_string) and assigns a big score."

  alias Despamilator.Subject

  @impl true
  def parse(%Subject{} = subject) do
    if subject.text == Despamilator.gtubs_test_string() do
      Subject.register_match(subject, __MODULE__, 100)
    else
      subject
    end
  end
end
