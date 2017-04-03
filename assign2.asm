# CSE/EEE230 Spring 2017
# Name: Austin Peterson
# PIN: 498
# Assignment: 2

.data 
	name: .asciiz "Austin Peterson\n" 			#located - 0 (needs newline)
	prompt1: .asciiz "Enter the number of times to repeat "	#located - 17	
	prompt2: .asciiz "Enter the first number " 		#located - 54
	prompt3: .asciiz "Enter the second number "		#located - starts 78
	prompt4: .asciiz "The sum is "				#located - starts 104 103?
	error: .asciiz "First number is greater than second\n"	#located - starts 116 (needs newline)
	newline: .asciiz "\n"					#located - starts 152
	endmess: .asciiz "program complete\n"			#located - starts 154 (needs newline)
	#all standalone messages need newline

#needed
.globl main
.text

main:
	#set base register to start of our segment (0x10010000)
	lui $t0, 0x1001
	
	#set flag to false
	addi $a2, $0, 0
	ori $t0, $0, 0
	
	#no need to change address b/c 0x10010000 is location of name
	jal print
	
	#first prompt "Enter number of times to repeat "
	ori $t0, $t0, 17
	jal print
	
	#take first input from user
	ori $v0, $0, 5
	syscall
	
	#save first input to t1
	addi $t1, $v0, 0 
	
loop:
	#compare if decrementer has finished
	#if so, end
	beq $t1, $0, end3
	
	#print second prompt "Enter the first number "
	ori $t0, $0, 54
	jal print
	
	#get input from user
	ori $v0, $0, 5
	syscall
	
	#save input from return into t2
	addi $t2, $v0, 0
	
	#print third prompt "Enter the second number "
	ori $t0, $0, 78
	jal print
	
	#get input from user
	ori $v0, $0, 5
	syscall
	
	#save input from return into t3
	addi $t3, $v0, 0
	
	#check if larger than other,
	#store in t4
	slt $t4, $t3, $t2
	
	#if second int larger, go to else (error message)
	beq $t4, 1, errorm
	
	#pass second int to t5 for later
	#dont want to overwrite
	addi $t5, $t3, 0
	
sumloop: 
	#kill loop, it is over
	#jump to end
	beq $t5, $t2, end
	
	#create sum of two numbers
	add $t3, $t3, $t2
	
	#increment
	addi $t2, $t2, 1
	
	j sumloop

#first end to be used to show sum
end:
	#print sum prompt "The sum is " 
	addi $t0, $0, 103
	addi $a2, $0, 1 #print text
	ori $a1, $t3, 0
	jal print
	j end2
	
#show error message, jump to decrement
errorm:
	#error message in register 
	addi $t0, $0, 115
	jal print
	j end2
	
#used solely to decrement and then back to loop
end2:
	#decrement loop
	sub $t1, $t1, 1
	j loop

#this is the real end, print finish message and kill prog
end3:
	#print finish program line
	addi $t0, $0, 154
	jal print
	#end
	ori $v0, $0, 10
	syscall
	
#note: using ori seems more reliable than andi 
#for the purpose of filling registers for printing

print:
	lui $a0, 0x1001
	#set the boolean flag register to 0
	#andi $a2, $0, 0 no longer needed
	#t0 outside variable, a0 init when print is run
	#(t0 will be modified outside potentially)
	or $a0, $a0, $t0
	#set command to print int
	ori $v0, $0, 4
	syscall
	
	#if a2 is = 0, finish
	beq $a2, $0, ret
	
	#put int in to print
	ori $a0, $a1, 0
	
	#put print int into print
	ori $v0, $0, 1
	syscall
	
	#print newline
	#reload a0 b/c modified for printing earlier
	lui $a0, 0x1001
	ori $v0, $0, 4
	
	#load a0 with address of newline
	ori $a0, $a0, 152
	syscall
	
	addi $a2, $0, 0
	
	#return
	j ret
	
#function to return
#note: pointing at next instruction
ret:	
	jr $ra
	

