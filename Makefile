# ROS_DISTRO is set by ROS2 setup.bash.
# If not set, ROS2 default distro value is following.
ROS_DISTRO ?= foxy
ROS_DIR ?= /opt/ros/$(ROS_DISTRO)

ROS_DISTRO_UPPER = $(shell echo $(ROS_DISTRO) | tr '[:lower:]' '[:upper:]')

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
ROS_CFLAGS  ?= -I$(ROS_DIR)/include
ROS_LDFLAGS ?= -L$(ROS_DIR)/lib
ROS_LDFLAGS += -lrcl -lrmw -lrcutils \
	-lrosidl_runtime_c -lrosidl_typesupport_c \
	-lrosidl_typesupport_introspection_c \
	-lfastcdr -lfastrtps -lrmw_fastrtps_cpp \
# if you want to use OpenSplice DDS
#ROS_LDFLAGS += -lrmw_opensplice_cpp -lrosidl_typesupport_opensplice_cpp

SRC = $(wildcard src/*.c)
HEADERS = $(SRC:src/%.c=src/%.h)
OBJ = $(SRC:src/%.c=$(BUILD)/%.o)

# WRITE ROS2 package-related settings HERE
MSG_PKGS = $(patsubst src/pkgs/%/msg,%,$(wildcard src/pkgs/*/msg))
ifneq "$(MSG_PKGS)" ""
BUILD_MSG    = $(MSG_PKGS:%=$(BUILD)/pkgs/%/msg)
SRC         += $(wildcard $(MSG_PKGS:%=src/pkgs/%/msg/*.c))
HEADERS      = $(SRC:src/%.c=src/%.h)
OBJ          = $(SRC:src/%.c=$(BUILD)/%.o)
ROS_LDFLAGS += $(MSG_PKGS:%=-l%__rosidl_generator_c)
ROS_LDFLAGS += $(MSG_PKGS:%=-l%__rosidl_typesupport_c)
endif

calling_from_make:
	mix compile

all: install

install: $(BUILD) $(BUILD_MSG) $(PREFIX) $(NIF)

$(OBJ): $(HEADERS) Makefile

$(BUILD)/%.o: src/%.c
	$(CC) -o $@ -c $(CFLAGS) $(ERL_CFLAGS) $(ROS_CFLAGS) -D$(ROS_DISTRO_UPPER) $<

# gcc 
$(NIF): $(OBJ)
	$(CC) -o $@ $^ $(LDFLAGS) $(ERL_LDFLAGS) $(ROS_LDFLAGS)

$(BUILD) $(BUILD_MSG) $(PREFIX):
	@mkdir -p $@

clean:
	$(RM) -r $(NIF) $(BUILD)/*.o
	mix rclex.gen.msgs --clean

# Even if mix compile failed, we can clean by following
clean_without_mix:
	$(RM) -r $(NIF) $(BUILD)/*.o
	$(RM) -r lib/rclex/pkgs src/pkgs
	cp -f priv/templates/rclex.gen.msgs/msg_types_nif.ex lib/rclex/msg_types_nif.ex
	cp -f priv/templates/rclex.gen.msgs/msg_types_nif.h  src/msg_types_nif.h
	cp -f priv/templates/rclex.gen.msgs/msg_types_nif.ec  src/msg_types_nif.ec

.PHONY: all clean clean_without_mix calling_from_make install
