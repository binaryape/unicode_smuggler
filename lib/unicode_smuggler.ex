defmodule UnicodeSmuggler do
  @moduledoc """
  Documentation for `UnicodeSmuggler`.
  """

  @spec encode!(text :: binary(), container :: binary()) :: binary()
  def encode!(text, container \\ "🦆") do
    :ok = ensure_single!(container)
    (for <<b :: 8 <- to_string(text)>>, do: b)
    |> Enum.map(&byte_to_vs/1)
    |> List.insert_at(0, trim(container))
    |> List.to_string()
  end

  @spec decode!(container :: binary()) :: binary() | nil
  def decode!(container) do
    :ok = ensure_single!(container)
    String.to_charlist(container)
    |> Enum.drop(1)
    |> Enum.map(&vs_to_byte/1)
    |> then(fn r -> if(Enum.empty?(r), do: nil, else: to_string(r)) end)
  end

  @spec scan(text :: binary()) :: list(binary())
  def scan(text) do
    text
    |> String.split("")
    |> Enum.map(fn l -> decode!(l) end)
    |> Enum.reject(fn s -> is_nil(s) end)
  end

  @spec smuggling?(text :: binary()) :: boolean()
  def smuggling?(text) do
    !Enum.empty?(scan(text))
  end

  @spec trim(text :: binary()) :: binary()
  def trim(text) do
    :ok = ensure_single!(text)
    text
    |> String.to_charlist()
    |> Enum.take(1)
    |> to_string()
  end

  ##############################

  @spec ensure_single!(text :: binary()) :: atom()
  def ensure_single!(text) do
    if String.length(text) > 1 do
      raise("More than one container character has been passed!")
    else
      :ok
    end
  end

  @spec byte_to_vs(byte :: integer() | binary()) :: integer()
  defp byte_to_vs(byte) when is_binary(byte) do
    :binary.first(byte)
    |> byte_to_vs()
  end

  defp byte_to_vs(byte) when byte < 16 do
    65025 + byte
  end

  defp byte_to_vs(byte) when byte > 16 and byte < 255 do
    917760 + (byte - 16)
  end

  defp byte_to_vs(_) do
    raise "Incorrect value - please pass a byte, not a codepoint"
  end

  @spec vs_to_byte(byte :: integer()) :: binary()
  defp vs_to_byte(vs) when vs in 65024..65039 do
    vs - 65024
    |> :binary.encode_unsigned()
  end

  defp vs_to_byte(vs) when vs in 917760..917999 do
    (vs + 16) - 917760
    |> :binary.encode_unsigned()
  end

  defp vs_to_byte(character) do
    :binary.encode_unsigned(character)
  end

end
