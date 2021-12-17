// generated from rosidl_generator_cpp/resource/idl__struct.hpp.em
// with input from smp_msgs:msg/Namenumber.idl
// generated code does not contain a copyright notice

#ifndef SMP_MSGS__MSG__DETAIL__NAMENUMBER__STRUCT_HPP_
#define SMP_MSGS__MSG__DETAIL__NAMENUMBER__STRUCT_HPP_

#include <rosidl_runtime_cpp/bounded_vector.hpp>
#include <rosidl_runtime_cpp/message_initialization.hpp>
#include <algorithm>
#include <array>
#include <memory>
#include <string>
#include <vector>


#ifndef _WIN32
# define DEPRECATED__smp_msgs__msg__Namenumber __attribute__((deprecated))
#else
# define DEPRECATED__smp_msgs__msg__Namenumber __declspec(deprecated)
#endif

namespace smp_msgs
{

namespace msg
{

// message struct
template<class ContainerAllocator>
struct Namenumber_
{
  using Type = Namenumber_<ContainerAllocator>;

  explicit Namenumber_(rosidl_runtime_cpp::MessageInitialization _init = rosidl_runtime_cpp::MessageInitialization::ALL)
  {
    if (rosidl_runtime_cpp::MessageInitialization::ALL == _init ||
      rosidl_runtime_cpp::MessageInitialization::ZERO == _init)
    {
      this->name = "";
      this->number = 0;
    }
  }

  explicit Namenumber_(const ContainerAllocator & _alloc, rosidl_runtime_cpp::MessageInitialization _init = rosidl_runtime_cpp::MessageInitialization::ALL)
  : name(_alloc)
  {
    if (rosidl_runtime_cpp::MessageInitialization::ALL == _init ||
      rosidl_runtime_cpp::MessageInitialization::ZERO == _init)
    {
      this->name = "";
      this->number = 0;
    }
  }

  // field types and members
  using _name_type =
    std::basic_string<char, std::char_traits<char>, typename ContainerAllocator::template rebind<char>::other>;
  _name_type name;
  using _number_type =
    int16_t;
  _number_type number;

  // setters for named parameter idiom
  Type & set__name(
    const std::basic_string<char, std::char_traits<char>, typename ContainerAllocator::template rebind<char>::other> & _arg)
  {
    this->name = _arg;
    return *this;
  }
  Type & set__number(
    const int16_t & _arg)
  {
    this->number = _arg;
    return *this;
  }

  // constant declarations

  // pointer types
  using RawPtr =
    smp_msgs::msg::Namenumber_<ContainerAllocator> *;
  using ConstRawPtr =
    const smp_msgs::msg::Namenumber_<ContainerAllocator> *;
  using SharedPtr =
    std::shared_ptr<smp_msgs::msg::Namenumber_<ContainerAllocator>>;
  using ConstSharedPtr =
    std::shared_ptr<smp_msgs::msg::Namenumber_<ContainerAllocator> const>;

  template<typename Deleter = std::default_delete<
      smp_msgs::msg::Namenumber_<ContainerAllocator>>>
  using UniquePtrWithDeleter =
    std::unique_ptr<smp_msgs::msg::Namenumber_<ContainerAllocator>, Deleter>;

  using UniquePtr = UniquePtrWithDeleter<>;

  template<typename Deleter = std::default_delete<
      smp_msgs::msg::Namenumber_<ContainerAllocator>>>
  using ConstUniquePtrWithDeleter =
    std::unique_ptr<smp_msgs::msg::Namenumber_<ContainerAllocator> const, Deleter>;
  using ConstUniquePtr = ConstUniquePtrWithDeleter<>;

  using WeakPtr =
    std::weak_ptr<smp_msgs::msg::Namenumber_<ContainerAllocator>>;
  using ConstWeakPtr =
    std::weak_ptr<smp_msgs::msg::Namenumber_<ContainerAllocator> const>;

  // pointer types similar to ROS 1, use SharedPtr / ConstSharedPtr instead
  // NOTE: Can't use 'using' here because GNU C++ can't parse attributes properly
  typedef DEPRECATED__smp_msgs__msg__Namenumber
    std::shared_ptr<smp_msgs::msg::Namenumber_<ContainerAllocator>>
    Ptr;
  typedef DEPRECATED__smp_msgs__msg__Namenumber
    std::shared_ptr<smp_msgs::msg::Namenumber_<ContainerAllocator> const>
    ConstPtr;

  // comparison operators
  bool operator==(const Namenumber_ & other) const
  {
    if (this->name != other.name) {
      return false;
    }
    if (this->number != other.number) {
      return false;
    }
    return true;
  }
  bool operator!=(const Namenumber_ & other) const
  {
    return !this->operator==(other);
  }
};  // struct Namenumber_

// alias to use template instance with default allocator
using Namenumber =
  smp_msgs::msg::Namenumber_<std::allocator<void>>;

// constant definitions

}  // namespace msg

}  // namespace smp_msgs

#endif  // SMP_MSGS__MSG__DETAIL__NAMENUMBER__STRUCT_HPP_
