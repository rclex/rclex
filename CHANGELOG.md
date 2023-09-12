# CHANGELOG

## v0.9.1 on 12 Sep 2023

**Full Changelog**: https://github.com/rclex/rclex/compare/v0.9.0...v0.9.1

* New features:
  * Experimental support for Iron Irwini by @takasehideki in https://github.com/rclex/rclex/pull/251
* Code Improvements/Fixes: none
* Bumps: none
* Known issues to be addressed in the near future:
  * Lock `git_hooks` to 0.6.5 due to its issue in https://github.com/rclex/rclex/issues/138
  * Release rcl nif resources when GerServer terminates in https://github.com/rclex/rclex/issues/160
  * `publish/2` sometimes failed just after `create_publisher/3` in https://github.com/rclex/rclex/issues/212
  * CI fails randomly at mix test in https://github.com/rclex/rclex/issues/246
  * Bump to Iron Irwini, for Docker and Nerves environments in https://github.com/rclex/rclex/issues/228
* Note in this release:
  * Please welcome Iron Irwini as the experimental supported distribution for Rclex!! :tada:

## v0.9.0 on 11 Sep 2023

**Full Changelog**: https://github.com/rclex/rclex/compare/v0.8.5...v0.9.0

* New features:
  * Support Humble (and format with Elixir 1.15.5) by @pojiro in https://github.com/rclex/rclex/pull/241
  * Support humble, galactic Nerves by @pojiro in https://github.com/rclex/rclex/pull/244
  * change the recommended environment and versions by @takasehideki in https://github.com/rclex/rclex/pull/247
  * Add humble support to arm32v7_ros_distros by @pojiro in https://github.com/rclex/rclex/pull/248
* Code Improvements/Fixes:
  * Fix bug of `mix rclex.gen.msgs` by @pojiro in https://github.com/rclex/rclex/pull/236
  * fix docs about ROS_DISTRO from `foxy` to `humble` by @takasehideki in https://github.com/rclex/rclex/pull/249
* Bumps:
  * Bump ex_doc from 0.29.4 to 0.30.6 by @dependabot in https://github.com/rclex/rclex/pull/234 https://github.com/rclex/rclex/pull/237 https://github.com/rclex/rclex/pull/238
  * Bump dialyxir from 1.3.0 to 1.4.1 by @dependabot in https://github.com/rclex/rclex/pull/240
  * Bump mix_test_watch from 1.1.0 to 1.1.1 by @dependabot in https://github.com/rclex/rclex/pull/242
* Known issues to be addressed in the near future:
  * Lock `git_hooks` to 0.6.5 due to its issue in https://github.com/rclex/rclex/issues/138
  * Release rcl nif resources when GerServer terminates in https://github.com/rclex/rclex/issues/160
  * `publish/2` sometimes failed just after `create_publisher/3` in https://github.com/rclex/rclex/issues/212
  * CI fails randomly at mix test in https://github.com/rclex/rclex/issues/246
  * Bump to Iron Irwini in https://github.com/rclex/rclex/issues/228
* Note in this release:
  * Please welcome Humble Hawksbill (and Galactic Geochelone) as the new supported distribution for Rclex!! :tada:

## v0.8.5 on 05 Jun 2023

**Full Changelog**: https://github.com/rclex/rclex/compare/v0.8.4...v0.8.5

* New features:
  * Adding handling for nested Message types from different Packages by @steve-at in https://github.com/rclex/rclex/pull/230
* Code Improvements/Fixes: none
* Bumps:
  * Bump elixir_make from 0.7.6 to 0.7.7
* Known issues to be addressed in the near future:
  * `publish/2` sometimes failed just after `create_publisher/3` in https://github.com/rclex/rclex/issues/212
  * Lock `git_hooks` to 0.6.5 due to its issue in https://github.com/rclex/rclex/issues/138
  * Bump to Humble Hawksbill in https://github.com/rclex/rclex/issues/114
  * Bump to Iron Irwini in https://github.com/rclex/rclex/issues/228
  * Release rcl nif resources when GerServer terminates in https://github.com/rclex/rclex/issues/160
* Note in this release: none

## v0.8.4 on 11 Apr 2023

**Full Changelog**: https://github.com/rclex/rclex/compare/v0.8.3...v0.8.4

* New features: none
* Code Improvements/Fixes:
  * Fix typos by @kianmeng in https://github.com/rclex/rclex/pull/217
* Bumps:
  * Bump elixir_make from 0.7.1 to 0.7.6
  * Bump ex_doc from 0.29.1 to 0.29.4
  * Bump credo from 1.6.7 to 1.7.0
  * Bump dialyxir from 1.2.0 to 1.3.0
* Known issues to be addressed in the near future:
  * `publish/2` sometimes failed just after `create_publisher/3` in https://github.com/rclex/rclex/issues/212
  * Lock `git_hooks` to 0.6.5 due to its issue in https://github.com/rclex/rclex/issues/138
  * Bump to Humble Hawksbill in https://github.com/rclex/rclex/issues/114
  * Release rcl nif resources when GerServer terminates in https://github.com/rclex/rclex/issues/160
* Note in this release: none

## v0.8.3 on 12 Dec 2022

**Full Changelog**: https://github.com/rclex/rclex/compare/v0.8.2...v0.8.3

* New features:
  * Add arm32v7 support to mix rclex.prep.ros2 by @pojiro in https://github.com/rclex/rclex/pull/210
* Code Improvements/Fixes:
  * improve doc about docker env by @takasehideki in https://github.com/rclex/rclex/pull/208
  * Remove useless gitignore line by @pojiro in https://github.com/rclex/rclex/pull/211
  * insert sleep before publishing on example code (see #212) by @takasehideki in https://github.com/rclex/rclex/pull/213
* Bumps:
  * Bump elixir_make from 0.7.0 to 0.7.1 by @dependabot in https://github.com/rclex/rclex/pull/209
* Known issues to be addressed in the near future:
  * `publish/2` sometimes failed just after `create_publisher/3` in https://github.com/rclex/rclex/issues/212
  * Lock `git_hooks` to 0.6.5 due to its issue in https://github.com/rclex/rclex/issues/138
  * Bump to Humble Hawksbill in https://github.com/rclex/rclex/issues/114
  * Release rcl nif resources when GerServer terminates in https://github.com/rclex/rclex/issues/160
* Note in this release: none

## v0.8.2 on 03 Dec 2022

**Full Changelog**: https://github.com/rclex/rclex/compare/v0.8.1...v0.8.2

* New features: none
* Code Improvements/Fixes:
  * fix to check ROS_DIR by @takasehideki in https://github.com/rclex/rclex/pull/206
* Bumps: none
* Known issues to be addressed in the near future:
  * Lock `git_hooks` to 0.6.5 due to its issue in https://github.com/rclex/rclex/issues/138
  * Bump to Humble Hawksbill in https://github.com/rclex/rclex/issues/114
  * Release rcl nif resources when GerServer terminates in https://github.com/rclex/rclex/issues/160
* Note in this release:
  * This release only fixes a critical issue that existed in the previous release,,,

## v0.8.1 on 03 Dec 2022

**Full Changelog**: https://github.com/rclex/rclex/compare/v0.8.0...v0.8.1

* New features:
  * Create docs for Use on Nerves and improve related mix tasks by @pojiro in https://github.com/rclex/rclex/pull/198
* Code Improvements/Fixes:
  * Change `raise` to `Mix.raise` to proper mix task error handling by @pojiro in https://github.com/rclex/rclex/pull/194
  * Change Makefile's if statement to confirm ROS_DIR exists by @pojiro in https://github.com/rclex/rclex/pull/195
  * Improve mix tasks usability by @pojiro in https://github.com/rclex/rclex/pull/196
* Bumps:
  * Bump ex_doc from 0.29.0 to 0.29.1 by @dependabot in https://github.com/rclex/rclex/pull/199
  * Bump elixir_make from 0.6.3 to 0.7.0 by @dependabot in https://github.com/rclex/rclex/pull/200
* Known issues to be addressed in the near future:
  * Lock `git_hooks` to 0.6.5 due to its issue in https://github.com/rclex/rclex/issues/138
  * Bump to Humble Hawksbill in https://github.com/rclex/rclex/issues/114
  * Release rcl nif resources when GerServer terminates in https://github.com/rclex/rclex/issues/160
* Note in this release: none

## v0.8.0 on 01 Nov 2022

**Full Changelog**: https://github.com/rclex/rclex/compare/v0.7.2...v0.8.0

**Holy Shit! Rclex now works on Nerves as well!!** :tada:

* New features:
  * Refactor generate messages codes pojiro by @pojiro in https://github.com/rclex/rclex/pull/185
  * refactor Makefile and msgs.ex by @pojiro in https://github.com/rclex/rclex/pull/192
  * Feature add tasks to prepare ros2 resources by @pojiro in https://github.com/rclex/rclex/pull/190
* Code Improvements/Fixes:
  * Add docker command to mix test.watch section on README.md by @pojiro in https://github.com/rclex/rclex/pull/177
  * Fix `mix deps.get` error on GitHub Actions by @s-hosoai in https://github.com/rclex/rclex/pull/178
  * Fix multiple definition by @pojiro in https://github.com/rclex/rclex/pull/182
  * Remove DASHING support from c source by @pojiro in https://github.com/rclex/rclex/pull/189
  * Remove unused rclex_gen_msgs from mix.lock by @pojiro in https://github.com/rclex/rclex/pull/191
* Bumps:
  *  `ex_doc` from 0.28.6 to 0.29.0 by @dependabot in https://github.com/rclex/rclex/pull/184
* Known issues to be addressed in the near future:
  * Lock `git_hooks` to 0.6.5 due to its issue in https://github.com/rclex/rclex/issues/138
  * Bump to Humble Hawksbill in https://github.com/rclex/rclex/issues/114
  * Release rcl nif resources when GerServer terminates in https://github.com/rclex/rclex/issues/160
* Note in this release:
  * set supported/tested elixir version to above 1.12 by @takasehideki in https://github.com/rclex/rclex/pull/186

## v0.7.2 on 22 Sep 2022

**Full Changelog**: https://github.com/rclex/rclex/compare/v0.7.1...v0.7.2

* New features: none
* Code Improvements/Fixes:
  * change the recommended env and target versions for GitHub Actions CI by @takasehideki in https://github.com/rclex/rclex/pull/173
  * Enable Dialyzer on GitHub Actions (remove uncheck and ignore exit options) by @s-hosoai in https://github.com/rclex/rclex/pull/165
  * elinimate errors in `mix dialyzer` on GHA (fix #174) by @takasehideki in https://github.com/rclex/rclex/pull/175
* Bumps:
  * `dialyxir` from 1.1.0 to 1.2.0 in https://github.com/rclex/rclex/pull/166
  *  `ex_doc` from 0.28.4 to 0.28.5 in https://github.com/rclex/rclex/pull/168
  * `credo` from 1.6.5 to 1.6.7 by https://github.com/rclex/rclex/pull/169
* Known issues to be addressed in the near future:
  * Lock `git_hooks` to 0.6.5 due to its issue in https://github.com/rclex/rclex/issues/138
  * Bump to Humble Hawksbill in https://github.com/rclex/rclex/issues/114
  * Release rcl nif resources when GerServer terminates in https://github.com/rclex/rclex/issues/160
* Note in this release:
  * The recommended environment is changed to the following versions
    * Ubuntu 20.04.2 LTS (Focal Fossa)
    * ROS 2 [Foxy Fitzroy](https://docs.ros.org/en/foxy/Releases/Release-Foxy-Fitzroy.html)
    * Elixir 1.13.4-otp-25
    * Erlang/OTP 25.0.3

## v0.7.1 on 21 Sep 2022

**Full Changelog**: https://github.com/rclex/rclex/compare/v0.7.0...v0.7.1

* New Contributors: @pojiro :tada:
* New features:
  * Improve unit test environment on local dev machine by @pojiro in https://github.com/rclex/rclex/pull/131
* Code Improvements/Fixes:
  * Enrich doc and specs with the awesome contributions by @pojiro (e.g., in https://github.com/rclex/rclex/pull/121)
  * Enrich unit tests with the awesome contributions by @pojiro (e.g., in https://github.com/rclex/rclex/pull/136)
  * Improve credo config, .credo.exs by @pojiro in https://github.com/rclex/rclex/pull/120
  * exclude auto-generated files format by @pojiro in https://github.com/rclex/rclex/pull/135
  * refactor Rclex.ResourceServer.call_nifs_rcl_node_init/5 by @pojiro in https://github.com/rclex/rclex/pull/147
  * fix node name bug, when it attributes a namespace (and also fix #142) by @pojiro in https://github.com/rclex/rclex/pull/149
  * Remove KeepSub module which is unused (also fix dialyzer error) by @s-hosoai in https://github.com/rclex/rclex/pull/164
  * Improve README by @takasehideki in https://github.com/rclex/rclex/pull/171
* Bumps:
  * `credo` from 1.6.4 to 1.6.5 in https://github.com/rclex/rclex/pull/162
* Known issues to be addressed in the near future:
  * Lock `git_hooks` to 0.6.5 due to its issue in https://github.com/rclex/rclex/issues/138
  * Bump to Humble Hawksbill in https://github.com/rclex/rclex/issues/114
  * Release rcl nif resources when GerServer terminates in https://github.com/rclex/rclex/issues/160
* Note in this release:
  * After long consideration, we have decided to end the support for Dashing as the target environment 6ae367d

## v0.7.0 on 27 May 2022

* New features: none
* Code Improvements/Fixes:
  * Refactoring to simplify implementation by @s-hosoai in https://github.com/rclex/rclex/pull/118
    * rename and simplify functions
    * delete comment out functions
    * change NIF exception handling
    * add @spac and @impl
    * refine tests
* Bumps: none
* Known issues:
  * `rclex_connection_tests` becomes failed on Dashing from v0.6.0_rc #89
  * `Rclex.initialize_msg/0` is undefined or private in `KeepSub.sub_task_start/2` #104
* Full Changelog: https://github.com/rclex/rclex/compare/v0.6.2...v0.7.0

## v0.6.2 on 25 May 2022

* Please welcome @s-hosoai as a new maintainer!
* New features: none
* Code Improvements/Fixes:
  * Add simple pub sub test by @s-hosoai in https://github.com/rclex/rclex/pull/113
  * fix job_queue length condition (fix #112) by @s-hosoai in https://github.com/rclex/rclex/pull/115
  * remove Dashing from CI targets by @takasehideki in https://github.com/rclex/rclex/pull/116
* Bumps:
  * `ex_doc` to 0.28.4 #110
* Known issues:
  * `rclex_connection_tests` becomes failed on Dashing from v0.6.0_rc #89
  * `Rclex.initialize_msg/0` is undefined or private in `KeepSub.sub_task_start/2` #104
* Full Changelog: https://github.com/rclex/rclex/compare/v0.6.1...v0.6.2

## v0.6.1 on 22 Mar 2022

- New features: none
- Code Improvements/Fixes:
  - include packages.txt and template file to hex package #107
- Bumps: none
- Known issues:
  - `rclex_connection_tests` becomes failed on Dashing from v0.6.0_rc #89
  - `Rclex.initialize_msg/0` is undefined or private in `KeepSub.sub_task_start/2` #104
- Full Changelog: https://github.com/rclex/rclex/compare/v0.6.0...v0.6.1

## v0.6.0 on 17 Mar 2022

- New features:
  - support custom msgtype!! #87 #98
- Code Improvements/Fixes:
  - Enhance README #102
- Bumps:
  - `ex_doc` to 0.28.2 #99
  - `credo` to 1.6.4 #100
- Known issues:
  - `rclex_connection_tests` becomes failed on Dashing from v0.6.0_rc #89
  - `Rclex.initialize_msg/0` is undefined or private in `KeepSub.sub_task_start/2` #104
- Full Changelog: https://github.com/rclex/rclex/compare/v0.5.3...v0.6.0

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

