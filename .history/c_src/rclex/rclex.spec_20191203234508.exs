defmodule Rclex.Native

callback :load
@doc """
ユーザーにとって必要なAPI
  rcl_init
  rcl_shutdown
   
  create_node
  create_publisher
  rcl_publish
"""
spec init() :: {:ok ::label, state}