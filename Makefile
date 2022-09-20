# set directory for ROSDISTRO
ROS_DIR = $(shell which ros2 | sed "s/\/bin\/ros2//")

ifeq ($(ROS_DISTRO), dashing)
	ROS_VERSION = DASHING
	TYPE_STRUCTURE_DIR = rosidl_generator_c
else ifeq ($(ROS_DISTRO), foxy)
	ROS_VERSION = FOXY
	TYPE_STRUCTURE_DIR = rosidl_runtime_c
endif

MSGTYPES = std_msgs/msg/String
MSGTYPE_FILES = $(shell echo $(MSGTYPES) | sed -e "s/\([A-Z]\)/_\L\1/g" -e "s/\/_/\//g")
MSGTYPE_FUNCS = $(subst /,_,$(MSGTYPE_FILES))
MSGPKGS = $(sort $(foreach msgtype,$(MSGTYPES),$(firstword $(subst /,$() ,$(msgtype)))))
MSGPKG_DIRS = $(shell for msgpkg in $(MSGPKGS); do ros2 pkg prefix $$msgpkg; done)
MT_SEQ = $(shell seq 1 $(words $(MSGTYPES)))

CC = gcc
LD = ld
RM = rm

PREFIX = $(MIX_APP_PATH)/priv
BUILD  = $(MIX_APP_PATH)/obj
BUILD_SUB = $(MSGPKGS:%=$(BUILD)/%/msg)
SRC_SUB = $(MSGPKGS:%=src/%/msg)
EXLIB_SUB = $(MSGPKGS:%=lib/rclex/%/msg)

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
	-l$(TYPE_STRUCTURE_DIR) -lrosidl_typesupport_c \
	-lrosidl_typesupport_introspection_c \
	-lfastcdr -lfastrtps -lrmw_fastrtps_cpp \
# if you want to use OpenSplice DDS
#ROS_LDFLAGS	+= -lrmw_opensplice_cpp -lrosidl_typesupport_opensplice_cpp

# for msgpkg libs
MSGPKG_CFLAGS  ?= $(MSGPKG_DIRS:%=-I%/include)
MSGPKG_LDFLAGS ?= $(MSGPKG_DIRS:%=-L%/lib)
MSGPKG_LDFLAGS += $(MSGPKG_DIRS:%=-Wl,-rpath,%/lib)
MSGPKG_LDFLAGS += $(MSGPKGS:%=-l%__rosidl_generator_c)
MSGPKG_LDFLAGS += $(MSGPKGS:%=-l%__rosidl_typesupport_c)

SRC ?= $(wildcard src/*.c) $(MSGTYPE_FILES:%=src/%_nif.c)
HEADERS ?= $(SRC:src/%.c=src/%.h)
OBJ ?= $(SRC:src/%.c=$(BUILD)/%.o)
MSGMOD ?= $(MSGTYPE_FILES:%=lib/rclex/%.ex) lib/rclex/nifs.ex

calling_from_make:
	mix compile

all: install
	
install: $(BUILD) $(PREFIX) $(BUILD_SUB) $(SRC_SUB) $(EXLIB_SUB) $(NIF) $(MSGMOD)

$(OBJ): $(HEADERS) Makefile

$(BUILD)/%.o: src/%.c
	$(CC) -c $(ERL_CFLAGS) $(ROS_CFLAGS) $(MSGPKG_CFLAGS) $(CFLAGS) -D$(ROS_VERSION) -o $@ $<

$(NIF): $(OBJ)
	$(CC) -o $@ $(ERL_LDFLAGS) $(LDFLAGS) $^ $(ROS_LDFLAGS) $(MSGPKG_LDFLAGS)

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
	$(RM) $(NIF) $(BUILD)/*.o

.PHONY: all clean calling_from_make install
