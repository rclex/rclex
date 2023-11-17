#ifndef ALLOCATOR_H
#define ALLOCATOR_H
#ifdef __cplusplus
extern "C"
{
#endif
#include "rmw/types.h"

rcutils_allocator_t get_nif_allocator();

#ifdef __cplusplus
}
#endif
#endif