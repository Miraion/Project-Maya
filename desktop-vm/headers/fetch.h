//
// Created by Jeremy S on 2018-03-23.
//

#pragma once

#include "binary_stream.h"
#include "instruction_t.h"

void fetch(instruction *instr, binary_stream *stream, vpu_t vpu);
