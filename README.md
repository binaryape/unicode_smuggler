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

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `unicode_smuggler` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:unicode_smuggler, "~> 0.1.0"}
  ]
end
```

## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/unicode_smuggler>.

## Contributing

You can request new features by creating an [issue](https://github.com/binaryape/unicode_smuggler/issues),
or submit a [pull request](https://github.com/binaryape/unicode_smuggler/pulls) with your contribution.

## Copyright and License

Copyright (c) 2025 Pete Birkinshaw

UnicodeSmuggler is MIT licensed.

## Disclaimer
Use at your own risk

