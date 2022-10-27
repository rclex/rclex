# ROS_DISTRO is set by setup.bash in /opt/ros/${ROS_DISTRO}/.
ifneq ($(origin ROS_DISTRO), undefined)
ROS_DIR ?= /opt/ros/$(ROS_DISTRO)
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

ifneq ($(origin ROS_DIR), undefined)
all: $(BUILD) $(BUILD_MSG) $(PREFIX) $(TEMPLATES) $(NIF)
else
all: $(TEMPLATES)
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
