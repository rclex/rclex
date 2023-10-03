#define debug(...)                                                                                 \
  do {                                                                                             \
    enif_fprintf(stderr, __VA_ARGS__);                                                             \
    enif_fprintf(stderr, "\r\n");                                                                  \
    fflush(stderr);                                                                                \
  } while (0)

#define ignore_unused(param)                                                                       \
  do {                                                                                             \
    (void)param;                                                                                   \
  } while (0)
