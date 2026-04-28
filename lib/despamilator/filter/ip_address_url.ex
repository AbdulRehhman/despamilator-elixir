defmodule Despamilator.Filter.IPAddressURL do
  use Despamilator.Filter,
    name: "IP Address URL",
    description: "Detects IP address URLs"

  alias Despamilator.{Allowlist, Subject}

  @impl true
  def parse(%Subject{} = subject) do
    text = subject.text |> Allowlist.strip() |> String.downcase()

    if Regex.match?(~r{http://\d+\.\d+\.\d+\.\d+}, text) do
      Subject.register_match(subject, __MODULE__, 0.5)
    else
      subject
    end
  end
end
