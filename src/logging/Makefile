all:
	gcc -march=native -mtune=native -finline-small-functions -fno-default-inline -O2 -flto -s -c logging.c -o logging.o
	ar rcs liblogging.a logging.o
	rm -rf logging.o
	mv liblogging.a ../lib
