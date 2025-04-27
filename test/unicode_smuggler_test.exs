defmodule UnicodeSmugglerTest do
  use ExUnit.Case
  doctest UnicodeSmuggler


  describe "encode!/2" do

    test "hides text in the specified character" do
      #assert "🌭󠄱󠅧󠄐󠅩󠅙󠅣󠅣󠄑󠇠" = UnicodeSmuggler.encode!("Aw yiss!🌭 ", "🌭")
      assert [
               127789,
               917809,
               917863,
               917776,
               917865,
               917849,
               917859,
               917859,
               917777,
               917984,
               917903,
               917884,
               917917
             ] = UnicodeSmuggler.encode!("Aw yiss!🌭", "🌭")
                 |> String.to_charlist()
    end

    test "if no character is specified, a duck is provided." do
      assert [
               129414,
               917809,
               917863,
               917776,
               917865,
               917849,
               917859,
               917859,
               917777,
               917984,
               917903,
               917884,
               917917
             ] = UnicodeSmuggler.encode!("Aw yiss!🌭")
                 |> String.to_charlist()
    end

    test "A plain character is returned if nil was passed as the text" do
      assert "🦆" = UnicodeSmuggler.encode!(nil)
      assert [129414] = String.to_charlist(UnicodeSmuggler.encode!(nil))
    end

    test "A plain character is returned if an empty string was passed as the text" do
      assert "🦆" = UnicodeSmuggler.encode!("")
      assert [129414] = String.to_charlist(UnicodeSmuggler.encode!(""))
    end

    test "An exception is raised if two or more container characters are provided" do
      assert_raise RuntimeError, fn -> UnicodeSmuggler.encode!("hello", "AA") end
    end

    test "Works with existing, public examples" do
      assert [128512, 917848, 917845, 917852, 917852, 917855] = String.to_charlist(
               UnicodeSmuggler.encode!("hello", "😀")
             )
    end

  end

  describe "decode!/1" do

    test "if passed one character with hidden text, the text is returned" do
      assert "Aw yiss!🌭" = UnicodeSmuggler.decode!(UnicodeSmuggler.encode!("Aw yiss!🌭"))
    end

    test "An exception is raised if two or more container characters are provided" do
      assert_raise RuntimeError, fn -> UnicodeSmuggler.decode!("AA") end
    end

    test "nil is returned if no hidden text is present" do
      assert is_nil(UnicodeSmuggler.decode!("B"))
    end

    test "Works with existing, public examples" do
      assert "hello" = UnicodeSmuggler.decode!(UnicodeSmuggler.encode!("hello", "😀"))
    end

  end

  describe "scan/1" do

    test "if passed text containing one or more hidden strings, they are returned in a list" do
      assert ["hello", "world"] = UnicodeSmuggler.scan(
               "This is text including not just #{UnicodeSmuggler.encode!("hello", "1")} but #{
                 UnicodeSmuggler.encode!("world", "2")
               } hidden texts"
             )
    end

    test "if passed normal text, an empty list is returned" do
      assert [] = UnicodeSmuggler.scan("Nothing here")
    end

  end

  describe "smuggling?/1" do

    test "returns true if any hidden text is found" do
      assert UnicodeSmuggler.smuggling?("Some text with secrets #{UnicodeSmuggler.encode!("hello", "😀")}")
    end

    test "returns false if no hidden text is found" do
      refute UnicodeSmuggler.smuggling?("😀")
    end

  end

  describe "trim/1" do

    test "An exception is raised if two or more container characters are provided" do
      assert_raise RuntimeError, fn -> UnicodeSmuggler.trim("AA") end
    end

    test "returns a normal character as-is" do
      assert "A" = UnicodeSmuggler.trim("A")
    end

    test "removes any hidden text attached to the character" do
      assert "A" = UnicodeSmuggler.trim(UnicodeSmuggler.encode!("hello", "A"))
      assert ~c"A" = UnicodeSmuggler.trim(UnicodeSmuggler.encode!("hello", "A"))
                     |> String.to_charlist()
      assert is_nil(UnicodeSmuggler.decode!(UnicodeSmuggler.trim(UnicodeSmuggler.encode!("hello", "A"))))
    end

  end


end
