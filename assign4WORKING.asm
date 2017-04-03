# CSE/EEE230 Spring 2017
# Name: Austin Peterson
# PIN: 498
# Assignment: 4

.data 
	name: .asciiz "Austin Peterson \n"	#start 10010000 
	prompt1: .asciiz "How many times would you like to repeat? "
	prompt2: .asciiz "Enter the first number (bigger abs value of the two): "
	prompt3: .asciiz "Enter the second number: "
	newline: .asciiz "\n"

.globl main
.text
		
main:
	#print my name
	lui $a0, 0x1001
	addi $v0, $0, 4
	syscall
	
	#set to prompt 1 and print
	addi $a0, $a0, 18
	jal getinput
	#save the input from getinput from v0 to s0 (times to repeat)
	addi $s0, $v0, 0
	
	#set decrementer for loop (using s0)
	addi $t0, $s0, 0
loop:
	#use s1 and s2 for the two integer inputs
	
	#print the second prompt and use getinput
	lui $a0, 0x1001
	addi $a0, $a0, 60	#second prompt address (first int)
	jal getinput
	#save input from getinput from v0 to s1
	addi $s1, $v0, 0
	
	#print the third prompt and use getinput
	lui $a0, 0x1001
	addi $a0, $a0, 115	#third prompt address (second int) HERHEREREHRH
	jal getinput
	#save input from getinput from v0 to s2
	addi $s2, $v0, 0
	
	#MULTIPLY===============================
	
	#set params for multiply using the s1 and s2 integers taken from user
	addi $a0, $s1, 0
	addi $a1, $s2, 0
	#call multiply
	jal multiply
	
	#save v0 return into a0 for printing (*)
	addi $a0, $v0, 0
	addi $v0, $0, 1
	syscall
	
	#call newline after the multiplication product is printed
	jal newlinefunc
	
	#DIVIDE=================================
	
	#set params for multiply using the s1 and s2 integers taken from user
	addi $a0, $s1, 0
	addi $a1, $s2, 0
	#call divide
	jal divide
	
	#save v0 return into a0 for printing (/)
	addi $a0, $v0, 0
	addi $v0, $0, 1
	syscall
	
	#call newline after the quotient is printed
	jal newlinefunc
	
	#save v1 return into a0 for printing (%)
	addi $a0, $v1, 0
	syscall
	
	#call newline after the remainder is printed
	jal newlinefunc

	#decrement t0 and reloop (bottom testing)
	addi $t0, $t0, -1
	bne $t0, $0, loop
	#loop is over, end
	j end
	
getinput:
	addi $v0, $0, 4
	syscall
	#read  input and store in 
	addi $v0, $0, 5
	syscall
	
	jr $ra
	
	
	
	
	
	
#MULTIPLY FUNCTION===============================

multiply:
	addi $v0, $0, 0
	addi $t1, $0, 32
	addi $t2, $0, 0

multloop:
	andi $t2, $a0, 1
	beq $t2, $0, notequalsone
 
	add $v0, $v0, $a1

notequalsone:
	sll $a1, $a1, 1
	srl $a0, $a0, 1
	addi $t1, $t1, -1
	beq $t1, $0, endmultloop
	j multloop

endmultloop:
	jr $ra
	

#DIVIDE FUNCTION==================================
#this only works with smaller numbers (<1000), but I think thats how its supposed to be

divide:
	#determine if either incoming
	blt $a0, 0, firstneg
	blt $a1, 0, secneg

	beq $a1, $0, end4
	sll $a1, $a1, 4
	#t6 is the incrementer
	addi $t6, $0, 0
	addi $v1, $a0, 0
	#whipe v0 from prev printing (precautionary)
	addi $v0, $0, 0

loop3:
	beq $t6, 32, end2
	
	sub $v1, $v1, $a1
	beq $v1, $0, end2
	blt $v1, 0, jump4
	sll $v0, $v0, 1
	addi $v0, $v0, 1
	j end3

jump4:
	add $v1, $v1, $a1
	sll $v0, $v0, 1

end3:
	srl $a1, $a1, 1
	add $t6, $t6, 1
	j loop3

#force the incoming numbers to pos if necessary
#in event that first number is negative (a0)
firstneg:
	sub $a0, $0, $a0
	#basically restart the divide function with positive number
	j divide

#in event that second number is negative (a1)
secneg:
	sub $a1, $0, $a1
	#basically restart the divide function with positive number
	j divide

end2:
	ori $v1, $a1, 0
	jr $ra

end4:
	ori $v1, $0, 0
	ori $v0, $0, 0
	jr $ra

newlinefunc:
	#save v0 and a0 for use after newline
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	
	lui $a0, 0x1001
	#load a0 with address to newline
	addi $a0, $a0, 141
	#print string
	addi $v0, $0, 4	#second one used to be v0
	syscall
	
	#restore v0 and a0 from stack back into registers
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	
	jr $ra

#end the program
end:
	addi $v0, $0, 10
	syscall	
	
	
	
	
	
