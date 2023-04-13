defmodule ExVespa.Package.Validation do
    @moduledoc """
    Represents a validation to be be overridden on application.

    Check the `Vespa documentation <https://docs.vespa.ai/en/reference/validation-overrides.html>`__`
    for more detailed information about validations.
    """

    alias __MODULE__

    @keys [
        :id, 
        :until, 
        :comment
    ]

    defstruct @keys

    @type t :: %__MODULE__{
        id: String.t(),
        until: String.t(),
        comment: String.t()
    }

    def validate(%Validation{id: id}) when is_nil(id) do
        raise ArgumentError, "id is required"
    end

    def validate(%Validation{until: until}) when is_nil(until) do
        raise ArgumentError, "until is required"
    end

    def validate(validation), do: validation

    @doc """
    Create a new validation object.

    ## Examples
        iex> alias ExVespa.Package.Validation
        iex> Validation.new("my_validation", "2021-01-01", "my comment")
        %Validation{
            id: "my_validation",
            until: "2021-01-01",
            comment: "my comment"
        }
    """
    @spec new(String.t(), String.t(), String.t()) :: %Validation{}
    def new(id, until, comment \\ "") do
        %Validation{
            id: id,
            until: until,
            comment: comment
        }
        |> validate()
    end
end