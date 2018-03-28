#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "headers/init.h"
#include "headers/fetch.h"
#include "headers/error_t.h"

int main(int argc, char **argv) {

    if (argc <= 1) {
        printf("Usage: maya [infile]\n");
        return -1;
    }

    char *infile = argv[1];

    if (argc == 3) {
        if (!strcmp(argv[1], "-m")) {
            init_memory_log();
            infile = argv[2];
        } else {
            printf("Usage: maya -m [infile]");
            return -1;
        }
    }

    init_signal_handlers();
    init_error_handlers(exit);
    init_system_interface(desktop_system_interface);
    instruction_list_init();

    vpu_t vpu = vpu_init();

    binary_stream *file = open_stream(infile);

    if (file->error != ERROR_NULL) {
        printf("Unable to open file.\n");
        return 1;
    }

    const size_t stack_size = 0x8000 * 8;
    void *stack_pointer = malloc(stack_size);
    void *top_of_stack = (uint8_t *) stack_pointer + stack_size;
    reg_set(vpu->rs, (uint64_t) top_of_stack);

    vpu->PC = (uint64_t) file->cursor;

    instruction i;
    while (bytes_left(file) != 0 && file->error == ERROR_NULL && !begin_exit_proc) {
        fetch(&i, file, vpu);
        run_instruction(&i, vpu);
        file->cursor = (uint8_t *) vpu->PC;
    }

    if (file->error == ERROR_INVALID_INSTRUCTION || file->error == ERROR_EOF) {
        printf("Error - Possible file corruption.\n");
    } else if (file->error == ERROR_DEFAULT) {
        printf("An unexpected error occurred; Please fix me.\n");
    }

    free(stack_pointer);
    vpu_delete(vpu);
    close_stream(file);

    if (mem_log) {
        mem_log_display_leaks();
        delete_set(mem_log);
    }

    return 0;
}
