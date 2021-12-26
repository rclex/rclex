# set directory for ROSDISTRO
ROS_DIR = $(shell which ros2 | sed "s/\/bin\/ros2//")

ifeq ($(ROS_DISTRO), dashing)
	ROS_VERSION = DASHING
	TYPE_STRUCTURE_DIR = rosidl_generator_c
else ifeq ($(ROS_DISTRO), foxy)
	ROS_VERSION = FOXY
	TYPE_STRUCTURE_DIR = rosidl_runtime_c
endif

MSGTYPES = $(strip $(shell cat packages.txt))
MSGTYPE_FILES = $(shell echo $(MSGTYPES) | sed -e "s/\([A-Z]\)/_\L\1/g" -e "s/\/_/\//g")
MSGTYPE_FUNCS = $(subst /,__,$(MSGTYPES))
MSGPKGS = $(sort $(foreach msgtype,$(MSGTYPES),$(firstword $(subst /,$() ,$(msgtype)))))
MSGPKG_DIRS = $(shell for msgpkg in $(MSGPKGS); do ros2 pkg prefix $$msgpkg; done)
MT_SEQ = $(shell seq 1 $(words $(MSGTYPES)))
comma = ,

CC = gcc
LD = ld
RM = rm

PREFIX = $(MIX_APP_PATH)/priv
BUILD  = $(MIX_APP_PATH)/obj
BUILD_SUB = $(foreach msgpkg,$(MSGPKGS),$(BUILD)/$(msgpkg)/msg)
EXLIB_SUB = $(foreach msgpkg,$(MSGPKGS),lib/rclex/$(msgpkg)/msg)

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
MSGPKG_CFLAGS  ?= $(foreach DIR,$(MSGPKG_DIRS),-I$(DIR)/include)
MSGPKG_LDFLAGS ?= $(foreach DIR,$(MSGPKG_DIRS),-L$(DIR)/lib)
MSGPKG_LDFLAGS += $(foreach DIR,$(MSGPKG_DIRS),-Wl,-rpath,$(DIR)/lib)
MSGPKG_LDFLAGS += $(foreach msgpkg,$(MSGPKGS),-l$(msgpkg)__rosidl_generator_c -l$(msgpkg)__rosidl_typesupport_c)

SRC ?= $(wildcard src/*.c) $(foreach msgtypefile,$(MSGTYPE_FILES),src/$(msgtypefile)_nif.c)
HEADERS ?= $(SRC:src/%.c=src/%.h)
OBJ ?= $(SRC:src/%.c=$(BUILD)/%.o)
MSGMOD ?= $(MSGTYPE_FILES:%=lib/rclex/%.ex) lib/rclex/nifs.ex

calling_from_make:
	mix compile

all: install
	
install: $(BUILD) $(PREFIX) $(BUILD_SUB) $(EXLIB_SUB) $(NIF) $(MSGMOD)

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
	mkdir -p $(1)
endef
$(foreach subdir,$(BUILD_SUB),$(eval $(call make_dir,$(subdir))))
$(foreach subdir,$(EXLIB_SUB),$(eval $(call make_dir,$(subdir))))

clean:
	$(RM) $(NIF) $(BUILD)/*.o

.PHONY: all clean calling_from_make install


MTNIFS_SRC_START = $(shell grep -n \<custom_msgtype\>_nif.c-----start src/total_nif.c | sed -e "s/:.*//g")
MTNIFS_SRC_END = $(shell grep -n \<custom_msgtype\>_nif.c-----end src/total_nif.c | sed -e "s/:.*//g")
src/total_nif.c: packages.txt 
	sed -i -e "$$(($(MTNIFS_SRC_START)+1)),$$(($(MTNIFS_SRC_END)-1))d" src/total_nif.c
	for msgstr in $(MSGTYPE_FUNCS); do\
	  sed -i -e "$(MTNIFS_SRC_START)a \  {\"readdata_$${msgstr}\",1,nif_readdata_$${msgstr},0}," src/total_nif.c;\
	  sed -i -e "$(MTNIFS_SRC_START)a \  {\"setdata_$${msgstr}\",2,nif_setdata_$${msgstr},0}," src/total_nif.c;\
	  sed -i -e "$(MTNIFS_SRC_START)a \  {\"init_msg_$${msgstr}\",1,nif_init_msg_$${msgstr},0}," src/total_nif.c;\
	  sed -i -e "$(MTNIFS_SRC_START)a \  {\"create_empty_msg_$${msgstr}\",0,nif_create_empty_msg_$${msgstr},0}," src/total_nif.c;\
	  sed -i -e "$(MTNIFS_SRC_START)a \  {\"get_typesupport_$${msgstr}\",0,nif_get_typesupport_$${msgstr},0}," src/total_nif.c;\
	done

MTNIFS_H_START = $(shell grep -n \<custom_msgtype\>_nif.h-----start src/total_nif.h | sed -e "s/:.*//g")
MTNIFS_H_END = $(shell grep -n \<custom_msgtype\>_nif.h-----end src/total_nif.h | sed -e "s/:.*//g")
src/total_nif.h: packages.txt 
	sed -i -e "$$(($(MTNIFS_H_START)+1)),$$(($(MTNIFS_H_END)-1))d" src/total_nif.h
	for msgfile in $(MSGTYPE_FILES); do\
	  sed -i -e "$(MTNIFS_H_START)a #include \"$${msgfile}_nif.h\"" src/total_nif.h;\
	done

MTNIFS_EX_START = $(shell grep -n \<custom_msgtype\>_nif.c-----start lib/rclex/nifs.ex | sed -e "s/:.*//g")
MTNIFS_EX_END = $(shell grep -n \<custom_msgtype\>_nif.c-----end lib/rclex/nifs.ex | sed -e "s/:.*//g")
lib/rclex/nifs.ex: packages.txt
	sed -i -e "$$(($(MTNIFS_EX_START)+1)),$$(($(MTNIFS_EX_END)-1))d" lib/rclex/nifs.ex
	for msgstr in $(MSGTYPE_FUNCS); do\
	  sed -i -e "$(MTNIFS_EX_START)a \  def readdata_$${msgstr}(_), do: raise \"NIF readdata_$${msgstr}/1 is not implemented\"" lib/rclex/nifs.ex;\
	  sed -i -e "$(MTNIFS_EX_START)a \  def setdata_$${msgstr}(_,_), do: raise \"NIF setdata_$${msgstr}/2 is not implemented\"" lib/rclex/nifs.ex;\
	  sed -i -e "$(MTNIFS_EX_START)a \  def init_msg_$${msgstr}(_), do: raise \"NIF init_msg_$${msgstr}/1 is not implemented\"" lib/rclex/nifs.ex;\
	  sed -i -e "$(MTNIFS_EX_START)a \  def create_empty_msg_$${msgstr}, do: raise \"NIF create_empty_msg_$${msgstr}/0 is not implemented\"" lib/rclex/nifs.ex;\
	  sed -i -e "$(MTNIFS_EX_START)a \  def get_typesupport_$${msgstr}, do: raise \"NIF get_typesupport_$${msgstr}/0 is not implemented\"" lib/rclex/nifs.ex;\
	done


msgtype_function_template = ERL_NIF_TERM nif_$(1)(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);
define msgtype_header_template
$(1): src/$(2).msg 
	echo "#include <erl_nif.h>" > $(1)
	echo "$(call msgtype_function_template,get_typesupport_$(3))" >> $(1)
	echo "$(call msgtype_function_template,create_empty_msg_$(3))" >> $(1)
	echo "$(call msgtype_function_template,init_msg_$(3))" >> $(1)
	echo "$(call msgtype_function_template,setdata_$(3))" >> $(1)
	echo "$(call msgtype_function_template,readdata_$(3))" >> $(1)
endef
$(foreach cnt,$(MT_SEQ),$(eval $(call msgtype_header_template,src/$(word $(cnt),$(MSGTYPE_FILES))_nif.h,$(word $(cnt),$(MSGTYPES)),$(word $(cnt),$(MSGTYPE_FUNCS)))))

define msgtype_source_template
$(1): src/$(2).msg src/msgtype_tmp.sh 
	bash src/msgtype_tmp.sh $(2)
endef
$(foreach cnt,$(MT_SEQ),$(eval $(call msgtype_source_template,src/$(word $(cnt),$(MSGTYPE_FILES))_nif.c,$(word $(cnt),$(MSGTYPES)))))

define msgtype_elixir_template
$(1): src/$(2).msg lib/rclex/msgtype_tmp.sh
	bash lib/rclex/msgtype_tmp.sh $(2)
endef
$(foreach cnt,$(MT_SEQ),$(eval $(call msgtype_elixir_template,lib/rclex/$(word $(cnt),$(MSGTYPE_FILES)).ex,$(word $(cnt),$(MSGTYPES)))))


