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

ERL_CFLAGS  ?= -I$(ERTS_INCLUDE_DIR) -I$(ERL_EI_INCLUDE_DIR)
ERL_LDFLAGS ?= -L$(ERL_EI_LIBDIR) -lei

ifeq ($(ROS_DISTRO), humble)
ROS_INCS    ?= rcl rcutils rmw rcl_yaml_param_parser rosidl_runtime_c rosidl_typesupport_interface rcl_action action_msgs unique_identifier_msgs
ROS_CFLAGS  ?= $(addprefix -I$(ROS_DIR)/include/, $(ROS_INCS))
else ifeq ($(ROS_DISTRO), iron)
ROS_INCS    ?= rcl rcutils rmw rcl_yaml_param_parser type_description_interfaces rosidl_runtime_c service_msgs builtin_interfaces rosidl_typesupport_interface rosidl_dynamic_typesupport rcl_action action_msgs unique_identifier_msgs
ROS_CFLAGS  ?= $(addprefix -I$(ROS_DIR)/include/, $(ROS_INCS))
else ifeq ($(ROS_DISTRO), jazzy)
ROS_INCS    ?= rcl rcutils rmw rcl_yaml_param_parser type_description_interfaces rosidl_runtime_c service_msgs builtin_interfaces rosidl_typesupport_interface rosidl_dynamic_typesupport rcl_action action_msgs unique_identifier_msgs
ROS_CFLAGS  ?= $(addprefix -I$(ROS_DIR)/include/, $(ROS_INCS))
else ifeq ($(ROS_DISTRO), foxy)
ROS_CFLAGS  ?= -I$(ROS_DIR)/include
endif

ROS_LDFLAGS ?= -L$(ROS_DIR)/lib
ROS_LDFLAGS += -lrcl -lrcl_action

SRC_C  = $(wildcard $(SRC_DIR)/*.c)
SRC_H  = $(wildcard $(SRC_DIR)/*.h)
OBJ    = $(SRC_C:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)

# ROS 2 package-related setting, especially for msg types
MSG_PKGS = $(patsubst src/pkgs/%/msg,%,$(wildcard src/pkgs/*/msg))
SRV_PKGS = $(patsubst src/pkgs/%/srv,%,$(wildcard src/pkgs/*/srv))
ACTION_PKGS = $(patsubst src/pkgs/%/action,%,$(wildcard src/pkgs/*/action))
ifneq ($(MSG_PKGS), "")
MSG_PKGS     = $(patsubst src/pkgs/%/msg, %, $(wildcard src/pkgs/*/msg))
SRV_PKGS     = $(patsubst src/pkgs/%/srv, %, $(wildcard src/pkgs/*/srv))
ACTION_PKGS  = $(patsubst src/pkgs/%/action, %, $(wildcard src/pkgs/*/action))
SRC_C       += $(wildcard $(MSG_PKGS:%=src/pkgs/%/msg/*.c))
SRC_C       += $(wildcard $(SRV_PKGS:%=src/pkgs/%/srv/*.c))
SRC_C       += $(wildcard $(ACTION_PKGS:%=src/pkgs/%/action/*.c))
MSG_OBJ_DIR  = $(MSG_PKGS:%=$(OBJ_DIR)/pkgs/%/msg)
SRV_OBJ_DIR  = $(SRV_PKGS:%=$(OBJ_DIR)/pkgs/%/srv)
ACTION_OBJ_DIR  = $(ACTION_PKGS:%=$(OBJ_DIR)/pkgs/%/action)
ifeq ($(ROS_DISTRO), humble)
ROS_CFLAGS  += $(addprefix -I,$(wildcard $(addprefix $(ROS_DIR)/include/, $(MSG_PKGS))))
ROS_CFLAGS  += $(addprefix -I,$(wildcard $(foreach dir,$(subst :, ,$(ROS2_DIRECTORIES)),$(MSG_PKGS:%=$(dir)/include/%/))))
ROS_CFLAGS  += $(addprefix -I,$(wildcard $(foreach dir,$(subst :, ,$(AMENT_PREFIX_PATH)),$(MSG_PKGS:%=$(dir)/include/%/))))
ROS_CFLAGS  += $(addprefix -I,$(wildcard $(foreach dir,$(subst :, ,$(ROS2_DIRECTORIES)),$(SRV_PKGS:%=$(dir)/include/%/))))
ROS_CFLAGS  += $(addprefix -I,$(wildcard $(foreach dir,$(subst :, ,$(AMENT_PREFIX_PATH)),$(SRV_PKGS:%=$(dir)/include/%/))))
ROS_CFLAGS  += $(addprefix -I,$(wildcard $(foreach dir,$(subst :, ,$(ROS2_DIRECTORIES)),$(ACTION_PKGS:%=$(dir)/include/%/))))
ROS_CFLAGS  += $(addprefix -I,$(wildcard $(foreach dir,$(subst :, ,$(AMENT_PREFIX_PATH)),$(ACTION_PKGS:%=$(dir)/include/%/))))
else ifeq ($(ROS_DISTRO), iron)
ROS_CFLAGS  += $(addprefix -I$(ROS_DIR)/include/, $(MSG_PKGS))
ROS_CFLAGS  += $(addprefix -I,$(wildcard $(foreach dir,$(subst :, ,$(ROS2_DIRECTORIES)),$(MSG_PKGS:%=$(dir)/include/%/))))
ROS_CFLAGS  += $(addprefix -I,$(wildcard $(foreach dir,$(subst :, ,$(AMENT_PREFIX_PATH)),$(MSG_PKGS:%=$(dir)/include/%/))))
ROS_CFLAGS  += $(addprefix -I,$(wildcard $(foreach dir,$(subst :, ,$(ROS2_DIRECTORIES)),$(SRV_PKGS:%=$(dir)/include/%/))))
ROS_CFLAGS  += $(addprefix -I,$(wildcard $(foreach dir,$(subst :, ,$(AMENT_PREFIX_PATH)),$(SRV_PKGS:%=$(dir)/include/%/))))
ROS_CFLAGS  += $(addprefix -I,$(wildcard $(foreach dir,$(subst :, ,$(ROS2_DIRECTORIES)),$(ACTION_PKGS:%=$(dir)/include/%/))))
ROS_CFLAGS  += $(addprefix -I,$(wildcard $(foreach dir,$(subst :, ,$(AMENT_PREFIX_PATH)),$(ACTION_PKGS:%=$(dir)/include/%/))))
else ifeq ($(ROS_DISTRO), jazzy)
ROS_CFLAGS  += $(addprefix -I$(ROS_DIR)/include/, $(MSG_PKGS))
ROS_CFLAGS  += $(addprefix -I,$(wildcard $(foreach dir,$(subst :, ,$(ROS2_DIRECTORIES)),$(MSG_PKGS:%=$(dir)/include/%/))))
ROS_CFLAGS  += $(addprefix -I,$(wildcard $(foreach dir,$(subst :, ,$(AMENT_PREFIX_PATH)),$(MSG_PKGS:%=$(dir)/include/%/))))
ROS_CFLAGS  += $(addprefix -I,$(wildcard $(foreach dir,$(subst :, ,$(ROS2_DIRECTORIES)),$(SRV_PKGS:%=$(dir)/include/%/))))
ROS_CFLAGS  += $(addprefix -I,$(wildcard $(foreach dir,$(subst :, ,$(AMENT_PREFIX_PATH)),$(SRV_PKGS:%=$(dir)/include/%/))))
ROS_CFLAGS  += $(addprefix -I,$(wildcard $(foreach dir,$(subst :, ,$(ROS2_DIRECTORIES)),$(ACTION_PKGS:%=$(dir)/include/%/))))
ROS_CFLAGS  += $(addprefix -I,$(wildcard $(foreach dir,$(subst :, ,$(AMENT_PREFIX_PATH)),$(ACTION_PKGS:%=$(dir)/include/%/))))
endif
ROS_LDFLAGS += $(addprefix -L, $(addsuffix /lib, $(subst :, ,$(ROS2_DIRECTORIES))))
ROS_LDFLAGS += $(addprefix -L, $(addsuffix /lib, $(subst :, ,$(AMENT_PREFIX_PATH))))
ROS_LDFLAGS += $(MSG_PKGS:%=-l%__rosidl_typesupport_c)
ROS_LDFLAGS += $(MSG_PKGS:%=-l%__rosidl_generator_c)
ROS_LDFLAGS += $(SRV_PKGS:%=-l%__rosidl_typesupport_c)
ROS_LDFLAGS += $(SRV_PKGS:%=-l%__rosidl_generator_c)
ROS_LDFLAGS += $(ACTION_PKGS:%=-l%__rosidl_typesupport_c)
ROS_LDFLAGS += $(ACTION_PKGS:%=-l%__rosidl_generator_c)
endif

MSG_TEMPLATES = lib/rclex/msg_funcs.ex src/msg_funcs.h src/msg_funcs.ec
SRV_TEMPLATES = lib/rclex/srv_funcs.ex src/srv_funcs.h src/srv_funcs.ec
ACTION_TEMPLATES = lib/rclex/action_funcs.ex src/action_funcs.h src/action_funcs.ec

COLOUR_GREEN=\033[0;32m
COLOUR_RED=\033[0;31m
COLOUR_BLUE=\033[0;34m
END_COLOUR=\033[0m

.PHONY: all
all: $(OBJ_DIR) $(PRIV_DIR) $(MSG_OBJ_DIR) $(SRV_OBJ_DIR) $(ACTION_OBJ_DIR) $(MSG_TEMPLATES) $(SRV_TEMPLATES) $(ACTION_TEMPLATES) $(NIF_SO)

$(NIF_SO): $(OBJ)
	@echo "$(COLOUR_BLUE)Linking $@$(END_COLOUR)"
	@$(CC) -o $@ $^ $(LDFLAGS) $(ERL_LDFLAGS) $(ROS_LDFLAGS)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c Makefile $(SRC_H)
	@echo "$(COLOUR_BLUE)Compiling $@$(END_COLOUR)"
	@$(CC) -DROS_DISTRO_$(ROS_DISTRO) -o $@ -c $(CFLAGS) $(ERL_CFLAGS) $(ROS_CFLAGS) $<

$(OBJ_DIR) $(PRIV_DIR) $(MSG_OBJ_DIR) $(SRV_OBJ_DIR) $(ACTION_OBJ_DIR):
	@mkdir -p $@

$(MSG_TEMPLATES):
	@test ! -f $@ && cp $(PRIV_DIR)/templates/rclex.gen.msgs/$@ $@

$(SRV_TEMPLATES):
	@test ! -f $@ && cp $(PRIV_DIR)/templates/rclex.gen.srvs/$@ $@

$(ACTION_TEMPLATES):
	@test ! -f $@ && cp $(PRIV_DIR)/templates/rclex.gen.action/$@ $@

.PHONY: clean
clean:
	$(RM) $(NIF_SO) $(OBJ)
	$(RM) $(MSG_TEMPLATES)
	$(RM) $(SRV_TEMPLATES)
	$(RM) $(ACTION_TEMPLATES)
	$(RM) -r lib/rclex/pkgs src/pkgs
