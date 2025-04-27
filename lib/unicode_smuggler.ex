defmodule UnicodeSmuggler do
  @moduledoc """
  # UnicodeSmuggler

  Because it seemed like a good idea at the time, this is a quick implementation of the ideas in
  Paul Butler's blog post [Smuggling arbitrary data through an emoji](https://paulbutler.org/2025/smuggling-arbitrary-data-through-an-emoji/)
  as a small Elixir package.

  UnicodeSmuggler is a simple stenography utility that will hide text by attaching it to any Unicode character
  as a list of invisible "variation selectors". The character will render as normal in most unicode-compatible
  applications. UnicodeSmuggler (or anything else compatible with Paul Butler's code) can later be used to extract the hidden text.

  As Paul makes clear this is, at best, an underhand hack and misuse of the Unicode standard. On the other hand,
  it's an interesting trick, I thought it would be fun to implement, and this library may possibly be of use
  for detecting such tricks in the wild.

  ## Features

  * Encode text in a Unicode character
  * Decode text hidden in a Unicode character
  * Find hidden text in a string
  * Remove hidden text from a Unicode character
  * Accidentally confuse JetBrains' IDEs like RubyMine and cause mysterious problems in your own tests
  * Ducks

  ## Examples

  ### Encoding

  ```elixir
  UnicodeSmuggler.encode!("Aw yiss!")
  # => "🦆󠄱󠅧󠄐󠅩󠅙󠅣󠅣"
  ```

  ### Decoding

  ```elixir
  UnicodeSmuggler.decode!("🦆󠄱󠅧󠄐󠅩󠅙󠅣󠅣")
  # => "Aw yiss!"
  ```


  ### Trimming

  ```elixir
  UnicodeSmuggler.trim("🦆󠄱󠅧󠄐󠅩󠅙󠅣󠅣")
  |> UnicodeSmuggler.decode!()
  # => nil
  ```

  """

  @doc """
  Hides the text passed as the first parameter in the container character passed as the second parameter.

  If no container character is specified then a duck will be returned.
  """
  @spec encode!(text :: binary(), container :: binary()) :: binary()
  def encode!(text, container \\ "🦆") do
    :ok = ensure_single!(container)
    (for <<b :: 8 <- to_string(text)>>, do: b)
    |> Enum.map(&byte_to_vs/1)
    |> List.insert_at(0, trim(container))
    |> List.to_string()
  end

  @doc """
  Decodes and returns the hidden text in the specified container character.

  A nil value will be returned if no text has been hidden.

  """
  @spec decode!(container :: binary()) :: binary() | nil
  def decode!(container) do
    :ok = ensure_single!(container)
    String.to_charlist(container)
    |> Enum.drop(1)
    |> Enum.map(&vs_to_byte/1)
    |> then(fn r -> if(Enum.empty?(r), do: nil, else: to_string(r)) end)
  end

  @doc """
  Scans a string for hidden text and returns any found fragments in a list.

  If no hidden text is found an empty list will be returned.
  """
  @spec scan(text :: binary()) :: list(binary())
  def scan(text) do
    text
    |> String.split("")
    |> Enum.map(fn l -> decode!(l) end)
    |> Enum.reject(fn s -> is_nil(s) end)
  end

  @doc """
  Returns true if hidden text is found in the passed string, otherwise false.
  """
  @spec smuggling?(text :: binary()) :: boolean()
  def smuggling?(text) do
    !Enum.empty?(scan(text))
  end

  @doc """
  Accepts a single character and returns it without hidden text. Hopefully.
  """
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
