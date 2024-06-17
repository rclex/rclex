// clang-format off
#include "set_bool.h"
#include "../../../macros.h"
#include "../../../resource_types.h"
#include "../../../terms.h"

#include <erl_nif.h>

#include <rosidl_runtime_c/service_type_support_struct.h>
#include <std_srvs/srv/set_bool.h>

ERL_NIF_TERM nif_std_srvs_srv_set_bool_type_support(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ignore_unused(argv);

  if (argc != 0) return enif_make_badarg(env);

  const rosidl_service_type_support_t * ts_p = ROSIDL_GET_SRV_TYPE_SUPPORT(std_srvs, srv, SetBool);
  rosidl_service_type_support_t *obj = enif_alloc_resource(rt_rosidl_service_type_support_t, sizeof(rosidl_service_type_support_t));
  *obj = *ts_p;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}
