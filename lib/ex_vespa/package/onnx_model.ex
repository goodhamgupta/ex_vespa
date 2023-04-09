defmodule ExVespa.Package.OnnxModel do
  @moduledoc """
  Create a Vespa ONNX model config.
                                                                                                            
  Vespa has support for advanced ranking models through it’s tensor API. If you have your model in the ONNX
  format, Vespa can import the models and use them directly. Check the
  `Vespa documentation <https://docs.vespa.ai/en/onnx.html>`__`
  for more detailed information about field sets.
  """

  alias __MODULE__

  @keys [
    :model_name,
    :model_file_path,
    :inputs,
    :outputs,
    :model_file_name,
    :file_path
  ]

  defstruct @keys

  @type t :: %__MODULE__{
          model_name: String.t(),
          model_file_path: String.t(),
          inputs: map(),
          outputs: map(),
          model_file_name: String.t(),
          file_path: String.t()
        }

  defp validate(%__MODULE__{model_name: model_name}) when is_nil(model_name) do
    raise ArgumentError, "model_name is required"
  end

  defp validate(%__MODULE__{model_file_path: model_file_path}) when is_nil(model_file_path) do
    raise ArgumentError, "model_file_path is required"
  end

  defp validate(%__MODULE__{inputs: inputs}) when is_nil(inputs) do
    raise ArgumentError, "inputs is required"
  end

  defp validate(%__MODULE__{outputs: outputs}) when is_nil(outputs) do
    raise ArgumentError, "outputs is required"
  end

  defp validate(input), do: input

  @doc """
  Create a new ONNX model config.

  ## Example
      
      iex> alias ExVespa.Package.OnnxModel
      iex> OnnxModel.new(nil, "model.onnx", %{}, %{})
      ** (ArgumentError) model_name is required

      iex> alias ExVespa.Package.OnnxModel
      iex> OnnxModel.new("my_model", nil, %{}, %{})
      ** (ArgumentError) model_file_path is required

      iex> alias ExVespa.Package.OnnxModel
      iex> OnnxModel.new("my_model", "model.onnx", nil, %{})
      ** (ArgumentError) inputs is required

      iex> alias ExVespa.Package.OnnxModel
      iex> OnnxModel.new("my_model", "model.onnx", %{}, nil)
      ** (ArgumentError) outputs is required


      iex> alias ExVespa.Package.OnnxModel
      iex> OnnxModel.new(
      ...>   "my_model",
      ...>   "model.onnx",
      ...>   %{
      ...>     input_ids: "input_ids",
      ...>     token_type_ids: "token_type_ids",
      ...>     attention_mask: "attention_mask",
      ...>   },
      ...>   %{
      ...>     logits: "logits"
      ...>   }
      ...> )
      %ExVespa.Package.OnnxModel{
        model_name: "my_model",
        model_file_path: "model.onnx",
        inputs: %{
          input_ids: "input_ids",
          token_type_ids: "token_type_ids",
          attention_mask: "attention_mask",
        },
        outputs: %{
          logits: "logits" 
        },
        model_file_name: "my_model.onnx",
        file_path: "files/my_model.onnx"
      }
  """
  def new(model_name, model_file_path, inputs, outputs) do
    %__MODULE__{
      model_name: model_name,
      model_file_path: model_file_path,
      inputs: inputs,
      outputs: outputs,
      model_file_name: "#{model_name}.onnx",
      file_path: Path.join("files", "#{model_name}.onnx")
    }
    |> validate()
  end

  def %OnnxModel{
        model_name: lmodel_name,
        model_file_path: lmodel_file_path,
        inputs: linputs,
        outputs: loutputs
      } = %OnnxModel{
        model_name: rmodel_name,
        model_file_path: rmodel_file_path,
        inputs: rinputs,
        outputs: routputs
      } do
    lmodel_name == rmodel_name and
      lmodel_file_path == rmodel_file_path and
      linputs == rinputs and
      loutputs == routputs
  end
end
