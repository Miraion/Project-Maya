//
// Created by Jeremy S on 2018-03-21.
//

#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include "../headers/system_inteface.h"
#include "../headers/init.h"
#include "../headers/error_t.h"

void desktop_system_interface(int x, vpu_t vpu) {
    int64_t result = -1;
    void *p = nullptr;

    switch (x) {

    case sys_exit:
        exit_code = reg_get_long(vpu->r0);
        begin_exit_proc = true;
        break;


    case sys_read:
        result = read((int) reg_get_long(vpu->r0),
                      (void *) reg_get_quad(vpu->r1),
                      (ssize_t) reg_get_quad(vpu->r2));
        break;


    case sys_write:
        result = write((int) reg_get_long(vpu->r0),
              (void *) reg_get_quad(vpu->r1),
              (size_t) reg_get_quad(vpu->r2));
        break;


    case sys_open:
        result = open((char *) reg_get_quad(vpu->r0),
                      reg_get_long(vpu->r1));
        break;


    case sys_close:
        result = close(reg_get_long(vpu->r0));
        break;


    case usr_malloc:
        p = malloc(reg_get_quad(vpu->r0));
        if (mem_log) set_insert(mem_log, p);
        result = (int64_t) p;
        break;


    case usr_free:
        p = (void *) reg_get_quad(vpu->r0);
        if (mem_log && !set_remove(mem_log, p)) {
            bad_free(p);
            exit(EC_BADFREE);
        } else {
            free(p);
        }
        break;


    case dbg_vpudec:
        print_vpu(vpu);
        break;


    case dbg_vpuhex:
        print_vpu(vpu);
        break;


        // todo: Add debug stack printing.
    default:
        break;
    }

    reg_set(vpu->rx, (uint64_t) result);
}
