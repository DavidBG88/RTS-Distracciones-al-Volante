all:   main.adb
	gcc -c dispositivos.c	
	gnatmake -c main.adb
	gnatbind main.ali
	gnatlink main.ali dispositivos.o -lwiringPi -lm

clean: force
	@/bin/rm -f *.o *.nm *.ali b~*.* *.s *~ main *.map

force:
