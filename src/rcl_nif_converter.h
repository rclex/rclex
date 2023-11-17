#ifndef RCL_NIF_CONVERTER_H
#define RCL_NIF_CONVERTER_H
#ifdef __cplusplus
extern "C"
{
#endif
#include "terms.h"
#include <rmw/types.h>

int fill_qos_profile_from_opts(ErlNifEnv* env, ERL_NIF_TERM list, rmw_qos_profile_t* qos_profile);
ERL_NIF_TERM qos_profile_to_keywordlist(ErlNifEnv* env, rmw_qos_profile_t qos);

int term_to_rmw_time(ErlNifEnv* env, ERL_NIF_TERM term, rmw_time_t* time);
ERL_NIF_TERM rmw_time_to_term(ErlNifEnv* env, rmw_time_t time);

#ifdef __cplusplus
}
#endif
#endif