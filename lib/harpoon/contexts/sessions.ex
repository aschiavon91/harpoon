defmodule Harpoon.Sessions do
  @moduledoc false

  def generate_sid do
    number =
      0..999
      |> Enum.random()
      |> Integer.to_string()
      |> String.pad_leading(3, "0")

    friendly_id = FriendlyID.generate(2, separator: "-", transform: &String.downcase/1)
    friendly_id <> "-" <> number
  end
end
