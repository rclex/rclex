#include "rcl_graph.h"
#include "allocator.h"
#include "macros.h"
#include "qos.h"
#include "resource_types.h"
#include "terms.h"
#include <erl_nif.h>
#include <rcl/allocator.h>
#include <rcl/graph.h>
#include <rcl/time.h>
#include <rcl/types.h>
#include <rcl_action/graph.h>

static inline ERL_NIF_TERM
make_names_and_types(ErlNifEnv *env, const rcl_names_and_types_t *topic_names_and_types) {
  rcutils_string_array_t names        = topic_names_and_types->names;
  rcutils_string_array_t *types       = topic_names_and_types->types;
  int names_length                    = names.size;
  ERL_NIF_TERM *names_and_types_array = enif_alloc(sizeof(ERL_NIF_TERM) * names_length);

  for (int i = 0; i < names_length; i++) {
    int types_length          = types[i].size;
    ERL_NIF_TERM *types_array = enif_alloc(sizeof(ERL_NIF_TERM) * types_length);
    for (int j = 0; j < types_length; j++) {
      types_array[j] = enif_make_string(env, types[i].data[j], ERL_NIF_LATIN1);
    }
    names_and_types_array[i] =
        enif_make_tuple2(env, enif_make_string(env, names.data[i], ERL_NIF_LATIN1),
                         enif_make_list_from_array(env, types_array, types_length));
  }

  return enif_make_list_from_array(env, names_and_types_array, names_length);
}

static inline ERL_NIF_TERM
make_topic_endpoint_info_list(ErlNifEnv *env,
                              const rcl_topic_endpoint_info_array_t *topic_endpoint_info) {
  int info_length          = topic_endpoint_info->size;
  ERL_NIF_TERM *info_array = enif_alloc(sizeof(ERL_NIF_TERM) * info_length);

  ERL_NIF_TERM atom_invalid      = enif_make_atom(env, "invalid");
  ERL_NIF_TERM atom_publisher    = enif_make_atom(env, "publisher");
  ERL_NIF_TERM atom_subscription = enif_make_atom(env, "subscription");

  ERL_NIF_TERM keys[6] = {
      enif_make_atom(env, "node_name"),    enif_make_atom(env, "node_namespace"),
      enif_make_atom(env, "topic_type"),   enif_make_atom(env, "endpoint_type"),
      enif_make_atom(env, "endpoint_gid"), enif_make_atom(env, "qos_profile")};

  for (int i = 0; i < info_length; i++) {

    ErlNifBinary bin_gid;
    if (!enif_alloc_binary(RMW_GID_STORAGE_SIZE, &bin_gid)) {
      return raise(env, __FILE__, __LINE__);
    }
    memcpy(bin_gid.data, topic_endpoint_info->info_array[i].endpoint_gid, RMW_GID_STORAGE_SIZE);
    bin_gid.size = RMW_GID_STORAGE_SIZE;

    ERL_NIF_TERM endpoint_type = atom_invalid;
    if (topic_endpoint_info->info_array[i].endpoint_type == RMW_ENDPOINT_PUBLISHER) {
      endpoint_type = atom_publisher;
    } else if (topic_endpoint_info->info_array[i].endpoint_type == RMW_ENDPOINT_SUBSCRIPTION) {
      endpoint_type = atom_subscription;
    }

    ERL_NIF_TERM values[6] = {
        enif_make_string(env, topic_endpoint_info->info_array[i].node_name, ERL_NIF_LATIN1),
        enif_make_string(env, topic_endpoint_info->info_array[i].node_namespace, ERL_NIF_LATIN1),
        enif_make_string(env, topic_endpoint_info->info_array[i].topic_type, ERL_NIF_LATIN1),
        endpoint_type,
        enif_make_binary(env, &bin_gid),
        get_ex_qos_profile(env, topic_endpoint_info->info_array[i].qos_profile)};

    if (!enif_make_map_from_arrays(env, keys, values, 6, &info_array[i])) {
      return raise(env, __FILE__, __LINE__);
    }
  }

  return enif_make_list_from_array(env, info_array, info_length);
}

ERL_NIF_TERM nif_rcl_count_publishers(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_node_t *node_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_node_t, (void **)&node_p))
    return enif_make_badarg(env);
  if (!rcl_node_is_valid(node_p)) return raise(env, __FILE__, __LINE__);

  char topic_name[256];
  if (enif_get_string(env, argv[1], topic_name, 256, ERL_NIF_LATIN1) <= 0) {
    return enif_make_badarg(env);
  }

  rcl_ret_t rc;
  size_t count;
  rc = rcl_count_publishers(node_p, topic_name, &count);
  if (rc == RCL_RET_OK)
    return enif_make_uint(env, count);
  else if (rc == RCL_RET_INVALID_ARGUMENT) // if any arguments are invalid
    return enif_make_badarg(env);
  else if (rc == RCL_RET_NODE_INVALID)
    return raise_with_message(env, __FILE__, __LINE__, "the node is invalid");
  else // (rc == RCL_RET_ERROR)
    return raise_with_message(env, __FILE__, __LINE__, "unspecified error");
}

ERL_NIF_TERM nif_rcl_count_subscribers(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_node_t *node_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_node_t, (void **)&node_p))
    return enif_make_badarg(env);
  if (!rcl_node_is_valid(node_p)) return raise(env, __FILE__, __LINE__);

  char topic_name[256];
  if (enif_get_string(env, argv[1], topic_name, 256, ERL_NIF_LATIN1) <= 0) {
    return enif_make_badarg(env);
  }

  rcl_ret_t rc;
  size_t count;
  rc = rcl_count_subscribers(node_p, topic_name, &count);
  if (rc == RCL_RET_OK)
    return enif_make_uint(env, count);
  else if (rc == RCL_RET_INVALID_ARGUMENT) // if any arguments are invalid
    return enif_make_badarg(env);
  else if (rc == RCL_RET_NODE_INVALID)
    return raise_with_message(env, __FILE__, __LINE__, "the node is invalid");
  else // (rc == RCL_RET_ERROR)
    return raise_with_message(env, __FILE__, __LINE__, "unspecified error");
}

ERL_NIF_TERM nif_rcl_get_client_names_and_types_by_node(ErlNifEnv *env, int argc,
                                                        const ERL_NIF_TERM argv[]) {
  if (argc != 3) return enif_make_badarg(env);

  rcl_node_t *node_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_node_t, (void **)&node_p))
    return enif_make_badarg(env);
  if (!rcl_node_is_valid(node_p)) return raise(env, __FILE__, __LINE__);

  char node_name[256];
  if (enif_get_string(env, argv[1], node_name, sizeof(node_name), ERL_NIF_LATIN1) <= 0)
    return enif_make_badarg(env);

  char node_namespace[256];
  if (enif_get_string(env, argv[2], node_namespace, sizeof(node_name), ERL_NIF_LATIN1) <= 0)
    return enif_make_badarg(env);

  rcl_ret_t rc;
  rcl_names_and_types_t client_names_and_types = rmw_get_zero_initialized_names_and_types();
  rcl_allocator_t allocator                    = get_nif_allocator();
  ERL_NIF_TERM term                            = atom_error;

  rc = rcl_get_client_names_and_types_by_node(node_p, &allocator, node_name, node_namespace,
                                              &client_names_and_types);
  if (rc == RCL_RET_OK) { // if the query was successful
    term = make_names_and_types(env, &client_names_and_types);
  } else if (rc == RCL_RET_NODE_INVALID) { // if the node is invalid
    return raise_with_message(env, __FILE__, __LINE__, "node is invalid");
  } else if (rc == RCL_RET_INVALID_ARGUMENT) {
    return raise_with_message(env, __FILE__, __LINE__, "arguments are invalid");
  } else if (rc == RCL_RET_NODE_INVALID_NAME) {
    return raise_with_message(env, __FILE__, __LINE__,
                              "node with an invalid namespace is detected");
  } else if (rc == RCL_RET_NODE_INVALID_NAMESPACE) {
    return raise_with_message(env, __FILE__, __LINE__,
                              "node with an invalid namespace is detected");
  } else if (rc == RCL_RET_NODE_NAME_NON_EXISTENT) {
    term = enif_make_tuple2(env, atom_error, enif_make_atom(env, "not_found"));
    // return raise_with_message(env, __FILE__, __LINE__, "node name was not found");
  } else if (rc == RCL_RET_ERROR) {
    return raise_with_message(env, __FILE__, __LINE__, "unspecified error");
  }

  // cleanup of the names and types struct:
  rc = rcl_names_and_types_fini(&client_names_and_types);
  if (rc != RCL_RET_OK) {
    return raise(env, __FILE__, __LINE__);
  }

  return term;
}

ERL_NIF_TERM nif_rcl_get_node_names(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_node_t *node_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_node_t, (void **)&node_p))
    return enif_make_badarg(env);
  if (!rcl_node_is_valid(node_p)) return raise(env, __FILE__, __LINE__);

  rcl_ret_t rc;
  rcutils_string_array_t node_names      = rcutils_get_zero_initialized_string_array();
  rcutils_string_array_t node_namespaces = rcutils_get_zero_initialized_string_array();
  rcl_allocator_t allocator              = get_nif_allocator();
  ERL_NIF_TERM term                      = atom_error;

  rc = rcl_get_node_names(node_p, allocator, &node_names, &node_namespaces);
  if (rc == RCL_RET_OK) { // if the query was successful
    int node_names_length          = node_names.size;
    ERL_NIF_TERM *node_names_array = enif_alloc(sizeof(ERL_NIF_TERM) * node_names_length);
    for (int i = 0; i < node_names_length; i++) {
      ERL_NIF_TERM node_name      = enif_make_string(env, node_names.data[i], ERL_NIF_LATIN1);
      ERL_NIF_TERM node_namespace = enif_make_string(env, node_namespaces.data[i], ERL_NIF_LATIN1);
      node_names_array[i]         = enif_make_tuple2(env, node_name, node_namespace);
    }
    term = enif_make_list_from_array(env, node_names_array, node_names_length);
  } else if (rc == RCL_RET_INVALID_ARGUMENT) { // if any arguments are invalid
    term = enif_make_badarg(env);
  } else if (rc == RCL_RET_BAD_ALLOC) {
    return raise_with_message(env, __FILE__, __LINE__, "error occurred while allocating memory");
  } else if (rc == RCL_RET_NODE_INVALID_NAME) {
    return raise_with_message(env, __FILE__, __LINE__,
                              "node with an invalid namespace is detected");
  } else if (rc == RCL_RET_NODE_INVALID_NAMESPACE) {
    return raise_with_message(env, __FILE__, __LINE__,
                              "node with an invalid namespace is detected");
  } else if (rc == RCL_RET_ERROR) {
    return raise_with_message(env, __FILE__, __LINE__, "unspecified error");
  }

  // cleanup of the string array structs:
  rc = rcutils_string_array_fini(&node_names);
  if (rc != RCUTILS_RET_OK) {
    return raise(env, __FILE__, __LINE__);
  }

  rc = rcutils_string_array_fini(&node_namespaces);
  if (rc != RCUTILS_RET_OK) {
    return raise(env, __FILE__, __LINE__);
  }

  return term;
}

ERL_NIF_TERM nif_rcl_get_node_names_with_enclaves(ErlNifEnv *env, int argc,
                                                  const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_node_t *node_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_node_t, (void **)&node_p))
    return enif_make_badarg(env);
  if (!rcl_node_is_valid(node_p)) return raise(env, __FILE__, __LINE__);

  rcl_ret_t rc;
  rcutils_string_array_t node_names      = rcutils_get_zero_initialized_string_array();
  rcutils_string_array_t node_namespaces = rcutils_get_zero_initialized_string_array();
  rcutils_string_array_t node_enclaves   = rcutils_get_zero_initialized_string_array();
  rcl_allocator_t allocator              = get_nif_allocator();
  ERL_NIF_TERM term                      = atom_error;

  rc = rcl_get_node_names_with_enclaves(node_p, allocator, &node_names, &node_namespaces,
                                        &node_enclaves);
  if (rc == RCL_RET_OK) { // if the query was successful
    int node_names_length          = node_names.size;
    ERL_NIF_TERM *node_names_array = enif_alloc(sizeof(ERL_NIF_TERM) * node_names_length);
    for (int i = 0; i < node_names_length; i++) {
      ERL_NIF_TERM node_name      = enif_make_string(env, node_names.data[i], ERL_NIF_LATIN1);
      ERL_NIF_TERM node_namespace = enif_make_string(env, node_namespaces.data[i], ERL_NIF_LATIN1);
      ERL_NIF_TERM node_enclave   = enif_make_string(env, node_enclaves.data[i], ERL_NIF_LATIN1);
      node_names_array[i]         = enif_make_tuple3(env, node_name, node_namespace, node_enclave);
    }
    term = enif_make_list_from_array(env, node_names_array, node_names_length);
  } else if (rc == RCL_RET_INVALID_ARGUMENT) { // if any arguments are invalid
    term = enif_make_badarg(env);
  } else if (rc == RCL_RET_BAD_ALLOC) {
    return raise_with_message(env, __FILE__, __LINE__, "error occurred while allocating memory");
  } else if (rc == RCL_RET_NODE_INVALID_NAME) {
    return raise_with_message(env, __FILE__, __LINE__,
                              "node with an invalid namespace is detected");
  } else if (rc == RCL_RET_NODE_INVALID_NAMESPACE) {
    return raise_with_message(env, __FILE__, __LINE__,
                              "node with an invalid namespace is detected");
  } else if (rc == RCL_RET_ERROR) {
    return raise_with_message(env, __FILE__, __LINE__, "unspecified error");
  }

  // cleanup of the string array structs:
  rc = rcutils_string_array_fini(&node_names);
  if (rc != RCUTILS_RET_OK) {
    return raise(env, __FILE__, __LINE__);
  }

  rc = rcutils_string_array_fini(&node_namespaces);
  if (rc != RCUTILS_RET_OK) {
    return raise(env, __FILE__, __LINE__);
  }

  rc = rcutils_string_array_fini(&node_enclaves);
  if (rc != RCUTILS_RET_OK) {
    return raise(env, __FILE__, __LINE__);
  }

  return term;
}

ERL_NIF_TERM nif_rcl_get_publisher_names_and_types_by_node(ErlNifEnv *env, int argc,
                                                           const ERL_NIF_TERM argv[]) {
  if (argc != 4) return enif_make_badarg(env);

  rcl_node_t *node_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_node_t, (void **)&node_p))
    return enif_make_badarg(env);
  if (!rcl_node_is_valid(node_p)) return raise(env, __FILE__, __LINE__);

  char node_name[256];
  if (enif_get_string(env, argv[1], node_name, sizeof(node_name), ERL_NIF_LATIN1) <= 0)
    return enif_make_badarg(env);

  char node_namespace[256];
  if (enif_get_string(env, argv[2], node_namespace, sizeof(node_name), ERL_NIF_LATIN1) <= 0)
    return enif_make_badarg(env);

  bool no_demangle;
  if (enif_compare(argv[3], atom_true) == 0)
    no_demangle = true;
  else if (enif_compare(argv[3], atom_false) == 0)
    no_demangle = false;
  else
    return enif_make_badarg(env);

  rcl_ret_t rc;
  rcl_names_and_types_t topic_names_and_types = rmw_get_zero_initialized_names_and_types();
  rcl_allocator_t allocator                   = get_nif_allocator();
  ERL_NIF_TERM term                           = atom_error;

  rc = rcl_get_publisher_names_and_types_by_node(node_p, &allocator, no_demangle, node_name,
                                                 node_namespace, &topic_names_and_types);
  if (rc == RCL_RET_OK) { // if the query was successful
    term = make_names_and_types(env, &topic_names_and_types);
  } else if (rc == RCL_RET_NODE_INVALID) { // if the node is invalid
    return raise_with_message(env, __FILE__, __LINE__, "node is invalid");
  } else if (rc == RCL_RET_INVALID_ARGUMENT) {
    return raise_with_message(env, __FILE__, __LINE__, "arguments are invalid");
  } else if (rc == RCL_RET_NODE_INVALID_NAME) {
    return raise_with_message(env, __FILE__, __LINE__,
                              "node with an invalid namespace is detected");
  } else if (rc == RCL_RET_NODE_INVALID_NAMESPACE) {
    return raise_with_message(env, __FILE__, __LINE__,
                              "node with an invalid namespace is detected");
  } else if (rc == RCL_RET_NODE_NAME_NON_EXISTENT) {
    term = enif_make_tuple2(env, atom_error, enif_make_atom(env, "not_found"));
    // return raise_with_message(env, __FILE__, __LINE__, "node name was not found");
  } else if (rc == RCL_RET_ERROR) {
    return raise_with_message(env, __FILE__, __LINE__, "unspecified error");
  }

  // cleanup of the names and types struct:
  rc = rcl_names_and_types_fini(&topic_names_and_types);
  if (rc != RCL_RET_OK) {
    return raise(env, __FILE__, __LINE__);
  }

  return term;
}

ERL_NIF_TERM nif_rcl_get_publishers_info_by_topic(ErlNifEnv *env, int argc,
                                                  const ERL_NIF_TERM argv[]) {
  if (argc != 3) return enif_make_badarg(env);

  rcl_node_t *node_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_node_t, (void **)&node_p))
    return enif_make_badarg(env);
  if (!rcl_node_is_valid(node_p)) return raise(env, __FILE__, __LINE__);

  char topic_name[256];
  if (enif_get_string(env, argv[1], topic_name, sizeof(topic_name), ERL_NIF_LATIN1) <= 0)
    return enif_make_badarg(env);

  bool no_mangle;
  if (enif_compare(argv[2], atom_true) == 0)
    no_mangle = true;
  else if (enif_compare(argv[2], atom_false) == 0)
    no_mangle = false;
  else
    return enif_make_badarg(env);

  rcl_ret_t rc;
  rcl_topic_endpoint_info_array_t publishers_info =
      rmw_get_zero_initialized_topic_endpoint_info_array();
  rcl_allocator_t allocator = get_nif_allocator();
  ERL_NIF_TERM term         = atom_error;

  rc =
      rcl_get_publishers_info_by_topic(node_p, &allocator, topic_name, no_mangle, &publishers_info);
  if (rc == RCL_RET_OK) { // if the query was successful
    term = make_topic_endpoint_info_list(env, &publishers_info);
  } else if (rc == RCL_RET_NODE_INVALID) { // if the node is invalid
    return raise_with_message(env, __FILE__, __LINE__, "node is invalid");
  } else if (rc == RCL_RET_INVALID_ARGUMENT) {
    return raise_with_message(env, __FILE__, __LINE__, "arguments are invalid");
  } else if (rc == RCL_RET_BAD_ALLOC) {
    return raise_with_message(env, __FILE__, __LINE__, "memory allocation failed");
  } else if (rc == RCL_RET_ERROR) {
    return raise_with_message(env, __FILE__, __LINE__, "unspecified error");
  }

  // cleanup of the names and types struct:
  rc = rmw_topic_endpoint_info_array_fini(&publishers_info, &allocator);
  if (rc != RMW_RET_OK) {
    return raise(env, __FILE__, __LINE__);
  }

  return term;
}

ERL_NIF_TERM nif_rcl_get_service_names_and_types(ErlNifEnv *env, int argc,
                                                 const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_node_t *node_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_node_t, (void **)&node_p))
    return enif_make_badarg(env);
  if (!rcl_node_is_valid(node_p)) return raise(env, __FILE__, __LINE__);

  rcl_ret_t rc;
  rcl_names_and_types_t service_names_and_types = rmw_get_zero_initialized_names_and_types();
  rcl_allocator_t allocator                     = get_nif_allocator();
  ERL_NIF_TERM term                             = atom_error;

  rc = rcl_get_service_names_and_types(node_p, &allocator, &service_names_and_types);
  if (rc == RCL_RET_OK) { // if the query was successful
    term = make_names_and_types(env, &service_names_and_types);
  } else if (rc == RCL_RET_NODE_INVALID) { // if the node is invalid
    return raise_with_message(env, __FILE__, __LINE__, "node is invalid");
  } else if (rc == RCL_RET_INVALID_ARGUMENT) {
    return raise_with_message(env, __FILE__, __LINE__, "arguments are invalid");
  } else if (rc == RCL_RET_ERROR) {
    return raise_with_message(env, __FILE__, __LINE__, "unspecified error");
  }

  // cleanup of the names and types struct:
  rc = rcl_names_and_types_fini(&service_names_and_types);
  if (rc != RCL_RET_OK) {
    return raise(env, __FILE__, __LINE__);
  }

  return term;
}

ERL_NIF_TERM nif_rcl_get_service_names_and_types_by_node(ErlNifEnv *env, int argc,
                                                         const ERL_NIF_TERM argv[]) {
  if (argc != 3) return enif_make_badarg(env);

  rcl_node_t *node_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_node_t, (void **)&node_p))
    return enif_make_badarg(env);
  if (!rcl_node_is_valid(node_p)) return raise(env, __FILE__, __LINE__);

  char node_name[256];
  if (enif_get_string(env, argv[1], node_name, sizeof(node_name), ERL_NIF_LATIN1) <= 0)
    return enif_make_badarg(env);

  char node_namespace[256];
  if (enif_get_string(env, argv[2], node_namespace, sizeof(node_name), ERL_NIF_LATIN1) <= 0)
    return enif_make_badarg(env);

  rcl_ret_t rc;
  rcl_names_and_types_t service_names_and_types = rmw_get_zero_initialized_names_and_types();
  rcl_allocator_t allocator                     = get_nif_allocator();
  ERL_NIF_TERM term                             = atom_error;

  rc = rcl_get_service_names_and_types_by_node(node_p, &allocator, node_name, node_namespace,
                                               &service_names_and_types);
  if (rc == RCL_RET_OK) { // if the query was successful
    term = make_names_and_types(env, &service_names_and_types);
  } else if (rc == RCL_RET_NODE_INVALID) { // if the node is invalid
    return raise_with_message(env, __FILE__, __LINE__, "node is invalid");
  } else if (rc == RCL_RET_INVALID_ARGUMENT) {
    return raise_with_message(env, __FILE__, __LINE__, "arguments are invalid");
  } else if (rc == RCL_RET_NODE_INVALID_NAME) {
    return raise_with_message(env, __FILE__, __LINE__,
                              "node with an invalid namespace is detected");
  } else if (rc == RCL_RET_NODE_INVALID_NAMESPACE) {
    return raise_with_message(env, __FILE__, __LINE__,
                              "node with an invalid namespace is detected");
  } else if (rc == RCL_RET_ERROR) {
    return raise_with_message(env, __FILE__, __LINE__, "unspecified error");
  }

  // cleanup of the names and types struct:
  rc = rcl_names_and_types_fini(&service_names_and_types);
  if (rc != RCL_RET_OK) {
    return raise(env, __FILE__, __LINE__);
  }

  return term;
}

ERL_NIF_TERM nif_rcl_get_subscriber_names_and_types_by_node(ErlNifEnv *env, int argc,
                                                            const ERL_NIF_TERM argv[]) {
  if (argc != 4) return enif_make_badarg(env);

  rcl_node_t *node_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_node_t, (void **)&node_p))
    return enif_make_badarg(env);
  if (!rcl_node_is_valid(node_p)) return raise(env, __FILE__, __LINE__);

  char node_name[256];
  if (enif_get_string(env, argv[1], node_name, sizeof(node_name), ERL_NIF_LATIN1) <= 0)
    return enif_make_badarg(env);

  char node_namespace[256];
  if (enif_get_string(env, argv[2], node_namespace, sizeof(node_name), ERL_NIF_LATIN1) <= 0)
    return enif_make_badarg(env);

  bool no_demangle;
  if (enif_compare(argv[3], atom_true) == 0)
    no_demangle = true;
  else if (enif_compare(argv[3], atom_false) == 0)
    no_demangle = false;
  else
    return enif_make_badarg(env);

  rcl_ret_t rc;
  rcl_names_and_types_t topic_names_and_types = rmw_get_zero_initialized_names_and_types();
  rcl_allocator_t allocator                   = get_nif_allocator();
  ERL_NIF_TERM term                           = atom_error;

  rc = rcl_get_subscriber_names_and_types_by_node(node_p, &allocator, no_demangle, node_name,
                                                  node_namespace, &topic_names_and_types);
  if (rc == RCL_RET_OK) { // if the query was successful
    term = make_names_and_types(env, &topic_names_and_types);
  } else if (rc == RCL_RET_NODE_INVALID) { // if the node is invalid
    return raise_with_message(env, __FILE__, __LINE__, "node is invalid");
  } else if (rc == RCL_RET_INVALID_ARGUMENT) {
    return raise_with_message(env, __FILE__, __LINE__, "arguments are invalid");
  } else if (rc == RCL_RET_NODE_INVALID_NAME) {
    return raise_with_message(env, __FILE__, __LINE__,
                              "node with an invalid namespace is detected");
  } else if (rc == RCL_RET_NODE_INVALID_NAMESPACE) {
    return raise_with_message(env, __FILE__, __LINE__,
                              "node with an invalid namespace is detected");
  } else if (rc == RCL_RET_NODE_NAME_NON_EXISTENT) {
    term = enif_make_tuple2(env, atom_error, enif_make_atom(env, "not_found"));
    // return raise_with_message(env, __FILE__, __LINE__, "node name was not found");
  } else if (rc == RCL_RET_ERROR) {
    return raise_with_message(env, __FILE__, __LINE__, "unspecified error");
  }

  // cleanup of the names and types struct:
  rc = rcl_names_and_types_fini(&topic_names_and_types);
  if (rc != RCL_RET_OK) {
    return raise(env, __FILE__, __LINE__);
  }

  return term;
}

ERL_NIF_TERM nif_rcl_get_subscribers_info_by_topic(ErlNifEnv *env, int argc,
                                                   const ERL_NIF_TERM argv[]) {
  if (argc != 3) return enif_make_badarg(env);

  rcl_node_t *node_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_node_t, (void **)&node_p))
    return enif_make_badarg(env);
  if (!rcl_node_is_valid(node_p)) return raise(env, __FILE__, __LINE__);

  char topic_name[256];
  if (enif_get_string(env, argv[1], topic_name, sizeof(topic_name), ERL_NIF_LATIN1) <= 0)
    return enif_make_badarg(env);

  bool no_mangle;
  if (enif_compare(argv[2], atom_true) == 0)
    no_mangle = true;
  else if (enif_compare(argv[2], atom_false) == 0)
    no_mangle = false;
  else
    return enif_make_badarg(env);

  rcl_ret_t rc;
  rcl_topic_endpoint_info_array_t subscribers_info =
      rmw_get_zero_initialized_topic_endpoint_info_array();
  rcl_allocator_t allocator = get_nif_allocator();
  ERL_NIF_TERM term         = atom_error;

  rc = rcl_get_subscriptions_info_by_topic(node_p, &allocator, topic_name, no_mangle,
                                           &subscribers_info);
  if (rc == RCL_RET_OK) { // if the query was successful
    term = make_topic_endpoint_info_list(env, &subscribers_info);
  } else if (rc == RCL_RET_NODE_INVALID) { // if the node is invalid
    return raise_with_message(env, __FILE__, __LINE__, "node is invalid");
  } else if (rc == RCL_RET_INVALID_ARGUMENT) {
    return raise_with_message(env, __FILE__, __LINE__, "arguments are invalid");
  } else if (rc == RCL_RET_BAD_ALLOC) {
    return raise_with_message(env, __FILE__, __LINE__, "memory allocation failed");
  } else if (rc == RCL_RET_ERROR) {
    return raise_with_message(env, __FILE__, __LINE__, "unspecified error");
  }

  // cleanup of the names and types struct:
  rc = rmw_topic_endpoint_info_array_fini(&subscribers_info, &allocator);
  if (rc != RMW_RET_OK) {
    return raise(env, __FILE__, __LINE__);
  }

  return term;
}

ERL_NIF_TERM nif_rcl_get_topic_names_and_types(ErlNifEnv *env, int argc,
                                               const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_node_t *node_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_node_t, (void **)&node_p))
    return enif_make_badarg(env);
  if (!rcl_node_is_valid(node_p)) return raise(env, __FILE__, __LINE__);

  bool no_demangle;
  if (enif_compare(argv[1], atom_true) == 0)
    no_demangle = true;
  else if (enif_compare(argv[1], atom_false) == 0)
    no_demangle = false;
  else
    return enif_make_badarg(env);

  rcl_ret_t rc;
  rcl_names_and_types_t topic_names_and_types = rmw_get_zero_initialized_names_and_types();
  rcl_allocator_t allocator                   = get_nif_allocator();
  ERL_NIF_TERM term                           = atom_error;

  rc = rcl_get_topic_names_and_types(node_p, &allocator, no_demangle, &topic_names_and_types);
  if (rc == RCL_RET_OK) { // if the query was successful
    term = make_names_and_types(env, &topic_names_and_types);
  } else if (rc == RCL_RET_NODE_INVALID) { // if the node is invalid
    return raise_with_message(env, __FILE__, __LINE__, "node is invalid");
  } else if (rc == RCL_RET_INVALID_ARGUMENT) {
    return raise_with_message(env, __FILE__, __LINE__, "arguments are invalid");
  } else if (rc == RCL_RET_ERROR) {
    return raise_with_message(env, __FILE__, __LINE__, "unspecified error");
  }

  // cleanup of the names and types struct:
  rc = rcl_names_and_types_fini(&topic_names_and_types);
  if (rc != RCL_RET_OK) {
    return raise(env, __FILE__, __LINE__);
  }

  return term;
}

ERL_NIF_TERM nif_rcl_service_server_is_available(ErlNifEnv *env, int argc,
                                                 const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_node_t *node_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_node_t, (void **)&node_p))
    return enif_make_badarg(env);
  if (!rcl_node_is_valid(node_p)) return raise(env, __FILE__, __LINE__);

  rcl_client_t *client_p;
  if (!enif_get_resource(env, argv[1], rt_rcl_client_t, (void **)&client_p))
    return enif_make_badarg(env);
  if (!rcl_client_is_valid(client_p)) return raise(env, __FILE__, __LINE__);

  rcl_ret_t rc;
  bool is_available;
  ERL_NIF_TERM term = atom_false;

  rc = rcl_service_server_is_available(node_p, client_p, &is_available);
  if (rc == RCL_RET_OK) { // if the query was successful
    if (is_available)
      term = atom_true;
    else
      term = atom_false;
  } else if (rc == RCL_RET_NODE_INVALID) { // if the node is invalid
    return raise_with_message(env, __FILE__, __LINE__, "node is invalid");
  } else if (rc == RCL_RET_INVALID_ARGUMENT) {
    return raise_with_message(env, __FILE__, __LINE__, "arguments are invalid");
  } else if (rc == RCL_RET_ERROR) {
    return raise_with_message(env, __FILE__, __LINE__, "unspecified error");
  }
  return term;
}

/*
ERL_NIF_TERM nif_rcl_wait_for_publishers(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 4) return enif_make_badarg(env);

  rcl_node_t *node_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_node_t, (void **)&node_p))
    return enif_make_badarg(env);
  if (!rcl_node_is_valid(node_p)) return raise(env, __FILE__, __LINE__);

  char topic_name[256];
  if (enif_get_string(env, argv[1], topic_name, sizeof(topic_name), ERL_NIF_LATIN1) <= 0)
    return enif_make_badarg(env);

  size_t count = 0;
  if (!enif_get_uint64(env, argv[2], &count)) return enif_make_badarg(env);

  rcutils_duration_value_t timeout = -1; // timeout in nanoseconds
  if (!enif_get_int64(env, argv[3], &timeout)) return enif_make_badarg(env);

  bool success;
  rcl_ret_t rc;
  rcl_allocator_t allocator = get_nif_allocator();
  ERL_NIF_TERM term         = atom_false;
  rc = rcl_wait_for_publishers(node_p, &allocator, topic_name, count, timeout, &success);
  if (rc == RCL_RET_OK) { // if the query was successful
    if (success)
      term = atom_true;
    else
      term = atom_false;
  } else if (rc == RCL_RET_NODE_INVALID) { // if the node is invalid
    return raise_with_message(env, __FILE__, __LINE__, "node is invalid");
  } else if (rc == RCL_RET_INVALID_ARGUMENT) {
    return raise_with_message(env, __FILE__, __LINE__, "arguments are invalid");
  } else if (rc == RCL_RET_NODE_INVALID_NAME) {
    return raise_with_message(env, __FILE__, __LINE__,
                              "node with an invalid namespace is detected");
  } else if (rc == RCL_RET_NODE_INVALID_NAMESPACE) {
    return raise_with_message(env, __FILE__, __LINE__,
                              "node with an invalid namespace is detected");
  } else if (rc == RCL_RET_ERROR) {
    return raise_with_message(env, __FILE__, __LINE__, "unspecified error");
  }

  return term;
}
*/

/*
ERL_NIF_TERM nif_rcl_wait_for_subscribers(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 4) return enif_make_badarg(env);

  rcl_node_t *node_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_node_t, (void **)&node_p))
    return enif_make_badarg(env);
  if (!rcl_node_is_valid(node_p)) return raise(env, __FILE__, __LINE__);

  char topic_name[256];
  if (enif_get_string(env, argv[1], topic_name, sizeof(topic_name), ERL_NIF_LATIN1) <= 0)
    return enif_make_badarg(env);

  size_t count = 0;
  if (!enif_get_uint64(env, argv[2], &count)) return enif_make_badarg(env);

  rcutils_duration_value_t timeout = -1; // timeout in nanoseconds
  if (!enif_get_int64(env, argv[3], &timeout)) return enif_make_badarg(env);

  bool success;
  rcl_ret_t rc;
  rcl_allocator_t allocator = get_nif_allocator();
  ERL_NIF_TERM term         = atom_false;
  rc = rcl_wait_for_subscribers(node_p, &allocator, topic_name, count, timeout, &success);
  if (rc == RCL_RET_OK) { // if the query was successful
    if (success)
      term = atom_true;
    else
      term = atom_false;
  } else if (rc == RCL_RET_NODE_INVALID) { // if the node is invalid
    return raise_with_message(env, __FILE__, __LINE__, "node is invalid");
  } else if (rc == RCL_RET_INVALID_ARGUMENT) {
    return raise_with_message(env, __FILE__, __LINE__, "arguments are invalid");
  } else if (rc == RCL_RET_NODE_INVALID_NAME) {
    return raise_with_message(env, __FILE__, __LINE__,
                              "node with an invalid namespace is detected");
  } else if (rc == RCL_RET_NODE_INVALID_NAMESPACE) {
    return raise_with_message(env, __FILE__, __LINE__,
                              "node with an invalid namespace is detected");
  } else if (rc == RCL_RET_ERROR) {
    return raise_with_message(env, __FILE__, __LINE__, "unspecified error");
  }

  return term;
}
*/

ERL_NIF_TERM nif_rcl_action_get_client_names_and_types_by_node(ErlNifEnv *env, int argc,
                                                               const ERL_NIF_TERM argv[]) {
  if (argc != 3) return enif_make_badarg(env);

  rcl_node_t *node_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_node_t, (void **)&node_p))
    return enif_make_badarg(env);
  if (!rcl_node_is_valid(node_p)) return raise(env, __FILE__, __LINE__);

  char node_name[256];
  if (enif_get_string(env, argv[1], node_name, sizeof(node_name), ERL_NIF_LATIN1) <= 0)
    return enif_make_badarg(env);

  char node_namespace[256];
  if (enif_get_string(env, argv[2], node_namespace, sizeof(node_name), ERL_NIF_LATIN1) <= 0)
    return enif_make_badarg(env);

  rcl_ret_t rc;
  rcl_names_and_types_t client_names_and_types = rmw_get_zero_initialized_names_and_types();
  rcl_allocator_t allocator                    = get_nif_allocator();
  ERL_NIF_TERM term                            = atom_error;

  rc = rcl_action_get_client_names_and_types_by_node(node_p, &allocator, node_name, node_namespace,
                                                     &client_names_and_types);
  if (rc == RCL_RET_OK) { // if the query was successful
    term = make_names_and_types(env, &client_names_and_types);
  } else if (rc == RCL_RET_NODE_INVALID) { // if the node is invalid
    return raise_with_message(env, __FILE__, __LINE__, "node is invalid");
  } else if (rc == RCL_RET_INVALID_ARGUMENT) {
    return raise_with_message(env, __FILE__, __LINE__, "arguments are invalid");
  } else if (rc == RCL_RET_NODE_INVALID_NAME) {
    return raise_with_message(env, __FILE__, __LINE__,
                              "node with an invalid namespace is detected");
  } else if (rc == RCL_RET_NODE_INVALID_NAMESPACE) {
    return raise_with_message(env, __FILE__, __LINE__,
                              "node with an invalid namespace is detected");
  } else if (rc == RCL_RET_ERROR) {
    return raise_with_message(env, __FILE__, __LINE__, "unspecified error");
  }

  // cleanup of the names and types struct:
  rc = rcl_names_and_types_fini(&client_names_and_types);
  if (rc != RCL_RET_OK) {
    return raise(env, __FILE__, __LINE__);
  }

  return term;
}

ERL_NIF_TERM nif_rcl_action_get_names_and_types(ErlNifEnv *env, int argc,
                                                const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_node_t *node_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_node_t, (void **)&node_p))
    return enif_make_badarg(env);
  if (!rcl_node_is_valid(node_p)) return raise(env, __FILE__, __LINE__);

  rcl_ret_t rc;
  rcl_names_and_types_t action_names_and_types = rmw_get_zero_initialized_names_and_types();
  rcl_allocator_t allocator                    = get_nif_allocator();
  ERL_NIF_TERM term                            = atom_error;

  rc = rcl_action_get_names_and_types(node_p, &allocator, &action_names_and_types);
  if (rc == RCL_RET_OK) { // if the query was successful
    term = make_names_and_types(env, &action_names_and_types);
  } else if (rc == RCL_RET_NODE_INVALID) { // if the node is invalid
    return raise_with_message(env, __FILE__, __LINE__, "node is invalid");
  } else if (rc == RCL_RET_INVALID_ARGUMENT) {
    return raise_with_message(env, __FILE__, __LINE__, "arguments are invalid");
  } else if (rc == RCL_RET_ERROR) {
    return raise_with_message(env, __FILE__, __LINE__, "unspecified error");
  }

  // cleanup of the names and types struct:
  rc = rcl_names_and_types_fini(&action_names_and_types);
  if (rc != RCL_RET_OK) {
    return raise(env, __FILE__, __LINE__);
  }

  return term;
}

ERL_NIF_TERM nif_rcl_action_get_server_names_and_types_by_node(ErlNifEnv *env, int argc,
                                                               const ERL_NIF_TERM argv[]) {
  if (argc != 3) return enif_make_badarg(env);

  rcl_node_t *node_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_node_t, (void **)&node_p))
    return enif_make_badarg(env);
  if (!rcl_node_is_valid(node_p)) return raise(env, __FILE__, __LINE__);

  char node_name[256];
  if (enif_get_string(env, argv[1], node_name, sizeof(node_name), ERL_NIF_LATIN1) <= 0)
    return enif_make_badarg(env);

  char node_namespace[256];
  if (enif_get_string(env, argv[2], node_namespace, sizeof(node_name), ERL_NIF_LATIN1) <= 0)
    return enif_make_badarg(env);

  rcl_ret_t rc;
  rcl_names_and_types_t server_names_and_types = rmw_get_zero_initialized_names_and_types();
  rcl_allocator_t allocator                    = get_nif_allocator();
  ERL_NIF_TERM term                            = atom_error;

  rc = rcl_action_get_server_names_and_types_by_node(node_p, &allocator, node_name, node_namespace,
                                                     &server_names_and_types);
  if (rc == RCL_RET_OK) { // if the query was successful
    term = make_names_and_types(env, &server_names_and_types);
  } else if (rc == RCL_RET_NODE_INVALID) { // if the node is invalid
    return raise_with_message(env, __FILE__, __LINE__, "node is invalid");
  } else if (rc == RCL_RET_INVALID_ARGUMENT) {
    return raise_with_message(env, __FILE__, __LINE__, "arguments are invalid");
  } else if (rc == RCL_RET_NODE_INVALID_NAME) {
    return raise_with_message(env, __FILE__, __LINE__,
                              "node with an invalid namespace is detected");
  } else if (rc == RCL_RET_NODE_INVALID_NAMESPACE) {
    return raise_with_message(env, __FILE__, __LINE__,
                              "node with an invalid namespace is detected");
  } else if (rc == RCL_RET_ERROR) {
    return raise_with_message(env, __FILE__, __LINE__, "unspecified error");
  }

  // cleanup of the names and types struct:
  rc = rcl_names_and_types_fini(&server_names_and_types);
  if (rc != RCL_RET_OK) {
    return raise(env, __FILE__, __LINE__);
  }

  return term;
}