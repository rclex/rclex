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

NIF = $(PREFIX)/rclex.so

CFLAGS  ?= -g -O2 -Wall -Wextra -Wno-unused-parameter -pedantic -fPIC
LDFLAGS ?= -g -shared

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

SRC ?= src/total_nif.c src/init_nif.c src/node_nif.c src/publisher_nif.c src/subscription_nif.c src/wait_nif.c
SRC += src/msg_int16_nif.c src/msg_string_nif.c
HEADERS =$(wildcard src/*.h)
OBJ = $(SRC:src/%.c=$(BUILD)/%.o)

all: install

install: $(PREFIX) $(BUILD) $(NIF)

$(OBJ): $(HEADERS) Makefile

$(BUILD)/%.o: src/%.c
	$(CC) -c $(ERL_CFLAGS) $(ROS_CFLAGS) $(CFLAGS) -D$(ROS_VERSION) -o $@ $<

$(NIF): $(OBJ)
	$(CC) -o $@ $(ERL_LDFLAGS) $(LDFLAGS) $^ $(ROS_LDFLAGS)

$(PREFIX):
	mkdir -p $@

$(BUILD):
	mkdir -p $@

clean:
	$(RM) $(NIF) $(BUILD)/*.o

.PHONY: all clean install
