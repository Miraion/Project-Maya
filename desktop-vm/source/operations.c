//
// Created by Jeremy S on 2018-03-16.
//

#include "../headers/operations.h"
#include "../headers/macro.h"
#include "../headers/error_t.h"

#define DIVIDE_BY_ZERO_CHECK(X) \
if ((X) == 0) fatal_error("Divide by zero", EC_DIVZERO)

#define OPERATION_WITH_FLAGS_ASM_OSX(NAME, OPERATION, STORE, TYPE) \
asm(    \
".globl _"NAME"_with_flags_"TYPE"\n" \
"_"NAME"_with_flags_"TYPE":\n" \
"xorl   %eax, %eax  \n" \
"xorl   %r8d, %r8d  \n" \
"xorl   %r9d, %r9d  \n" \
"xorl   %r10d, %r10d\n" \
"xorl   %r11d, %r11d\n" \
OPERATION          "\n" \
"sets   %r8b        \n" \
"setz   %r9b        \n" \
"seto   %r10b       \n" \
"setc   %r11b       \n" \
"orl    %r8d, %eax  \n" \
"shll   $8, %eax    \n" \
"orl    %r9d, %eax  \n" \
"shll   $8, %eax    \n" \
"orl    %r10d, %eax \n" \
"shll   $8, %eax    \n" \
"orl    %r11d, %eax \n" \
"movl   %eax, (%rcx)\n" \
STORE              "\n" \
"ret                \n" \
);

#define OPERATION_WITH_FLAGS_ASM_LINUX(NAME, OPERATION, STORE, TYPE) \
asm(    \
".globl "NAME"_with_overflow_"TYPE"\n" \
NAME"_with_overflow_"TYPE":\n" \
"xorl   %eax, %eax  \n" \
"xorl   %r8d, %r8d  \n" \
"xorl   %r9d, %r9d  \n" \
"xorl   %r10d, %r10d\n" \
"xorl   %r11d, %r11d\n" \
OPERATION          "\n" \
"sets   %r8b        \n" \
"setz   %r9b        \n" \
"seto   %r10b       \n" \
"setc   %r11b       \n" \
"orl    %r8d, %eax  \n" \
"shll   $8, %eax    \n" \
"orl    %r9d, %eax  \n" \
"shll   $8, %eax    \n" \
"orl    %r10d, %eax \n" \
"shll   $8, %eax    \n" \
"orl    %r11d, %eax \n" \
"movl   %eax, (%rcx)\n" \
STORE              "\n" \
"ret                \n" \
);

#if defined(__APPLE__)
OPERATION_WITH_FLAGS_ASM_OSX("adding", "addb %sil, %dil", "movb %dil, (%rdx)", "byte")
OPERATION_WITH_FLAGS_ASM_OSX("adding", "addw  %si,  %di", "movw %di, (%rdx)", "word")
OPERATION_WITH_FLAGS_ASM_OSX("adding", "addl %esi, %edi", "movl %edi, (%rdx)", "long")
OPERATION_WITH_FLAGS_ASM_OSX("adding", "addq %rsi, %rdi", "movq %rdi, (%rdx)", "quad")
OPERATION_WITH_FLAGS_ASM_OSX("subtracting", "subb %sil, %dil", "movb %dil, (%rdx)", "byte")
OPERATION_WITH_FLAGS_ASM_OSX("subtracting", "subw  %si,  %di", "movw %di, (%rdx)", "word")
OPERATION_WITH_FLAGS_ASM_OSX("subtracting", "subl %esi, %edi", "movl %edi, (%rdx)", "long")
OPERATION_WITH_FLAGS_ASM_OSX("subtracting", "subq %rsi, %rdi", "movq %rdi, (%rdx)", "quad")
OPERATION_WITH_FLAGS_ASM_OSX("multiplying", "imulw %si, %di", "movw %di, (%rdx)", "word")
OPERATION_WITH_FLAGS_ASM_OSX("multiplying", "imull %esi, %edi", "movl %edi, (%rdx)", "long")
OPERATION_WITH_FLAGS_ASM_OSX("multiplying", "imulq %rsi, %rdi", "movq %rdi, (%rdx)", "quad")
#elif defined(__linux__)
OPERATION_WITH_FLAGS_ASM_LINUX("adding", "addb %sil, %dil", "movb %dil, (%rdx)", "byte")
OPERATION_WITH_FLAGS_ASM_LINUX("adding", "addw  %si,  %di", "movw %di, (%rdx)", "word")
OPERATION_WITH_FLAGS_ASM_LINUX("adding", "addl %esi, %edi", "movl %edi, (%rdx)", "long")
OPERATION_WITH_FLAGS_ASM_LINUX("adding", "addq %rsi, %rdi", "movq %rdi, (%rdx)", "quad")
OPERATION_WITH_FLAGS_ASM_LINUX("subtracting", "subb %sil, %dil", "movb %dil, (%rdx)", "byte")
OPERATION_WITH_FLAGS_ASM_LINUX("subtracting", "subw  %si,  %di", "movw %di, (%rdx)", "word")
OPERATION_WITH_FLAGS_ASM_LINUX("subtracting", "subl %esi, %edi", "movl %edi, (%rdx)", "long")
OPERATION_WITH_FLAGS_ASM_LINUX("subtracting", "subq %rsi, %rdi", "movq %rdi, (%rdx)", "quad")
OPERATION_WITH_FLAGS_ASM_LINUX("multiplying", "imulw %si, %di", "movw %di, (%rdx)", "word")
OPERATION_WITH_FLAGS_ASM_LINUX("multiplying", "imull %esi, %edi", "movl %edi, (%rdx)", "long")
OPERATION_WITH_FLAGS_ASM_LINUX("multiplying", "imulq %rsi, %rdi", "movq %rdi, (%rdx)", "quad")
#endif

// todo: Add inline assembly for Windows.


void multiplying_with_flags_byte OPERATION_WITH_FLAGS_ARG(uint8_t) {
    *result = a * b;
    flags->ZF = *result == 0;
}

void dividing_with_flags_byte OPERATION_WITH_FLAGS_ARG(uint8_t) {
    DIVIDE_BY_ZERO_CHECK(b);
    *result = a / b;
    flags->ZF = *result == 0;
}

void dividing_with_flags_word OPERATION_WITH_FLAGS_ARG(uint16_t) {
    DIVIDE_BY_ZERO_CHECK(b);
    *result = a / b;
    flags->ZF = *result == 0;
}

void dividing_with_flags_long OPERATION_WITH_FLAGS_ARG(uint32_t) {
    DIVIDE_BY_ZERO_CHECK(b);
    *result = a / b;
    flags->ZF = *result == 0;
}

void dividing_with_flags_quad OPERATION_WITH_FLAGS_ARG(uint64_t) {
    DIVIDE_BY_ZERO_CHECK(b);
    *result = a / b;
    flags->ZF = *result == 0;
}

void modulo_with_flags_byte OPERATION_WITH_FLAGS_ARG(uint8_t) {
    DIVIDE_BY_ZERO_CHECK(b);
    *result = a % b;
    flags->ZF = *result == 0;
}

void modulo_with_flags_word OPERATION_WITH_FLAGS_ARG(uint16_t) {
    DIVIDE_BY_ZERO_CHECK(b);
    *result = a % b;
    flags->ZF = *result == 0;
}

void modulo_with_flags_long OPERATION_WITH_FLAGS_ARG(uint32_t) {
    DIVIDE_BY_ZERO_CHECK(b);
    *result = a % b;
    flags->ZF = *result == 0;
}

void modulo_with_flags_quad OPERATION_WITH_FLAGS_ARG(uint64_t) {
    DIVIDE_BY_ZERO_CHECK(b);
    *result = a % b;
    flags->ZF = *result == 0;
}


#define REG_OPERATION(FNAME, ONAME) \
integer_t FNAME (vreg_t lhs, vreg_t rhs, modifier_t mod, struct flag_complex * flags) { \
    integer_t result; \
    switch (mod) { \
    case byte_m: \
        TOKENPASTE(ONAME, _byte)(reg_get_byte(lhs), \
                               reg_get_byte(rhs), \
                               &result.b, \
                               flags); \
        return result; \
\
    case word_m: \
        TOKENPASTE(ONAME, _word)(reg_get_word(lhs), \
                               reg_get_word(rhs), \
                               &result.w, \
                               flags); \
        return result; \
\
    case long_m: \
        TOKENPASTE(ONAME, _long)(reg_get_long(lhs), \
                               reg_get_long(rhs), \
                               &result.l, \
                               flags); \
        return result; \
\
    case quad_m: \
        TOKENPASTE(ONAME, _quad)(reg_get_quad(lhs), \
                               reg_get_quad(rhs), \
                               &result.q, \
                               flags); \
        return result; \
\
    default: \
        result.q = 0; \
        return result; \
    } \
}

REG_OPERATION(reg_add, adding_with_flags)
REG_OPERATION(reg_sub, subtracting_with_flags)
REG_OPERATION(reg_mul, multiplying_with_flags)
REG_OPERATION(reg_div, dividing_with_flags);
REG_OPERATION(reg_mod, modulo_with_flags);
