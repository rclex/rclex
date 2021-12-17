// generated from rosidl_generator_c/resource/idl__functions.c.em
// with input from smp_msgs:msg/Namenumber.idl
// generated code does not contain a copyright notice
#include "smp_msgs/msg/detail/namenumber__functions.h"

#include <assert.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>


// Include directives for member types
// Member `name`
#include "rosidl_runtime_c/string_functions.h"

bool
smp_msgs__msg__Namenumber__init(smp_msgs__msg__Namenumber * msg)
{
  if (!msg) {
    return false;
  }
  // name
  if (!rosidl_runtime_c__String__init(&msg->name)) {
    smp_msgs__msg__Namenumber__fini(msg);
    return false;
  }
  // number
  return true;
}

void
smp_msgs__msg__Namenumber__fini(smp_msgs__msg__Namenumber * msg)
{
  if (!msg) {
    return;
  }
  // name
  rosidl_runtime_c__String__fini(&msg->name);
  // number
}

smp_msgs__msg__Namenumber *
smp_msgs__msg__Namenumber__create()
{
  smp_msgs__msg__Namenumber * msg = (smp_msgs__msg__Namenumber *)malloc(sizeof(smp_msgs__msg__Namenumber));
  if (!msg) {
    return NULL;
  }
  memset(msg, 0, sizeof(smp_msgs__msg__Namenumber));
  bool success = smp_msgs__msg__Namenumber__init(msg);
  if (!success) {
    free(msg);
    return NULL;
  }
  return msg;
}

void
smp_msgs__msg__Namenumber__destroy(smp_msgs__msg__Namenumber * msg)
{
  if (msg) {
    smp_msgs__msg__Namenumber__fini(msg);
  }
  free(msg);
}


bool
smp_msgs__msg__Namenumber__Sequence__init(smp_msgs__msg__Namenumber__Sequence * array, size_t size)
{
  if (!array) {
    return false;
  }
  smp_msgs__msg__Namenumber * data = NULL;
  if (size) {
    data = (smp_msgs__msg__Namenumber *)calloc(size, sizeof(smp_msgs__msg__Namenumber));
    if (!data) {
      return false;
    }
    // initialize all array elements
    size_t i;
    for (i = 0; i < size; ++i) {
      bool success = smp_msgs__msg__Namenumber__init(&data[i]);
      if (!success) {
        break;
      }
    }
    if (i < size) {
      // if initialization failed finalize the already initialized array elements
      for (; i > 0; --i) {
        smp_msgs__msg__Namenumber__fini(&data[i - 1]);
      }
      free(data);
      return false;
    }
  }
  array->data = data;
  array->size = size;
  array->capacity = size;
  return true;
}

void
smp_msgs__msg__Namenumber__Sequence__fini(smp_msgs__msg__Namenumber__Sequence * array)
{
  if (!array) {
    return;
  }
  if (array->data) {
    // ensure that data and capacity values are consistent
    assert(array->capacity > 0);
    // finalize all array elements
    for (size_t i = 0; i < array->capacity; ++i) {
      smp_msgs__msg__Namenumber__fini(&array->data[i]);
    }
    free(array->data);
    array->data = NULL;
    array->size = 0;
    array->capacity = 0;
  } else {
    // ensure that data, size, and capacity values are consistent
    assert(0 == array->size);
    assert(0 == array->capacity);
  }
}

smp_msgs__msg__Namenumber__Sequence *
smp_msgs__msg__Namenumber__Sequence__create(size_t size)
{
  smp_msgs__msg__Namenumber__Sequence * array = (smp_msgs__msg__Namenumber__Sequence *)malloc(sizeof(smp_msgs__msg__Namenumber__Sequence));
  if (!array) {
    return NULL;
  }
  bool success = smp_msgs__msg__Namenumber__Sequence__init(array, size);
  if (!success) {
    free(array);
    return NULL;
  }
  return array;
}

void
smp_msgs__msg__Namenumber__Sequence__destroy(smp_msgs__msg__Namenumber__Sequence * array)
{
  if (array) {
    smp_msgs__msg__Namenumber__Sequence__fini(array);
  }
  free(array);
}
