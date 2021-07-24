# CHANGELOG

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

## v0.4.0 on 8 Jun 2021

- Support for [ROS 2 Foxy Fitzroy](https://index.ros.org/doc/ros2/Releases/Release-Foxy-Fitzroy/)!! #32 :tada:
- Recommended environment is now Ubuntu 20.04.2 LTS / ROS 2 Foxy / Elixir 1.11.2-otp-23 / Erlang/OTP 23.3.1
  - also work well on Ubuntu 18.04.5 LTS and Dashing Diademata
- Introduce automatic test a.k.a CI works on [GitHub Actions](https://github.com/rclex/rclex/actions) #13 #25 #31 
  - Please also check [rclex_connection_tests](https://github.com/rclex/rclex_connection_tests) and [rclex_docker on Docker Hub](https://hub.docker.com/r/rclex/rclex_docker) for more details
  - Note that CI sometimes fails due to the performance of GHA runner #28 
- Implement subsucribe_stop/2 #30
- Fix bug on timer_loop/4 #29 #21 
- Create [rclex Organization](https://github.com/rclex) and change source URL #18
- Please welcome @kebus426 as a new maintainer! 

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

