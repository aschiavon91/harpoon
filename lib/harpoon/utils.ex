defmodule Harpoon.Utils do
  @moduledoc false
  def generate_sid do
    number =
      0..99
      |> Enum.random()
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    friendly_id = FriendlyID.generate(2, separator: "-", transform: &String.downcase/1)
    friendly_id <> "-" <> number
  end
end
