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

PREFIX = $(MIX_APP_PATH)/priv
BUILD  = $(MIX_APP_PATH)/obj

NIF = $(PREFIX)/rclex_nifs.so

CFLAGS  += -g -O2 -Wall -Wextra -Wno-unused-parameter -pedantic -fPIC -I./src
LDFLAGS += -g -shared

# Enabling this line prints debug messages on NIFs code.
#CFLAGS  += -DDEBUG_BUILD

# Set Erlang-specific compile and linker flags
ERL_CFLAGS  ?= -I$(ERL_EI_INCLUDE_DIR)
ERL_LDFLAGS ?= -L$(ERL_EI_LIBDIR)

# for ROS libs
ifeq ($(ROS_DISTRO), humble)
ROS_INCS    ?= rcl rcl_yaml_param_parser rcutils rmw rosidl_runtime_c rosidl_typesupport_interface
ROS_CFLAGS  ?= $(addprefix -I$(ROS_DIR)/include/, $(ROS_INCS)) $(addprefix -I, $(wildcard $(ROS_DIR)/include/*_msgs))
else ifeq ($(ROS_DISTRO), iron)
ROS_INCS    ?= rcl rcl_yaml_param_parser rcutils rmw rosidl_runtime_c rosidl_typesupport_interface rosidl_dynamic_typesupport type_description_interfaces builtin_interfaces
ROS_CFLAGS  ?= $(addprefix -I$(ROS_DIR)/include/, $(ROS_INCS)) $(addprefix -I, $(wildcard $(ROS_DIR)/include/*_msgs))
else
ROS_CFLAGS  ?= -I$(ROS_DIR)/include
endif
ROS_LDFLAGS ?= -L$(ROS_DIR)/lib
ROS_LDFLAGS += -lrcl -lrmw -lrcutils \
	-lrosidl_runtime_c -lrosidl_typesupport_c \
	-lrosidl_typesupport_introspection_c \
	-lfastcdr

SRC = $(wildcard src/*.c)
HEADERS = $(SRC:src/%.c=src/%.h)
OBJ = $(SRC:src/%.c=$(BUILD)/%.o)

# ROS 2 package-related setting, especially for msg types
MSG_PKGS = $(patsubst src/pkgs/%/msg,%,$(wildcard src/pkgs/*/msg))
ifneq ($(MSG_PKGS), "")
BUILD_MSG    = $(MSG_PKGS:%=$(BUILD)/pkgs/%/msg)
SRC         += $(wildcard $(MSG_PKGS:%=src/pkgs/%/msg/*.c))
HEADERS      = $(SRC:src/%.c=src/%.h)
OBJ          = $(SRC:src/%.c=$(BUILD)/%.o)
ROS_LDFLAGS += $(MSG_PKGS:%=-l%__rosidl_generator_c)
ROS_LDFLAGS += $(MSG_PKGS:%=-l%__rosidl_typesupport_c)
endif

TEMPLATES = src/msg_types_nif.h src/msg_types_nif.ec lib/rclex/msg_types_nif.ex

calling_from_make:
	mix compile

ifneq ("$(wildcard $(ROS_DIR))", "")
all: $(BUILD) $(BUILD_MSG) $(PREFIX) $(TEMPLATES) $(NIF)
else
all: $(TEMPLATES)
	@echo $(ROS_DIR) does not exist.
	@echo If you would not like to install ROS 2 on your HOST, please check \`mix help rclex.prep.ros2\`.
endif

$(OBJ): $(HEADERS) Makefile

$(BUILD)/%.o: src/%.c
	$(CC) -o $@ -c $(CFLAGS) $(ERL_CFLAGS) $(ROS_CFLAGS) $<

$(NIF): $(OBJ)
	$(CC) -o $@ $^ $(LDFLAGS) $(ERL_LDFLAGS) $(ROS_LDFLAGS)

$(BUILD) $(BUILD_MSG) $(PREFIX):
	@mkdir -p $@

$(TEMPLATES):
	@test ! -f $@ && cp $(PREFIX)/templates/rclex.gen.msgs/$@ $@

clean:
	$(RM) $(NIF) $(OBJ)
	$(RM) -r lib/rclex/pkgs src/pkgs
	$(RM) $(TEMPLATES)

.PHONY: all clean calling_from_make
