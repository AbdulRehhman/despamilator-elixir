defmodule Despamilator.Filter.IPAddressURL do
  use Despamilator.Filter,
    name: "IP Address URL",
    description: "Detects IP address URLs"

  alias Despamilator.Subject

  @impl true
  def parse(%Subject{} = subject) do
    if Regex.match?(~r{http://\d+\.\d+\.\d+\.\d+}, String.downcase(subject.text)) do
      Subject.register_match(subject, __MODULE__, 0.5)
    else
      subject
    end
  end
end
