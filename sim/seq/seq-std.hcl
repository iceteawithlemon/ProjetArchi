#/* $begin seq-all-hcl */
#/* $begin seq-plus-all-hcl */
####################################################################
#  HCL Description of Control for Single Cycle Y86 Processor SEQ   #
#  Copyright (C) Randal E. Bryant, David R. O'Hallaron, 2002       #
####################################################################

####################################################################
#    C Include's.  Don't alter these                               #
####################################################################

quote '#include <stdio.h>'
quote '#include "isa.h"'
quote '#include "sim.h"'
quote 'int sim_main(int argc, char *argv[]);'
quote 'int gen_pc(){return 0;}'
quote 'int main(int argc, char *argv[])'
quote '  {plusmode=0;return sim_main(argc,argv);}'

####################################################################
#    Declarations.  Do not change/remove/delete any of these       #
####################################################################

##### Symbolic representation of Y86 Instruction Codes #############
intsig NOP 	'I_NOP'
intsig HALT	'I_HALT'
intsig RRMOVL	'I_RRMOVL'
intsig IRMOVL	'I_IRMOVL'
intsig RMMOVL	'I_RMMOVL'
intsig MRMOVL	'I_MRMOVL'
intsig OPL	'I_ALU'
intsig IOPL	'I_ALUI'
intsig JXX	'I_JXX'
intsig CALL	'I_CALL'
intsig RET	'I_RET'
intsig PUSHL	'I_PUSHL'
intsig POPL	'I_POPL'
intsig JMEM	'I_JMEM'
intsig JREG	'I_JREG'
intsig LEAVE	'I_LEAVE'


##### Symbolic representation of Y86 Registers referenced explicitly #####
intsig RESP     'REG_ESP'    	# Stack Pointer
intsig REBP     'REG_EBP'    	# Frame Pointer
intsig RNONE    'REG_NONE'   	# Special value indicating "no register"

##### ALU Functions referenced explicitly                            #####
intsig ALUADD	'A_ADD'		# ALU should add its arguments

##### Signals that can be referenced by control logic ####################

##### Fetch stage inputs		#####
intsig pc 'pc'				# Program counter
##### Fetch stage computations		#####
intsig icode	'icode'			# Instruction control code
intsig ifun	'ifun'			# Instruction function
intsig rA	'ra'			# rA field from instruction
intsig rB	'rb'			# rB field from instruction
intsig valC	'valc'			# Constant from instruction
intsig valP	'valp'			# Address of following instruction

##### Decode stage computations		#####
intsig valA	'vala'			# Value from register A port
intsig valB	'valb'			# Value from register B port

##### Execute stage computations	#####
intsig valE	'vale'			# Value computed by ALU
boolsig Bch	'bcond'			# Branch test

##### Memory stage computations		#####
intsig valM	'valm'			# Value read from memory


####################################################################
#    Control Signal Definitions.                                   #
####################################################################


################ Fetch Stage     ###################################

# Does fetched instruction require a regid byte?
bool need_regids =
	icode in { RRMOVL, OPL, IOPL, PUSHL, POPL, IRMOVL, RMMOVL, MRMOVL, JREG, JMEM };

# Does fetched instruction require a constant word?
bool need_valC =
	icode in { IRMOVL, RMMOVL, MRMOVL, JXX, CALL, IOPL,JMEM };

bool instr_valid = icode in 
	{ NOP, HALT, RRMOVL, IRMOVL, RMMOVL, MRMOVL,
	       OPL, IOPL, JXX, CALL, RET, PUSHL, POPL, JREG, JMEM, LEAVE};

################ Decode Stage    ###################################

## What register should be used as the A source?
int srcA = [
	icode in { RRMOVL, RMMOVL, OPL, PUSHL, JREG} : rA;
	icode in { POPL, RET } : RESP;
	icode in { LEAVE } : REBP;
	1 : RNONE; # Don't need register
];

## What register should be used as the B source?
int srcB = [
	icode in { OPL, IOPL, RMMOVL, MRMOVL, JMEM } : rB;
	icode == IRMOVL && ifun == 1 : rB;
	icode in { PUSHL, POPL, CALL, RET } : RESP;
	icode in { LEAVE } : REBP;
	1 : RNONE;  # Don't need register
];

## What register should be used as the E destination?
int dstE = [
	icode in { RRMOVL, OPL, IOPL } : rB;
	icode == IRMOVL && ifun == 0 : rB;
	icode == IRMOVL && ifun == 1 : rA;
	icode in { PUSHL, POPL, CALL, RET, LEAVE } : RESP;
	1 : RNONE;  # Don't need register
];

## What register should be used as the M destination?
int dstM = [
	icode in { MRMOVL, POPL } : rA;
	icode in { LEAVE } : REBP;
	1 : RNONE;  # Don't need register
];

################ Execute Stage   ###################################

## Select input A to ALU
int aluA = [
	icode in { RRMOVL, OPL } : valA;
	icode in { IRMOVL, RMMOVL, MRMOVL, IOPL, JMEM } : valC;
	icode in { CALL, PUSHL } : -4;
	icode in { RET, POPL, LEAVE } : 4;
	# Other instructions don't need ALU
];

## Select input B to ALU
int aluB = [
	icode == IRMOVL && ifun == 1 : valB;
	icode == IRMOVL && ifun == 0 : 0;
	icode in { RMMOVL, MRMOVL, OPL, IOPL, CALL, PUSHL, RET, POPL, JMEM, LEAVE } : valB;
	icode in { RRMOVL} : 0;
	# Other instructions don't need ALU
];

## Set the ALU function
int alufun = [
	icode in { OPL, IOPL } : ifun;
	1 : ALUADD;
];

## Should the condition codes be updated?
bool set_cc = icode in { OPL, IOPL };

################ Memory Stage    ###################################

## Set read control signal
bool mem_read = icode in { MRMOVL, POPL, RET, JMEM, LEAVE };

## Set write control signal
bool mem_write = icode in { RMMOVL, PUSHL, CALL };

## Select memory address
int mem_addr = [
	icode in { RMMOVL, PUSHL, CALL, MRMOVL, JMEM } : valE;
	icode in { POPL, RET, LEAVE} : valA;
	# Other instructions don't need address
];

## Select memory input data
int mem_data = [
	# Value from register
	icode in { RMMOVL, PUSHL} : valA;
	# Return PC
	icode == CALL : valP;
	# Default: Don't write anything
];

################ Program Counter Update ############################

## What address should instruction be fetched at

int new_pc = [
	# Call.  Use instruction constant
	icode == CALL : valC;
	# Taken branch.  Use instruction constant
	icode == JXX && Bch : valC;
	icode == JREG : valA;
	icode == JMEM : valM;
	# Completion of RET instruction.  Use value from stack
	icode == RET : valM;
	# Default: Use incremented PC
	1 : valP;
];
#/* $end seq-plus-all-hcl */
#/* $end seq-all-hcl */
