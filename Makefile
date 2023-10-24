#-----------------------------------------------------------------------------
#                               EXAMPLES  Makefile
#-----------------------------------------------------------------------------

# the Main program
MAIN = main

# gnatmake
GNATMAKE = gnatmake

# build directory
BUILD_DIR = build

#-----------------------------------------------------------------------------
# Main rule

all :   $(MAIN).adb
	mkdir -p $(BUILD_DIR)
	cd $(BUILD_DIR); $(GNATMAKE) ../$(MAIN)

clean : force
	rm -rf $(BUILD_DIR)

force :

