# set directory for ROSDISTRO
ROS_DIR = /opt/ros/foxy

ROS_DISTRO_UPPER = $(shell echo $(ROS_DISTRO) | tr a-z A-Z)

MSGTYPES = std_msgs/msg/String geometry_msgs/msg/Twist
MSGTYPE_FILES = std_msgs/msg/string geometry_msgs/msg/twist geometry_msgs/msg/vector3
MSGTYPE_FUNCS = std_msgs_msg_string geometry_msgs_msg_twist
MSGPKGS = geometry_msgs std_msgs
MSGPKG_DIRS = /opt/ros/foxy
MT_SEQ = 1 2

PREFIX = $(MIX_APP_PATH)/priv
BUILD  = $(MIX_APP_PATH)/obj
OLD_SUB = src/std_msgs/ src/geometry_msgs/ lib/rclex/geometry_msgs/ lib/rclex/std_msgs/
BUILD_SUB = $(BUILD)/geometry_msgs/msg $(BUILD)/std_msgs/msg
SRC_SUB = src/geometry_msgs/msg src/std_msgs/msg
EXLIB_SUB = lib/rclex/geometry_msgs/msg lib/rclex/std_msgs/msg

NIF = $(PREFIX)/rclex_nifs.so

CFLAGS  ?= -g -O2 -Wall -Wextra -Wno-unused-parameter -pedantic -fPIC -I./src
LDFLAGS ?= -g -shared

# Enabling this line prints debug messages on NIFs code.
#CFLAGS  += -DDEBUG_BUILD

# Set Erlang-specific compile and linker flags
ERL_CFLAGS  ?= -I$(ERL_EI_INCLUDE_DIR)
ERL_LDFLAGS ?= -L$(ERL_EI_LIBDIR)

# for ROS libs
ROS_CFLAGS  ?= -I$(ROS_DIR)/include
ROS_LDFLAGS ?= -L$(ROS_DIR)/lib
ROS_LDFLAGS += -lrcl -lrmw -lrcutils \
	-lrosidl_runtime_c -lrosidl_typesupport_c \
	-lrosidl_typesupport_introspection_c \
	-lfastcdr -lfastrtps -lrmw_fastrtps_cpp \
# if you want to use OpenSplice DDS
#ROS_LDFLAGS	+= -lrmw_opensplice_cpp -lrosidl_typesupport_opensplice_cpp

# for msgpkg libs
MSGPKG_CFLAGS  ?= -I/opt/ros/foxy/include
MSGPKG_LDFLAGS ?= -L/opt/ros/foxy/lib
MSGPKG_LDFLAGS += -Wl,-rpath,/opt/ros/foxy/lib
MSGPKG_LDFLAGS += -lgeometry_msgs__rosidl_generator_c -lstd_msgs__rosidl_generator_c
MSGPKG_LDFLAGS += -lgeometry_msgs__rosidl_typesupport_c -lstd_msgs__rosidl_typesupport_c

SRC ?= $(wildcard src/*.c) $(MSGTYPE_FILES:%=src/%_nif.c)
HEADERS ?= $(SRC:src/%.c=src/%.h)
OBJ ?= $(SRC:src/%.c=$(BUILD)/%.o)
MSGMOD ?= $(MSGTYPE_FILES:%=lib/rclex/%.ex) lib/rclex/nifs.ex

calling_from_make:
	mix compile

all: install
	
install: $(OLD_SUB) $(BUILD) $(PREFIX) $(BUILD_SUB) $(SRC_SUB) $(EXLIB_SUB) $(NIF) $(MSGMOD)

$(OBJ): $(HEADERS) Makefile

$(BUILD)/%.o: src/%.c
	$(CC) -c $(ERL_CFLAGS) $(ROS_CFLAGS) $(MSGPKG_CFLAGS) $(CFLAGS) -D$(ROS_DISTRO_UPPER) -o $@ $<

$(NIF): $(OBJ)
	$(CC) -o $@ $(ERL_LDFLAGS) $(LDFLAGS) $^ $(ROS_LDFLAGS) $(MSGPKG_LDFLAGS)

$(OLD_SUB): packages.txt
	$(RM) -r $@

$(BUILD):
	@mkdir -p $(BUILD)

$(PREFIX):
	@mkdir -p $(PREFIX)

define make_dir
$(1):
	@mkdir -p $(1)
endef
$(foreach subdir,$(BUILD_SUB),$(eval $(call make_dir,$(subdir))))
$(foreach subdir,$(SRC_SUB),$(eval $(call make_dir,$(subdir))))
$(foreach subdir,$(EXLIB_SUB),$(eval $(call make_dir,$(subdir))))

clean:
	$(RM) -rf $(NIF) $(BUILD)/*.o
	$(RM) -rf lib/rclex/std_msgs lib/rclex/geometry_msgs src/std_msgs src/geometry_msgs

.PHONY: all clean calling_from_make install
