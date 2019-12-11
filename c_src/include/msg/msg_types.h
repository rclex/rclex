#include <rcl/rcl.h>
#include <rosidl_generator_c/message_type_support_struct.h>
#include <rosidl_generator_c/string_functions.h>
#include <rcl/error_handling.h>

//直接プロトタイプ宣言
const rosidl_message_type_support_t* get_message_type_from_std_msgs_msg_Int16();
const std_msgs__msg__Int16* init_std_msgs_msg_Int16 ();
void destroy_std_msgs_msg_Int16(std_msgs__msg__Int16* msg);

/*
// MACROS for function headers
#define GET_MSG_TYPE_SUPPORT_HEADER(x,y,z) const rosidl_message_type_support_t* get_message_type_from_## x ##_## y ##_## z ();
#define CREATE_MSG_INIT_HEADER(x,y,z) const x##__##y##__##z* init_## x ##_## y ##_## z ();
#define CREATE_MSG_DESTROY_HEADER(x,y,z) void destroy_## x ##_## y ##_## z (x##__##y##__##z* msg);

// MACROS for function body
#define GET_MSG_TYPE_SUPPORT(x,y,z) const rosidl_message_type_support_t* get_message_type_from_## x ##_## y ##_## z (){ \
  return ROSIDL_GET_MSG_TYPE_SUPPORT(x,y,z); \
}

#define CREATE_MSG_INIT(x,y,z) const x##__##y##__##z* init_## x ##_## y ##_## z (){ \
  return  x##__##y##__##z##__create(); \
}

#define CREATE_MSG_DESTROY(x,y,z) void destroy_## x ##_## y ##_## z (x##__##y##__##z* msg){ \
  return  x##__##y##__##z##__destroy(msg); \
  }

#include <std_msgs/msg/int16.h>
//プロトタイプ宣言
GET_MSG_TYPE_SUPPORT_HEADER(std_msgs,msg,Int16)
CREATE_MSG_INIT_HEADER(std_msgs,msg,Int16)
CREATE_MSG_DESTROY_HEADER(std_msgs,msg,Int16)
/*
#include <std_msgs/msg/bool.h>
ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs,msg,Bool);

#include <std_msgs/msg/byte.h>
ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs,msg,Byte);

#include <std_msgs/msg/string.h>
ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs,msg,String);

#include <std_msgs/msg/char.h>
ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs,msg,Char);

#include <std_msgs/msg/color_rgba.h>
ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs,msg,ColorRGBA);

#include <std_msgs/msg/empty.h>
ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs,msg,Empty);

#include <std_msgs/msg/float32.h>
ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs,msg,Float32);

#include <std_msgs/msg/float64.h>
ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs,msg,Float64);
*/