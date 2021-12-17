// generated from rosidl_generator_cpp/resource/idl__builder.hpp.em
// with input from smp_msgs:msg/Namenumber.idl
// generated code does not contain a copyright notice

#ifndef SMP_MSGS__MSG__DETAIL__NAMENUMBER__BUILDER_HPP_
#define SMP_MSGS__MSG__DETAIL__NAMENUMBER__BUILDER_HPP_

#include "smp_msgs/msg/detail/namenumber__struct.hpp"
#include <rosidl_runtime_cpp/message_initialization.hpp>
#include <algorithm>
#include <utility>


namespace smp_msgs
{

namespace msg
{

namespace builder
{

class Init_Namenumber_number
{
public:
  explicit Init_Namenumber_number(::smp_msgs::msg::Namenumber & msg)
  : msg_(msg)
  {}
  ::smp_msgs::msg::Namenumber number(::smp_msgs::msg::Namenumber::_number_type arg)
  {
    msg_.number = std::move(arg);
    return std::move(msg_);
  }

private:
  ::smp_msgs::msg::Namenumber msg_;
};

class Init_Namenumber_name
{
public:
  Init_Namenumber_name()
  : msg_(::rosidl_runtime_cpp::MessageInitialization::SKIP)
  {}
  Init_Namenumber_number name(::smp_msgs::msg::Namenumber::_name_type arg)
  {
    msg_.name = std::move(arg);
    return Init_Namenumber_number(msg_);
  }

private:
  ::smp_msgs::msg::Namenumber msg_;
};

}  // namespace builder

}  // namespace msg

template<typename MessageType>
auto build();

template<>
inline
auto build<::smp_msgs::msg::Namenumber>()
{
  return smp_msgs::msg::builder::Init_Namenumber_name();
}

}  // namespace smp_msgs

#endif  // SMP_MSGS__MSG__DETAIL__NAMENUMBER__BUILDER_HPP_
