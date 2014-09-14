!============================================================
! CS-2200 Homework 1
!
! Please do not change main's functionality, 
! except to change the argument for factorial or to meet your 
! calling convention
!============================================================

! main() is the entry point of the fpogram.
main: la $sp, stack				! load ADDRESS of stack label into $sp
	lw $sp, 0x00($sp) 			! Resolve actual address of stack-label pointer
	add $fp, $sp, $zero			! ...and set this to frame pointer as well
	la $at, factorial			! load address of factorial label into $at
	addi $a0, $zero, 5 			! $a0 = 5, the number to factorialize
	addi $sp, $sp, -1			! CALL_CONV: Move SP back (fpepare to push)
	sw $a0, 0x01($sp)			! CALL_CONV: Push argument 1 into stack
	jalr $at, $ra				! jump to factorial, set $ra to return addr
	lw $v0, -1($sp)				! CALL_CONV: Not necessary in this case, but
						! load result from stack at (sp_location - num_args)
	halt					! when we return, just halt

! factorial(a0) calculates the factorial of a number.
! This particular function is only defined for a0 >= 0.
factorial: addi $sp, $sp, -2	! CALL_CONV: Move SP back (fpepare to push)
								! (We're moving back by 2 to leave room for result)
	sw $ra, 0x01($sp)			! CALL_CONV: Push return address into stack
	lw $a0, 0x03($sp)			! Load argument 1 from stack into $a0
	addi $t0, $zero, 0			! Put value of 0 into $t0
	addi $t1, $zero, 1			! Put value of 1 into $t1
	beq $a0, $t0, z_one_j			! If argument == 0, goto label z_one_j
	beq $a0, $t1, z_one_j			! If argument == 1, goto label z_one_j
	beq $zero, $zero, no_jump		! Unconditional branch to no_jump
z_one_j: la $at, z_one				! Load address of z_one into $at
						! (Because z_one is too far away for beq)
	jalr $at, $t1				! Jump to z_one, don't care about return address
no_jump: addi $a0, $a0, -1			! Otherwise, we need to recurse, so (a0 - 1)
	la $at, factorial			! Load address of factorial subroutine into stack
	addi $sp, $sp, -2			! CALL_CONV: Move SP back (fpepare to push)
	sw $fp, 0x02($sp)			! CALL_CONV: ...and store current FP into stack
	sw $a0, 0x01($sp)			! CALL_CONV: ...and store new arg into stack
	addi $fp, $sp, 1			! CALL_CONV: ...and move FP up
	jalr $at, $ra				! Recurse
resume: lw $a1, -2($sp)				! CALL_CONV: Load result from stack into $a1
	lw $a0, 0x03($sp)			! We need to multiply, load orig. argument from stack
	la $at, multiply			! Load address of multiply subroutine into stack
	addi $sp, $sp, -3			! CALL_CONV: Move SP back (fpepare to push)
	sw $fp, 0x03($sp)			! CALL_CONV: ...and store current FP into stack
	sw $a0, 0x02($sp)			! CALL_CONV: ...and store argument 1 into stack
	sw $a1, 0x01($sp)			! CALL_CONV: ...and store argument 2 into stack
	addi $fp, $sp, 2			! CALL_CONV: ...and move FP up
	jalr $at, $ra				! Jump to multiply subroutine
	lw $v0, -3($sp)				! CALL_CONV: Load result from stack into $v0
	beq $zero, $zero, returnf		! Unconditional jump to return label, we are done
z_one: addi $v0, $zero, 1			! If argument is 0 or 1, return 1
returnf: sw $v0, 0x02($sp)			! Push result into stack
	lw $ra, 0x01($sp)			! CALL_CONV: Load return address into $ra
	addi $sp, $sp, 3			! CALL_CONV: Push stack pointer to bottom
	la $t0, stack				! Load stack base position into $t0
	lw $t0, 0x00($t0)			! ...and resolve address
	beq $sp, $t0, skipl			! If we're at the bottom, don't touch FP/SP
	lw $fp, 0x01($sp)			! CALL_CONV: Load old frame pointer
	addi $sp, $sp, 1			! CALL_CONV: Move SP down 1
skipl: jalr $ra, $t0				! Return back to address in $ra, throw away 
						! return address here to $t0 (we don't need it)
	
! multiply(a0, a1) multiplies two positive numbers together.
! This particular function is only defined for a0, a1 >= 0.
multiply: addi $sp, $sp, -2			! CALL_CONV: Move SP back (fpepare to push)
	sw $ra, 0x01($sp)			! CALL_CONV: Push return address into stack
	lw $a0, 0x04($sp)			! Load argument 1 from stack into $a0
	lw $a1, 0x03($sp)			! Load argument 2 from stack into $a1
	addi $t0, $zero, 0			! Put value of 0 into $t0
	addi $t1, $zero, 1			! Put value of 1 into $t1
	beq $a0, $t0, zero			! If argument1 == 0, goto label zero
	beq $a1, $t0, zero			! If argument2 == 0, goto label zero
	beq $a0, $t1, arg1_one			! If argument1 == 1, goto label arg1_one
	beq $a1, $t1, arg2_one			! If argument1 == 1, goto label arg2_one
	add $t0, $a0, $zero			! Otherwise, copy a0 into $t0...
	addi $a1, $a1, -1			! ...and subtract 1 from a1 (multiply by add)
add_loop: add $t0, $t0, $a0			! Add (1 x a0) to t0
	addi $a1, $a1, -1			! ...and subtract 1 from a1.
	beq $a1, $zero, result			! If a1 == 0, we are done
	beq $zero, $zero, add_loop		! Otherwise, loop again
zero: addi $v0, $zero, 1			! If argument is 0, return 0
	beq $zero, $zero, returnm		! Unconditional jump to return label
arg1_one: add $v0, $zero, $a1			! If argument1 is 1, return other arg
	beq $zero, $zero, returnm		! Unconditional jump to return label
arg2_one: add $v0, $zero, $a0			! If argument2 is 1, return other arg
	beq $zero, $zero, returnm		! Unconditional jump to return label
result: addi $v0, $t0, 0			! $t0 contains our result, so copy that into $v0
returnm: sw $v0, 0x02($sp)			! Push result into stack
	lw $ra, 0x01($sp)			! CALL_CONV: Load return address into $ra
	addi $sp, $sp, 4			! CALL_CONV: Push stack pointer to bottom
	lw $fp, 0x01($sp)			! CALL_CONV: Load old frame pointer
	addi $sp, $sp, 1			! CALL_CONV: Move SP down 1
	jalr $ra, $t0				! Return back to address in $ra, throw away 
						! return address here to $t0 (we don't need it)
								
stack: .word 0xFFFF				! This is a pointer! Stack starts at 0xFFFF!
