// generated from rosidl_typesupport_introspection_cpp/resource/idl__type_support.cpp.em
// with input from smp_msgs:msg/Namenumber.idl
// generated code does not contain a copyright notice

#include "array"
#include "cstddef"
#include "string"
#include "vector"
#include "rosidl_runtime_c/message_type_support_struct.h"
#include "rosidl_typesupport_cpp/message_type_support.hpp"
#include "rosidl_typesupport_interface/macros.h"
#include "smp_msgs/msg/detail/namenumber__struct.hpp"
#include "rosidl_typesupport_introspection_cpp/field_types.hpp"
#include "rosidl_typesupport_introspection_cpp/identifier.hpp"
#include "rosidl_typesupport_introspection_cpp/message_introspection.hpp"
#include "rosidl_typesupport_introspection_cpp/message_type_support_decl.hpp"
#include "rosidl_typesupport_introspection_cpp/visibility_control.h"

namespace smp_msgs
{

namespace msg
{

namespace rosidl_typesupport_introspection_cpp
{

void Namenumber_init_function(
  void * message_memory, rosidl_runtime_cpp::MessageInitialization _init)
{
  new (message_memory) smp_msgs::msg::Namenumber(_init);
}

void Namenumber_fini_function(void * message_memory)
{
  auto typed_message = static_cast<smp_msgs::msg::Namenumber *>(message_memory);
  typed_message->~Namenumber();
}

static const ::rosidl_typesupport_introspection_cpp::MessageMember Namenumber_message_member_array[2] = {
  {
    "name",  // name
    ::rosidl_typesupport_introspection_cpp::ROS_TYPE_STRING,  // type
    0,  // upper bound of string
    nullptr,  // members of sub message
    false,  // is array
    0,  // array size
    false,  // is upper bound
    offsetof(smp_msgs::msg::Namenumber, name),  // bytes offset in struct
    nullptr,  // default value
    nullptr,  // size() function pointer
    nullptr,  // get_const(index) function pointer
    nullptr,  // get(index) function pointer
    nullptr  // resize(index) function pointer
  },
  {
    "number",  // name
    ::rosidl_typesupport_introspection_cpp::ROS_TYPE_INT16,  // type
    0,  // upper bound of string
    nullptr,  // members of sub message
    false,  // is array
    0,  // array size
    false,  // is upper bound
    offsetof(smp_msgs::msg::Namenumber, number),  // bytes offset in struct
    nullptr,  // default value
    nullptr,  // size() function pointer
    nullptr,  // get_const(index) function pointer
    nullptr,  // get(index) function pointer
    nullptr  // resize(index) function pointer
  }
};

static const ::rosidl_typesupport_introspection_cpp::MessageMembers Namenumber_message_members = {
  "smp_msgs::msg",  // message namespace
  "Namenumber",  // message name
  2,  // number of fields
  sizeof(smp_msgs::msg::Namenumber),
  Namenumber_message_member_array,  // message members
  Namenumber_init_function,  // function to initialize message memory (memory has to be allocated)
  Namenumber_fini_function  // function to terminate message instance (will not free memory)
};

static const rosidl_message_type_support_t Namenumber_message_type_support_handle = {
  ::rosidl_typesupport_introspection_cpp::typesupport_identifier,
  &Namenumber_message_members,
  get_message_typesupport_handle_function,
};

}  // namespace rosidl_typesupport_introspection_cpp

}  // namespace msg

}  // namespace smp_msgs


namespace rosidl_typesupport_introspection_cpp
{

template<>
ROSIDL_TYPESUPPORT_INTROSPECTION_CPP_PUBLIC
const rosidl_message_type_support_t *
get_message_type_support_handle<smp_msgs::msg::Namenumber>()
{
  return &::smp_msgs::msg::rosidl_typesupport_introspection_cpp::Namenumber_message_type_support_handle;
}

}  // namespace rosidl_typesupport_introspection_cpp

#ifdef __cplusplus
extern "C"
{
#endif

ROSIDL_TYPESUPPORT_INTROSPECTION_CPP_PUBLIC
const rosidl_message_type_support_t *
ROSIDL_TYPESUPPORT_INTERFACE__MESSAGE_SYMBOL_NAME(rosidl_typesupport_introspection_cpp, smp_msgs, msg, Namenumber)() {
  return &::smp_msgs::msg::rosidl_typesupport_introspection_cpp::Namenumber_message_type_support_handle;
}

#ifdef __cplusplus
}
#endif
