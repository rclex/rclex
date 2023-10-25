define ERROR_ROS_DISTRO_NOT_DEFINED
Environmental variable `ROS_DISTRO` is not defined.
To use Rclex on a host where ROS 2 is already installed, run `source /opt/ros/${ROS_DISTRO}/setup.bash` first.
Or, if you are going to use Nerves as a target, set the target name of ROS 2 distribution, e.g., `export ROS_DISTRO=humble`.
endef
ifeq ($(origin ROS_DISTRO), undefined)
$(error $(ERROR_ROS_DISTRO_NOT_DEFINED))
endif

ifeq ($(MIX_TARGET), host)
ROS_DIR ?= /opt/ros/$(ROS_DISTRO)
else
ROS_DIR ?= $(NERVES_APP)/rootfs_overlay/opt/ros/$(ROS_DISTRO)
endif

SRC_DIR  = src
OBJ_DIR  = $(MIX_APP_PATH)/obj
PRIV_DIR = $(MIX_APP_PATH)/priv

NIF_SO = $(PRIV_DIR)/rclex.so

CFLAGS  += -O2 -Wall -Wextra -pedantic -fPIC -I$(SRC_DIR)
LDFLAGS += -shared

ERL_CFLAGS  = -I$(ERL_EI_INCLUDE_DIR)
ERL_LDFLAGS = -L$(ERL_EI_LIBDIR)

ifeq ($(ROS_DISTRO), humble)
ROS_INCS    ?= rcl rcutils rmw rcl_yaml_param_parser rosidl_runtime_c rosidl_typesupport_interface
ROS_CFLAGS  ?= $(addprefix -I$(ROS_DIR)/include/, $(ROS_INCS))
else ifeq ($(ROS_DISTRO), iron)
ROS_INCS    ?= rcl rcutils rmw rcl_yaml_param_parser type_description_interfaces rosidl_runtime_c service_msgs builtin_interfaces rosidl_typesupport_interface rosidl_dynamic_typesupport
ROS_CFLAGS  ?= $(addprefix -I$(ROS_DIR)/include/, $(ROS_INCS))
else ifeq ($(ROS_DISTRO), foxy)
ROS_CFLAGS  ?= -I$(ROS_DIR)/include
endif

ROS_LDFLAGS ?= -L$(ROS_DIR)/lib
ROS_LDFLAGS += -lrcl

SRC_C  = $(wildcard $(SRC_DIR)/*.c)
SRC_H  = $(wildcard $(SRC_DIR)/*.h)
OBJ    = $(SRC_C:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)

# ROS 2 package-related setting, especially for msg types
MSG_PKGS = $(patsubst src/pkgs/%/msg,%,$(wildcard src/pkgs/*/msg))
ifneq ($(MSG_PKGS), "")
MSG_PKGS     = $(patsubst src/pkgs/%/msg, %, $(wildcard src/pkgs/*/msg))
SRC_C       += $(wildcard $(MSG_PKGS:%=src/pkgs/%/msg/*.c))
MSG_OBJ_DIR  = $(MSG_PKGS:%=$(OBJ_DIR)/pkgs/%/msg)
ifeq ($(ROS_DISTRO), humble)
ROS_CFLAGS  += $(addprefix -I$(ROS_DIR)/include/, $(MSG_PKGS))
else ifeq ($(ROS_DISTRO), iron)
ROS_CFLAGS  += $(addprefix -I$(ROS_DIR)/include/, $(MSG_PKGS))
endif
ROS_LDFLAGS += $(MSG_PKGS:%=-l%__rosidl_typesupport_c)
ROS_LDFLAGS += $(MSG_PKGS:%=-l%__rosidl_generator_c)
endif

TEMPLATES = lib/rclex/msg_funcs.ex src/msg_funcs.h src/msg_funcs.ec

.PHONY: all
all: $(OBJ_DIR) $(PRIV_DIR) $(MSG_OBJ_DIR) $(TEMPLATES) $(NIF_SO)

$(NIF_SO): $(OBJ)
	$(CC) -o $@ $^ $(LDFLAGS) $(ERL_LDFLAGS) $(ROS_LDFLAGS)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c Makefile $(SRC_H)
	$(CC) -o $@ -c $(CFLAGS) $(ERL_CFLAGS) $(ROS_CFLAGS) $<

$(OBJ_DIR) $(PRIV_DIR) $(MSG_OBJ_DIR):
	@mkdir -p $@

$(TEMPLATES):
	@test ! -f $@ && cp $(PRIV_DIR)/templates/rclex.gen.msgs/$@ $@

.PHONY: clean
clean:
	$(RM) $(NIF_SO) $(OBJ)
	$(RM) $(TEMPLATES)
	$(RM) -r lib/rclex/pkgs src/pkgs
