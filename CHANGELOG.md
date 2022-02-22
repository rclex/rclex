# CHANGELOG

## v0.5.3 on 22 Feb 2022

- New features:
  - Add following APIs #92 
    - `create_singlenode_with_executor_setting/3`
      - can specify `executor_setting` in addition to args in `create_singlenode/3`
      - `{queue_length}` means the maximum length of `job_queue` under the created nodes
      - `change_order` (in `{queue_length, change_order}`) means a function that adjusts the execution order of `job_exe`
    - `create_nodes_with_executor_setting/4`, `create_timer_with_executor_setting/5` and `create_timer_with_executor_setting/6`: same with the above
- Code Improvements/Fixes: none
- Bumps:
  - `ex_doc` to 0.28.1 #96
  - `credo` to 1.6.3 #91
- Known issues:
  - `mix test` sometimes fails, but we don't think it will affect the behavior #68
- Full Changelog: https://github.com/rclex/rclex/compare/v0.5.2...v0.5.3

## v0.5.2 on 21 Jan 2022

- New features:
  - Add timer name in args of `create_timer/4` and `create_timer/5` to treat timer ID ddf99cf
  - Implement `ResourceServer` module #83
    - `JobExecutor` and `JobQueue` will be created for each node and timer
    - `Executor` has been obsoleted and changed to the above feature
- Code Improvements/Fixes:
  - change wait time 50 to 5 milliseconds #76
  - change docker tags for CI test #78
- Bumps:
  - `ex_doc` to 0.27.3 #80
  - `credo` to 1.6.2 #82
- Known issues:
  - `mix test` sometimes fails, but we don't think it will affect the behavior #68
- Full Changelog: https://github.com/rclex/rclex/compare/v0.5.1...v0.5.2

## v0.5.1 on 30 Nov 2021

- New features:
  - Implement `Timer.terminate/2` [2915de5](https://github.com/rclex/rclex/commit/2915de5a7bdaa3ca22b56c7900d03a9931e057f9)
- Code Improvements/Fixes:
  - Change filename to snake_case according to follow ElixirStyleGuide #72 
  - Some minor refactoring to remove boring warning in `mix compile` #73
- Bumps:
  - `ex_doc` to 0.26.0 #71
  - `credo` to 1.6.1 #70
- Known issues:
  - `mix test` sometimes fails, but we don't think it will affect the behavior #68
- Full Changelog: https://github.com/rclex/rclex/compare/v0.5.0...v0.5.1

## v0.5.0 on 01 Nov 2021

- New features:
  - Implement `Executor` module by using GenServer #61 #67
- Code Improvements/Fixes:
  - Hide NIF functions from users #54 #55
- Bumps:
  - `ex_doc` to 0.25.5 #63
  - `elixir_make` to 0.6.3 #62
- Known issues:
  - `mix test` sometimes fails, but we don't think it will affect the behavior #68
- Full Changelog: https://github.com/rclex/rclex/compare/v0.4.1...v0.5.0

## v0.4.1 on 24 Jul 2021

- New features:
  - Implement `rcl_node_get_name/1` and `rcl_get_topic_names_and_types/3` #42
- Code Improvements/Fixes:
  - Improve code according to the advice from Credo #41 
  - Use DEBUG_PRINTF and Logger to control print message in library #46 #23 #24
  - Change the method to obtain ROS_DIR with `which ros2` #38
  - Add and apply Artistic Style for C source (mix format) #45
- Enhancements:
  - Introduce `mix credo` on GHA #48
  - Create GHA to publish to Hex when tags released #40
  - Separate ci.yml #49
  - Improve timing of connection tests [rclex/rclex_connection_tests#12](https://github.com/rclex/rclex_connection_tests/pull/12)
- Bumps:
  - `ex_doc` from 0.24.2 to 0.25.0 #47
- Full Changelog: https://github.com/rclex/rclex/compare/v0.4.0...v0.4.1

## v0.4.0 on 8 Jun 2021

- Please welcome @kebus426 as a new maintainer! 
- Support for [ROS 2 Foxy Fitzroy](https://index.ros.org/doc/ros2/Releases/Release-Foxy-Fitzroy/)!! #32 :tada:
- Recommended environment is now Ubuntu 20.04.2 LTS / ROS 2 Foxy / Elixir 1.11.2-otp-23 / Erlang/OTP 23.3.1
  - also work well on Ubuntu 18.04.5 LTS and Dashing Diademata
- Introduce automatic test a.k.a CI works on [GitHub Actions](https://github.com/rclex/rclex/actions) #13 #25 #31 
  - Please also check [rclex_connection_tests](https://github.com/rclex/rclex_connection_tests) and [rclex_docker on Docker Hub](https://hub.docker.com/r/rclex/rclex_docker) for more details
  - Note that CI sometimes fails due to the performance of GHA runner #28 
- Implement subsucribe_stop/2 #30
- Fix bug on timer_loop/4 #29 #21 
- Create [rclex Organization](https://github.com/rclex) and change source URL #18
- Full Changelog: https://github.com/rclex/rclex/compare/v0.3.1...v0.4.0

## v0.3.1 on 4 Jul 2020

- Translate README from Japanese to English #11

## v0.3.0 on 26 Jun 2020

- Change module name to Rclex #8

## v0.2.0 on 24 Feb 2020

- Publish this package on hex.pm
  - You can now use this repository as the Hex package
- Refactor source tree
  - Adjust elixir_make to generate rclex.so to priv/
  - Eliminate Timex
- Apply mix format
- Write README doc, only by Japanese (sorry,,,)

## v0.1.0 on 24 Feb 2020

First publication

