char simname[] = "Y86 Processor: seq-std.hcl";
#include <stdio.h>
#include "isa.h"
#include "sim.h"
int sim_main(int argc, char *argv[]);
int gen_pc(){return 0;}
int main(int argc, char *argv[])
  {plusmode=0;return sim_main(argc,argv);}
int gen_need_regids()
{
    return ((icode) == (I_RRMOVL)||(icode) == (I_ALU)||(icode) == (I_ALUI)||(icode) == (I_PUSHL)||(icode) == (I_POPL)||(icode) == (I_IRMOVL)||(icode) == (I_RMMOVL)||(icode) == (I_MRMOVL)||(icode) == (I_JREG)||(icode) == (I_JMEM)||(icode) == (I_LEAL));
}

int gen_need_valC()
{
    return ((icode) == (I_IRMOVL)||(icode) == (I_RMMOVL)||(icode) == (I_MRMOVL)||(icode) == (I_JXX)||(icode) == (I_CALL)||(icode) == (I_ALUI)||(icode) == (I_JMEM)||(icode) == (I_LEAL));
}

int gen_instr_valid()
{
    return ((icode) == (I_NOP)||(icode) == (I_HALT)||(icode) == (I_RRMOVL)||(icode) == (I_IRMOVL)||(icode) == (I_RMMOVL)||(icode) == (I_MRMOVL)||(icode) == (I_ALU)||(icode) == (I_ALUI)||(icode) == (I_JXX)||(icode) == (I_CALL)||(icode) == (I_RET)||(icode) == (I_PUSHL)||(icode) == (I_POPL)||(icode) == (I_JREG)||(icode) == (I_JMEM)||(icode) == (I_LEAL)||(icode) == (I_LEAVE));
}

int gen_srcA()
{
    return (((icode) == (I_RRMOVL)||(icode) == (I_RMMOVL)||(icode) == (I_ALU)||(icode) == (I_PUSHL)||(icode) == (I_JREG)) ? (ra) : ((icode) == (I_POPL)||(icode) == (I_RET)) ? (REG_ESP) : ((icode) == (I_LEAVE)) ? (REG_EBP) : 1 ? (REG_NONE) : 0);
}

int gen_srcB()
{
    return (((icode) == (I_ALU)||(icode) == (I_ALUI)||(icode) == (I_RMMOVL)||(icode) == (I_MRMOVL)||(icode) == (I_JMEM)) ? (rb) : ((icode) == (I_PUSHL)||(icode) == (I_POPL)||(icode) == (I_CALL)||(icode) == (I_RET)) ? (REG_ESP) : ((icode) == (I_LEAVE)) ? (REG_EBP) : 1 ? (REG_NONE) : 0);
}

int gen_dstE()
{
    return (((icode) == (I_RRMOVL)||(icode) == (I_IRMOVL)||(icode) == (I_ALU)||(icode) == (I_ALUI)||(icode) == (I_LEAL)) ? (rb) : ((icode) == (I_PUSHL)||(icode) == (I_POPL)||(icode) == (I_CALL)||(icode) == (I_RET)||(icode) == (I_LEAVE)) ? (REG_ESP) : 1 ? (REG_NONE) : 0);
}

int gen_dstM()
{
    return (((icode) == (I_MRMOVL)||(icode) == (I_POPL)) ? (ra) : ((icode) == (I_LEAVE)) ? (REG_EBP) : 1 ? (REG_NONE) : 0);
}

int gen_aluA()
{
    return (((icode) == (I_RRMOVL)||(icode) == (I_ALU)) ? (vala) : ((icode) == (I_IRMOVL)||(icode) == (I_RMMOVL)||(icode) == (I_MRMOVL)||(icode) == (I_ALUI)||(icode) == (I_JMEM)||(icode) == (I_LEAL)) ? (valc) : ((icode) == (I_CALL)||(icode) == (I_PUSHL)) ? -4 : ((icode) == (I_RET)||(icode) == (I_POPL)||(icode) == (I_LEAVE)) ? 4 : 0);
}

int gen_aluB()
{
    return (((icode) == (I_RMMOVL)||(icode) == (I_MRMOVL)||(icode) == (I_ALU)||(icode) == (I_ALUI)||(icode) == (I_CALL)||(icode) == (I_PUSHL)||(icode) == (I_RET)||(icode) == (I_POPL)||(icode) == (I_JMEM)||(icode) == (I_LEAVE)) ? (valb) : ((icode) == (I_RRMOVL)||(icode) == (I_IRMOVL)||(icode) == (I_LEAL)) ? 0 : 0);
}

int gen_alufun()
{
    return (((icode) == (I_ALU)||(icode) == (I_ALUI)) ? (ifun) : 1 ? (A_ADD) : 0);
}

int gen_set_cc()
{
    return ((icode) == (I_ALU)||(icode) == (I_ALUI));
}

int gen_mem_read()
{
    return ((icode) == (I_MRMOVL)||(icode) == (I_POPL)||(icode) == (I_RET)||(icode) == (I_JMEM)||(icode) == (I_LEAVE));
}

int gen_mem_write()
{
    return ((icode) == (I_RMMOVL)||(icode) == (I_PUSHL)||(icode) == (I_CALL));
}

int gen_mem_addr()
{
    return (((icode) == (I_RMMOVL)||(icode) == (I_PUSHL)||(icode) == (I_CALL)||(icode) == (I_MRMOVL)||(icode) == (I_JMEM)) ? (vale) : ((icode) == (I_POPL)||(icode) == (I_RET)||(icode) == (I_LEAVE)) ? (vala) : 0);
}

int gen_mem_data()
{
    return (((icode) == (I_RMMOVL)||(icode) == (I_PUSHL)) ? (vala) : ((icode) == (I_CALL)) ? (valp) : 0);
}

int gen_new_pc()
{
    return (((icode) == (I_CALL)) ? (valc) : (((icode) == (I_JXX)) & (bcond)) ? (valc) : ((icode) == (I_JREG)) ? (vala) : ((icode) == (I_JMEM)) ? (valm) : ((icode) == (I_RET)) ? (valm) : 1 ? (valp) : 0);
}

