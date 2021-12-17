// generated from rosidl_generator_cpp/resource/idl__traits.hpp.em
// with input from smp_msgs:msg/Namenumber.idl
// generated code does not contain a copyright notice

#ifndef SMP_MSGS__MSG__DETAIL__NAMENUMBER__TRAITS_HPP_
#define SMP_MSGS__MSG__DETAIL__NAMENUMBER__TRAITS_HPP_

#include "smp_msgs/msg/detail/namenumber__struct.hpp"
#include <rosidl_runtime_cpp/traits.hpp>
#include <stdint.h>
#include <type_traits>

namespace rosidl_generator_traits
{

template<>
inline const char * data_type<smp_msgs::msg::Namenumber>()
{
  return "smp_msgs::msg::Namenumber";
}

template<>
inline const char * name<smp_msgs::msg::Namenumber>()
{
  return "smp_msgs/msg/Namenumber";
}

template<>
struct has_fixed_size<smp_msgs::msg::Namenumber>
  : std::integral_constant<bool, false> {};

template<>
struct has_bounded_size<smp_msgs::msg::Namenumber>
  : std::integral_constant<bool, false> {};

template<>
struct is_message<smp_msgs::msg::Namenumber>
  : std::true_type {};

}  // namespace rosidl_generator_traits

#endif  // SMP_MSGS__MSG__DETAIL__NAMENUMBER__TRAITS_HPP_
