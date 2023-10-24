#-----------------------------------------------------------------------------
#                               EXAMPLES  Makefile
#-----------------------------------------------------------------------------

# the Main program
MAIN = main

# the gnatmake
GNATMAKE = gnatmake

#-----------------------------------------------------------------------------
# Main rule

all :   $(MAIN).adb
	$(GNATMAKE) $(MAIN)

clean : force
	del -f *.o *.nm *.ali b~*.* *.s *~ $(MAIN) *.map

force :

