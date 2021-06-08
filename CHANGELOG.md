# CHANGELOG

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

