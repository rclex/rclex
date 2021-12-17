# set directory for ROSDISTRO
ROS_DIR = $(shell which ros2 | sed "s/\/bin\/ros2//")

ifeq ($(ROS_DISTRO), dashing)
	ROS_VERSION = DASHING
	TYPE_STRUCTURE_DIR = rosidl_generator_c
else ifeq ($(ROS_DISTRO), foxy)
	ROS_VERSION = FOXY
	TYPE_STRUCTURE_DIR = rosidl_runtime_c
endif

SMP_MSG_DIR = smp_msgs#$(HOME)/colcon_ws/install/smp_msgs

CC = gcc
LD = ld
RM = rm

PREFIX = $(MIX_APP_PATH)/priv
BUILD  = $(MIX_APP_PATH)/obj

NIF = $(PREFIX)/rclex_nifs.so

CFLAGS  ?= -g -O2 -Wall -Wextra -Wno-unused-parameter -pedantic -fPIC -I./src
LDFLAGS ?= -g -shared

# Enabling this line prints debug messages on NIFs code.
#CFLAGS  += -DDEBUG_BUILD

# Set Erlang-specific compile and linker flags
ERL_CFLAGS  ?= -I$(ERL_EI_INCLUDE_DIR)
ERL_LDFLAGS ?= -L$(ERL_EI_LIBDIR)

# for ROS libs
ROS_CFLAGS  ?= -I$(ROS_DIR)/include -I$(SMP_MSG_DIR)/include
ROS_LDFLAGS ?= -L$(ROS_DIR)/lib -L$(SMP_MSG_DIR)/lib
ROS_LDFLAGS += -lrcl -lrmw -lrcutils \
	-l$(TYPE_STRUCTURE_DIR) -lrosidl_typesupport_c \
	-lrosidl_typesupport_introspection_c \
	-lstd_msgs__rosidl_generator_c -lstd_msgs__rosidl_typesupport_c \
	-lfastcdr -lfastrtps -lrmw_fastrtps_cpp \
	-lsmp_msgs__rosidl_generator_c -lsmp_msgs__rosidl_typesupport_c
ROS_LDFLAGS += -Wl,-rpath $(SMP_MSG_DIR)/lib
# if you want to use OpenSplice DDS
#ROS_LDFLAGS	+= -lrmw_opensplice_cpp -lrosidl_typesupport_opensplice_cpp

SRC ?= $(wildcard src/*.c) $(wildcard src/std_msgs/msg/*.c) $(wildcard src/smp_msgs/msg/*.c)
#HEADERS ?= $(SRC:%.c=%.h)
HEADERS ?= $(wildcard src/*.h)
OBJ ?= $(SRC:src/%.c=$(BUILD)/%.o)

calling_from_make:
	mix compile

all: install

install: $(NIF)

$(OBJ): $(HEADERS) Makefile

$(BUILD)/%.o: src/%.c
	@mkdir -p $(@D)
	$(CC) -c $(ERL_CFLAGS) $(ROS_CFLAGS) $(CFLAGS) -D$(ROS_VERSION) -o $@ $<

$(NIF): $(OBJ)
	@mkdir -p $(PREFIX)
	$(CC) -o $@ $(ERL_LDFLAGS) $(LDFLAGS) $^ $(ROS_LDFLAGS)

clean:
	$(RM) $(NIF) $(BUILD)/*.o

.PHONY: all clean calling_from_make install
