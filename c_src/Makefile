# set directory for ROSDISTRO
ROSDIR = /opt/ros/dashing

CC = gcc
LD = ld
RM = rm

PREFIX = $(MIX_APP_PATH)/priv
BUILD  = $(MIX_APP_PATH)/obj
#BUILD += $(MIX_APP_PATH)/obj/msg

NIF = $(PREFIX)/rclex.so

CFLAGS  += -O2 -Wall -Wextra -Wno-unused-parameter -pedantic -fPIC
# MMD means generating .d for dependencies of object files
#CFLAGS  += -MMD -MP
LDFLAGS += -fPIC -shared -L$(ROSDIR)/lib

INCLUDE += -I$(ROSDIR)/include
# for ROS libs
INCLUDE	+= -lrcl -lrmw -lrcutils \
					 -lrosidl_generator_c -lrosidl_typesupport_c \
					 -lstd_msgs__rosidl_generator_c -lstd_msgs__rosidl_typesupport_c \
					 -lrosidl_typesupport_introspection_c  \
					 -lfastcdr -lfastrtps -lrmw_fastrtps_cpp
# if you wanna use OpenSplice DDS
#INCLUDE	+= --lrmw_opensplice_cpp -lrosidl_typesupport_opensplice_cpp

# Set Erlang-specific compile and linker flags
ERL_CFLAGS  ?= -I$(ERL_EI_INCLUDE_DIR)
ERL_LDFLAGS ?= -L$(ERL_EI_LIBDIR)

#SRC = src/fifo_nif.cc
SRC = c_src/src/total_nif.c c_src/src/init_nif.c c_src/src/node_nif.c c_src/src/publisher_nif.c c_src/src/subscription_nif.c c_src/src/wait_nif.c
SRC += c_src/src/msg/msg_int16_nif.c c_src/src/msg/msg_string_nif.c
OBJ = $(SRC:c_src/src/%.c=$(BUILD)/%.o)
OBJ += $(SRC:c_src/src/msg/%.c=$(BUILD)/msg/%.o)
HEADERS =$(wildcard c_src/include*.h)
HEADERS +=$(wildcard c_src/include/msg/*.h)

all: install

install: $(PREFIX) $(BUILD) $(NIF)

$(OBJ): $(SRC)
	$(CC) -c $(ERL_CFLAGS) $(CFLAGS) -o $@ $<

$(BUILD)/%.o: $(SRC)
	$(CC) -c $(ERL_CFLAGS) $(CFLAGS) -o $@ $<

$(NIF): $(OBJ)
	$(CC) -o $@ $(ERL_LDFLAGS) $(LDFLAGS) $(INCLUDE) $^

$(PREFIX):
	mkdir -p $@

$(BUILD):
	mkdir -p $@

clean:
	$(RM) $(NIF) $(BUILD)/*.o

.PHONY: all clean install
