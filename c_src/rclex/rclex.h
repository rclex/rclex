#pragma once
/*
  ここに必要なヘッダファイルをincludeしていく
  構造体rcl_node_tとかを以下のように別名つける.
  結果，spec.exsで使えるようになる...はず
*/

//node + init
#include <erl_nif.h>
#include "rcl/node.h"
#include "rcl/init.h"
#include "rcl/context.h"
#include "rcl/init_options.h"
#include "rcl/node.h"

#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "rcl/arguments.h"
#include "rcl/error_handling.h"
//#include "rcl/localhost.h"
#include "rcl/logging.h"
#include "rcl/logging_rosout.h"
#include "rcl/rcl.h"
#include "rcl/remap.h"
#include "rcl/security_directory.h"
#include "rcutils/filesystem.h"
#include "rcutils/find.h"
#include "rcutils/format_string.h"
#include "rcutils/get_env.h"
#include "rcutils/logging.h"
#include "rcutils/macros.h"
#include "rcutils/repl_str.h"
#include "rcutils/snprintf.h"
#include "rcutils/strdup.h"
#include "rmw/error_handling.h"
#include "rmw/node_security_options.h"
#include "rmw/rmw.h"
#include "rmw/validate_namespace.h"
#include "rmw/validate_node_name.h"
//#include "tracetools/tracetools.h"

//#include "../src/context_impl.h"
//ここまでコメントアウトしてた

//---------publisher_nif.c------------
#include "rcl/publisher.h"
#include "rcl/allocator.h"
#include "rcl/error_handling.h"
#include "rcl/expand_topic_name.h"
#include "rcl/remap.h"
#include "rcutils/logging.h"
#include "rmw/validate_full_topic_name.h"

//---------msg_int16_nif.c------------
#include "msg_types.h"
#include <rosidl_generator_c/message_type_support_struct.h>
#include "std_msgs/msg/int16__struct.h"

typedef struct rcl_context_t .....;
typedef struct rcl_options_node_t .....;
...

typedef struct MyState UnifexNifState;

struct MyState {
  int a;
};
typedef UnifexNifState State;

typedef struct MyState2 UnifexNifStateTwo;
struct MyState2 {
  int age;
  double height;
};
typedef UnifexNifStateTwo StateTwo;

#include "_generated/rclex.h"