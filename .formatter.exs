# Used by "mix format"
[
  inputs:
    ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
    # expand wildcard path to list
    |> Enum.flat_map(&Path.wildcard(&1, match_dot: true))
    # exclude msgs, ex) lib/rclex/geometry_msgs/msg/*.ex
    |> Enum.reject(fn path -> Regex.match?(~r{lib/rclex/.*/msg/.*}, path) end)
]
