# set directory for ROSDISTRO
ROS_DIR = $(shell which ros2 | sed "s/\/bin\/ros2//")

ifeq ($(ROS_DISTRO), dashing)
	ROS_VERSION = DASHING
	TYPE_STRUCTURE_DIR = rosidl_generator_c
else ifeq ($(ROS_DISTRO), foxy)
	ROS_VERSION = FOXY
	TYPE_STRUCTURE_DIR = rosidl_runtime_c
endif

CC = gcc
LD = ld
RM = rm

PREFIX = $(MIX_APP_PATH)/priv
BUILD  = $(MIX_APP_PATH)/obj

NIF = $(PREFIX)/rclex_nifs.so

CFLAGS  ?= -g -O2 -Wall -Wextra -Wno-unused-parameter -pedantic -fPIC -I src
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
	-l$(TYPE_STRUCTURE_DIR) -lrosidl_typesupport_c \
	-lrosidl_typesupport_introspection_c \
	-lstd_msgs__rosidl_generator_c -lstd_msgs__rosidl_typesupport_c \
	-lfastcdr -lfastrtps -lrmw_fastrtps_cpp
# if you want to use OpenSplice DDS
#ROS_LDFLAGS	+= -lrmw_opensplice_cpp -lrosidl_typesupport_opensplice_cpp

SRC ?= $(wildcard src/*.c) $(wildcard src/std_msgs/msg/*.c)
HEADERS ?= $(wildcard src/*.h) $(wildcard src/std_msgs/msg/*.h)
OBJ ?= $(SRC:%.c=%.o)

calling_from_make:
	mix compile

all: install

install: $(PREFIX) $(BUILD) $(NIF)

$(OBJ): $(HEADERS) Makefile

%.o: %.c
	$(CC) -c $(ERL_CFLAGS) $(ROS_CFLAGS) $(CFLAGS) -D$(ROS_VERSION) -o $@ $<

$(NIF): $(OBJ)
	$(CC) -o $@ $(ERL_LDFLAGS) $(LDFLAGS) $^ $(ROS_LDFLAGS)

$(PREFIX):
	mkdir -p $@

$(BUILD):
	mkdir -p {$@,$@/std_msgs/msg}

clean:
	$(RM) $(NIF) $(BUILD)/*.o

.PHONY: all clean calling_from_make install
