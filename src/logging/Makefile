all:
	gcc -c logging.c -o logging.o
	ar rcs liblogging.a logging.o
	rm -rf logging.o
	mv liblogging.a ../lib
