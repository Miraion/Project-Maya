cmake_minimum_required(VERSION 3.9)
project(maya_virtual_machine C)

set(CMAKE_C_STANDARD 11)

add_executable(maya_virtual_machine
        main.c
        source/virtual_register.c
        headers/virtual_register.h
        source/virtual_cpu.c
        headers/virtual_cpu.h
        source/operations.c
        headers/operations.h
        headers/types.h
        source/types.c
        headers/macro.h
        source/binary_stream.c
        headers/binary_stream.h
        headers/error_t.h
        source/error_t.c
        source/instruction_t.c
        headers/instruction_t.h
        source/instructions.c
        headers/instructions.h
        source/mem_io.c
        headers/mem_io.h
        source/init.c
        headers/init.h
        source/system_inteface.c
        headers/system_inteface.h
        source/fetch.c
        headers/fetch.h source/set.c headers/set.h)
