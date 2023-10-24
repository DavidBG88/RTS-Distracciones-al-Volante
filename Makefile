#-----------------------------------------------------------------------------
#                               EXAMPLES  Makefile
#-----------------------------------------------------------------------------

# the Main program
MAIN = main

# gnatmake
GNATMAKE = gnatmake

# build directory
BUILD_DIR = build

# Check Windows
ifdef OS
	RM = del /Q
	MKDIR = mkdir
else
	RM = rm -f
	MKDIR = mkdir -p
endif

#-----------------------------------------------------------------------------
# Main rule

all :   $(MAIN).adb
	$(MKDIR) $(BUILD_DIR)
	cd $(BUILD_DIR) && $(GNATMAKE) ../$(MAIN)

clean : force
	$(RM) $(BUILD_DIR)

force :

