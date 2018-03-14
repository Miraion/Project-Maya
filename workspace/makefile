# Assembler
ASM = ./bin/assembler

# Virtual Machine
VM = ./bin/virtual-machine

# Standard library source/object files.
STDLIB_SRC = $(wildcard stdlib/*.mia)
STDLIB_OBJ = $(STDLIB_SRC:.mia=.mio)

all: main.mx

run: main.mx
	$(info Running Executable)
	$(info ------------------)
	@$(VM) main.mx

main.mx: testfile.mio $(STDLIB_OBJ)
	$(info Linking...)
	@$(ASM) -o main.mx testfile.mio $(STDLIB_OBJ)

%.mio: %.mia
	$(info Compiling $<...)
	@$(ASM) -c $<

clean:
	$(info Cleaning...)
	@rm -f *.mio *.mx
	@rm -f stdlib/*.mio
