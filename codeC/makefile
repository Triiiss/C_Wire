all: c-wire_exec

utilitary.o: utilitary.c main.h
	gcc -c utilitary.c -o utilitary.o

Avl.o: Avl.c main.h
	gcc -c Avl.c -o Avl.o

c-wire.o:c-wire.c main.h
	gcc -c c-wire.c -o c-wire.o
	
c-wire_exec: c-wire.o Avl.o utilitary.o main.h
	gcc utilitary.o Avl.o c-wire.o -o c-wire_exec
	
clean :
	rm -f *.o
	rm c-wire_exec
