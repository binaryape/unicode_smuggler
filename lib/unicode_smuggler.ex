defmodule UnicodeSmuggler do
  @moduledoc """
  Documentation for `UnicodeSmuggler`.
  """

  def encode(text, container \\ "🦆") do
    (for <<b :: 8 <- text>>, do: b)
    |> Enum.map(&byte_to_vs/1)
    |> List.insert_at(0, container)
    |> List.to_string()
  end

  def decode(text) do
    String.to_charlist(text)
    |> Enum.drop(1)
    |> Enum.map(&vs_to_byte/1)
    |> to_string()
  end

  def smuggling?(text) do
    false
  end

  def trim(text) do
    text
  end

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

  defp byte_to_vs(byte) do
    raise "Incorrect value - please pass a byte, not a codepoint"
  end

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
