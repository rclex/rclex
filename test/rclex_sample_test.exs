defmodule RclexSamplesTest do
    use ExUnit.Case
  
    test "run RclexSamples in rclex repository" do
      assert RclexSamples.hello() == :world
    end
  end