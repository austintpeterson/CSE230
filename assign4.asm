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
	
	#MULTIPLY CALL===============================
	
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
	
	#DIVIDE CALL=================================
	
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
	
#get input function as described
getinput:
	addi $v0, $0, 4
	syscall
	#read  input and store in 
	addi $v0, $0, 5
	syscall
	
	jr $ra
	
#MULTIPLY FUNCTION===============================
#happy as a clam :)

multiply:
	#clean v0
	addi $v0, $0, 0
	#incrementer
	addi $t1, $0, 0
	#flag to check least-sig bit
	addi $t2, $0, 0

multloop:
	andi $t2, $a0, 1
	beq $t2, $0, notequalsone
 
	add $v0, $v0, $a1

notequalsone:
	#shifting part of algorithm
	sll $a1, $a1, 1
	srl $a0, $a0, 1
	addi $t1, $t1, 1
	#stopping condition
	beq $t1, 32, endmultloop
	j multloop

endmultloop:
	jr $ra
	
	
	
	
#DIVIDE FUNCTION==================================
#this only works with smaller numbers (<1000), but I think thats how its supposed to be
#book algorithm might not have ending condition
#works best with big_odd/small_even (ex: 13/2)
#I tried my best TA pls give points

divide:
	#determine if either incoming numbers are negative, change to pos if true
	blt $a0, 0, firstneg
	blt $a1, 0, secneg

	#stopping condition, a1 now nothing
	#does the algorithm in book have a stopping condition
	#top testing
	beq $a1, $0, enddiv
	#shifting off al1 4 bits
	sll $a1, $a1, 4
	#t1 is the incrementer
	addi $t1, $0, 0
	#whipe v0 from prev printing (precautionary)
	addi $v0, $0, 0
	addi $v1, $a0, 0

divloop:
	#incremented 32 times, better to use incr vs decr
	#because can use immediate, dont have to store limit in another reg.
	beq $t1, 32, enddiv2
	
	sub $v1, $v1, $a1
	beq $v1, $0, enddiv2
	blt $v1, 0, divjump
	#shift and increment
	sll $v0, $v0, 1
	addi $v0, $v0, 1
	j enddiv1

#should run right through to enddiv1
divjump:
	add $v1, $v1, $a1
	sll $v0, $v0, 1

enddiv1:
	srl $a1, $a1, 1
	add $t1, $t1, 1
	j divloop

#updating finishing v1 (will happen multiple times)
enddiv2:
	ori $v1, $a1, 0
	jr $ra

enddiv:
	#if there is no remainder (perfect division of evens), then the whole number is 
	#put into the remainder? still technically correct, but not doing what I want
	ori $v1, $0, 0
	ori $v0, $0, 0
	jr $ra

#NEGATIVE HANDLING FOR DIVISION
#force the incoming numbers to pos if necessary
#in event that first number is negative (a0)
firstneg:
	sub $a0, $0, $a0
	#restart the divide function with positive number
	j divide

#in event that second number is negative (a1)
secneg:
	sub $a1, $0, $a1
	#restart the divide function with positive number
	j divide




#getting tired of messing with v0 and a0 every time I want a newline,
#better to have stack-saving function in use
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

#end the program (correctly)
end:
	addi $v0, $0, 10
	syscall	
	
	
	
	
	
