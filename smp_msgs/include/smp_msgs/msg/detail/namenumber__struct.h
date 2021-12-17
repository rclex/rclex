// generated from rosidl_generator_c/resource/idl__struct.h.em
// with input from smp_msgs:msg/Namenumber.idl
// generated code does not contain a copyright notice

#ifndef SMP_MSGS__MSG__DETAIL__NAMENUMBER__STRUCT_H_
#define SMP_MSGS__MSG__DETAIL__NAMENUMBER__STRUCT_H_

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>


// Constants defined in the message

// Include directives for member types
// Member 'name'
#include "rosidl_runtime_c/string.h"

// Struct defined in msg/Namenumber in the package smp_msgs.
typedef struct smp_msgs__msg__Namenumber
{
  rosidl_runtime_c__String name;
  int16_t number;
} smp_msgs__msg__Namenumber;

// Struct for a sequence of smp_msgs__msg__Namenumber.
typedef struct smp_msgs__msg__Namenumber__Sequence
{
  smp_msgs__msg__Namenumber * data;
  /// The number of valid items in data
  size_t size;
  /// The number of allocated items in data
  size_t capacity;
} smp_msgs__msg__Namenumber__Sequence;

#ifdef __cplusplus
}
#endif

#endif  // SMP_MSGS__MSG__DETAIL__NAMENUMBER__STRUCT_H_
