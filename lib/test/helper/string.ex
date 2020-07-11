defmodule Test.Helper.String do
  def random_string(str_length) do
    str = []

    ret =
      Enum.map(0..(str_length - 1), fn index ->
        str = [<<Enum.random(64..122)>> | str]
      end)

    Enum.join(ret)
  end
end
