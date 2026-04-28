defmodule Despamilator.Filter do
  @moduledoc """
  Behaviour every filter must implement.

  ## Example

      defmodule Despamilator.Filter.DetectLetterA do
        use Despamilator.Filter,
          name: "Detecting the letter A",
          description: ~s(Detects the letter "a" for demo purposes)

        alias Despamilator.Subject

        @impl true
        def parse(%Subject{} = subject) do
          if String.contains?(String.downcase(subject.text), "a") do
            Subject.register_match(subject, __MODULE__, 0.1)
          else
            subject
          end
        end
      end
  """

  alias Despamilator.Subject

  @callback name() :: String.t()
  @callback description() :: String.t()
  @callback parse(Subject.t()) :: Subject.t()

  defmacro __using__(opts) do
    name = Keyword.fetch!(opts, :name)
    description = Keyword.fetch!(opts, :description)

    quote do
      @behaviour Despamilator.Filter

      @impl true
      def name, do: unquote(name)

      @impl true
      def description, do: unquote(description)
    end
  end
end
