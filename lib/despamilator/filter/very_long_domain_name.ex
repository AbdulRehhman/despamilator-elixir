defmodule Despamilator.Filter.VeryLongDomainName do
  use Despamilator.Filter,
    name: "Very Long Domain Name",
    description: "Detects unusually long domain names."

  alias Despamilator.{Allowlist, Subject}

  @host_regex ~r{https?://([^\s/?#]+)}i

  @impl true
  def parse(%Subject{} = subject) do
    text = Allowlist.strip(subject.text)

    Regex.scan(@host_regex, text, capture: :all_but_first)
    |> Enum.map(fn [host] -> host end)
    |> Enum.reduce(subject, fn host, acc ->
      cond do
        not Regex.match?(~r/(\w|-){5,}\.\w{2,5}/, host) ->
          acc

        true ->
          domain = main_domain_label(host)

          if String.length(domain) > 20,
            do: Subject.register_match(acc, __MODULE__, 0.4),
            else: acc
      end
    end)
  end

  defp main_domain_label(host) do
    host
    |> String.downcase()
    |> String.replace_prefix("www.", "")
    |> String.split(".")
    |> Enum.drop(-1)
    |> List.last()
    |> Kernel.||("")
  end
end
