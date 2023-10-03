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

ERL_CFLAGS  = -I$(ERL_EI_INCLUDE_DIR)
ERL_LDFLAGS = -L$(ERL_EI_LIBDIR)

ROS_CFLAGS  ?= -I$(ROS_DIR)/include
ROS_LDFLAGS ?= -L$(ROS_DIR)/lib
ROS_LDFLAGS += -lrcl

SRC_C  = $(wildcard $(SRC_DIR)/*.c)
SRC_H  = $(wildcard $(SRC_DIR)/*.h)
OBJ    = $(SRC_C:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)

MSG_PKGS     = $(patsubst src/pkgs/%/msg, %, $(wildcard src/pkgs/*/msg))
SRC_C       += $(wildcard $(MSG_PKGS:%=src/pkgs/%/msg/*.c))
MSG_OBJ_DIR  = $(MSG_PKGS:%=$(OBJ_DIR)/pkgs/%/msg)
ROS_LDFLAGS += $(MSG_PKGS:%=-l%__rosidl_typesupport_c)
ROS_LDFLAGS += $(MSG_PKGS:%=-l%__rosidl_generator_c)

.PHONY: all
all: $(OBJ_DIR) $(PRIV_DIR) $(MSG_OBJ_DIR) $(NIF_SO)

$(NIF_SO): $(OBJ)
	$(CC) -o $@ $^ $(LDFLAGS) $(ERL_LDFLAGS) $(ROS_LDFLAGS)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c Makefile $(SRC_H)
	$(CC) -o $@ -c $(CFLAGS) $(ERL_CFLAGS) $(ROS_CFLAGS) $<

$(OBJ_DIR) $(PRIV_DIR) $(MSG_OBJ_DIR):
	@mkdir -p $@

.PHONY: clean
clean:
	$(RM) $(NIF_SO) $(OBJ)
