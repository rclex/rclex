#include "allocator.h"
#include <erl_nif.h>
#include <rcl/allocator.h>

static void *__nif_allocate(size_t size, void *state) {
  RCUTILS_CAN_RETURN_WITH_ERROR_OF(NULL);

  RCUTILS_UNUSED(state);
  return enif_alloc(size);
}

static void __nif_deallocate(void *pointer, void *state) {
  RCUTILS_UNUSED(state);
  enif_free(pointer);
}

static void *__nif_reallocate(void *pointer, size_t size, void *state) {
  RCUTILS_CAN_RETURN_WITH_ERROR_OF(NULL);

  RCUTILS_UNUSED(state);
  return enif_realloc(pointer, size);
}

static void *__nif_zero_allocate(size_t number_of_elements, size_t size_of_element, void *state) {
  RCUTILS_CAN_RETURN_WITH_ERROR_OF(NULL);

  RCUTILS_UNUSED(state);
  void *mem = enif_alloc(number_of_elements * size_of_element);
  memset((char *)mem, 0, number_of_elements * size_of_element);
  return mem;
}

rcutils_allocator_t get_nif_allocator() {
  static rcutils_allocator_t nif_allocator = {
      .allocate      = __nif_allocate,
      .deallocate    = __nif_deallocate,
      .reallocate    = __nif_reallocate,
      .zero_allocate = __nif_zero_allocate,
      .state         = NULL,
  };
  return nif_allocator;
}
