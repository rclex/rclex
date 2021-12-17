// generated from rosidl_generator_c/resource/idl__functions.h.em
// with input from smp_msgs:msg/Namenumber.idl
// generated code does not contain a copyright notice

#ifndef SMP_MSGS__MSG__DETAIL__NAMENUMBER__FUNCTIONS_H_
#define SMP_MSGS__MSG__DETAIL__NAMENUMBER__FUNCTIONS_H_

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdbool.h>
#include <stdlib.h>

#include "rosidl_runtime_c/visibility_control.h"
#include "smp_msgs/msg/rosidl_generator_c__visibility_control.h"

#include "smp_msgs/msg/detail/namenumber__struct.h"

/// Initialize msg/Namenumber message.
/**
 * If the init function is called twice for the same message without
 * calling fini inbetween previously allocated memory will be leaked.
 * \param[in,out] msg The previously allocated message pointer.
 * Fields without a default value will not be initialized by this function.
 * You might want to call memset(msg, 0, sizeof(
 * smp_msgs__msg__Namenumber
 * )) before or use
 * smp_msgs__msg__Namenumber__create()
 * to allocate and initialize the message.
 * \return true if initialization was successful, otherwise false
 */
ROSIDL_GENERATOR_C_PUBLIC_smp_msgs
bool
smp_msgs__msg__Namenumber__init(smp_msgs__msg__Namenumber * msg);

/// Finalize msg/Namenumber message.
/**
 * \param[in,out] msg The allocated message pointer.
 */
ROSIDL_GENERATOR_C_PUBLIC_smp_msgs
void
smp_msgs__msg__Namenumber__fini(smp_msgs__msg__Namenumber * msg);

/// Create msg/Namenumber message.
/**
 * It allocates the memory for the message, sets the memory to zero, and
 * calls
 * smp_msgs__msg__Namenumber__init().
 * \return The pointer to the initialized message if successful,
 * otherwise NULL
 */
ROSIDL_GENERATOR_C_PUBLIC_smp_msgs
smp_msgs__msg__Namenumber *
smp_msgs__msg__Namenumber__create();

/// Destroy msg/Namenumber message.
/**
 * It calls
 * smp_msgs__msg__Namenumber__fini()
 * and frees the memory of the message.
 * \param[in,out] msg The allocated message pointer.
 */
ROSIDL_GENERATOR_C_PUBLIC_smp_msgs
void
smp_msgs__msg__Namenumber__destroy(smp_msgs__msg__Namenumber * msg);


/// Initialize array of msg/Namenumber messages.
/**
 * It allocates the memory for the number of elements and calls
 * smp_msgs__msg__Namenumber__init()
 * for each element of the array.
 * \param[in,out] array The allocated array pointer.
 * \param[in] size The size / capacity of the array.
 * \return true if initialization was successful, otherwise false
 * If the array pointer is valid and the size is zero it is guaranteed
 # to return true.
 */
ROSIDL_GENERATOR_C_PUBLIC_smp_msgs
bool
smp_msgs__msg__Namenumber__Sequence__init(smp_msgs__msg__Namenumber__Sequence * array, size_t size);

/// Finalize array of msg/Namenumber messages.
/**
 * It calls
 * smp_msgs__msg__Namenumber__fini()
 * for each element of the array and frees the memory for the number of
 * elements.
 * \param[in,out] array The initialized array pointer.
 */
ROSIDL_GENERATOR_C_PUBLIC_smp_msgs
void
smp_msgs__msg__Namenumber__Sequence__fini(smp_msgs__msg__Namenumber__Sequence * array);

/// Create array of msg/Namenumber messages.
/**
 * It allocates the memory for the array and calls
 * smp_msgs__msg__Namenumber__Sequence__init().
 * \param[in] size The size / capacity of the array.
 * \return The pointer to the initialized array if successful, otherwise NULL
 */
ROSIDL_GENERATOR_C_PUBLIC_smp_msgs
smp_msgs__msg__Namenumber__Sequence *
smp_msgs__msg__Namenumber__Sequence__create(size_t size);

/// Destroy array of msg/Namenumber messages.
/**
 * It calls
 * smp_msgs__msg__Namenumber__Sequence__fini()
 * on the array,
 * and frees the memory of the array.
 * \param[in,out] array The initialized array pointer.
 */
ROSIDL_GENERATOR_C_PUBLIC_smp_msgs
void
smp_msgs__msg__Namenumber__Sequence__destroy(smp_msgs__msg__Namenumber__Sequence * array);

#ifdef __cplusplus
}
#endif

#endif  // SMP_MSGS__MSG__DETAIL__NAMENUMBER__FUNCTIONS_H_
