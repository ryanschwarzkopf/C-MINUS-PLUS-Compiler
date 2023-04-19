.data
L1: .asciiz "Please enter value: "
L2: .asciiz "The number read was "
L3:  .asciiz "The sum of squares is "
NL:  .asciiz "\n"
buffer: .space 8 # we need this to read in values an then we can store them
.text # defines where the code starts

main:   # we need 4 words to store the value, s, i, and then RA and SP
	# sp:0, ra:4, i:8, s:12, value:16

        subu $a0, $sp, 16  # subtr
        sw $sp, ($a0)  # store SP in activation record
        sw $ra, 4($a0) # store RA in activation record 
        move $sp, $a0  # adjust the stack pointer

	#Prints the prompt2 string
	li $v0, 4 # operation print string
	la $a0, L1 # load string 1 from data
	syscall # run operation

	#reads one integer from user and saves in t0
	li $v0, 5 # operation read expression
	addu $t0, $sp, 16   #$t0 is the memory location for our variable
	syscall # run operation
	sw $v0 16($sp) # save from register 0 to address
	
	# sprint it back out  string
	li $v0, 4 # priunt string operation
	la $a0, L2 # load string to print
	syscall # run operation

	# print out the number
        li $v0, 1 # load operation into first register, (print expression)
        addu $t0, $sp, 16   #Address of x (16+sp) into register 0
        lw $a0,16($sp)     # value of x
        syscall     # run operation
        li $v0, 4   #  these 3 lines do a new line, operation print string
        la $a0, NL # load newline from data into register
        syscall 	# run operation
	
        sw $0, 8($sp)  # store 0 into memory -- counting variable 
        sw $0, 12($sp)  # store 0 into memory -- accumulating variable
	lw $t5, 16($sp) # place value of x back into register for branch operation

loop:
        lw $t6, 8($sp)  #   
        mul $t7, $t6, $t6  #  i * i
        lw $t8, 12($sp)   #  s
        addu $t9, $t8, $t7  #  s + i*i
        sw $t9, 12($sp)  #   s= s + i*i 
        lw $t6, 8($sp)   # i 
        addu $t0, $t6, 1  # i+1
        sw $t0, 8($sp)  #  i = i + 1
        ble $t0, $t5, loop  #   keep doing it for (x) times
#end loop branch

	# sprint it back out  string
	li $v0, 4 # load operation 4 (print string)
	la $a0, L3 # load string from data
	syscall # run operation

        # print out the number
	li $v0, 1 # operation value
	addu $t0, $sp, 12   #Address of x
	lw $a0, 12($sp)     # value of x  
	syscall      # run operation
	li $v0, 4   #  these 3 lines do a new line, operation 4
	la $a0, NL  # data newline
	syscall   # runoperation

exitProgram:   
        #put back RA and SP
        lw $ra 4($sp)
        lw $sp ($sp)
        li $v0, 10  # system call to
    	syscall         # terminate program


