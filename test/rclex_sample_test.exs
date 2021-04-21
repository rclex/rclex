defmodule RclexSamplesTest do
    use ExUnit.Case
  
    test "run RclexSamples in rclex repository" do
      IO.puts(RclexSamples.hello())
      assert RclexSamples.hello() == :world
    end
  end