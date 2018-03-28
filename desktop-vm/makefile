SRC = $(wildcard source/*.c)
OBJ = $(SRC:.c=.o)

main: main.o $(OBJ)
	mv	*.o source
	gcc -o virtual-machine source/main.o $(OBJ)

%.o: %.c
	gcc -O3 -c $<

clean:
	rm -f source/*.o
