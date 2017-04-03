# CSE/EEE230 Spring 2017
# Name: Austin Peterson
# PIN: 498
# Assignment: 5

.data
	#these addresses should all be correct currently
	array: .space 40 #space for the array, 40 bits (1001000)
	name: .asciiz "Austin Peterson \n"	#start 10010040 
	prompt1: .asciiz "Enter a number "	#start 10010058
	newline: .asciiz "\n"			#start 10010074
	
.globl main
.text

#main function
#calls all functions
main:
	#reference for prompt
	#might not need
	lui $t5 0x1001
	
	#print my name
	#same as always
	lui $a0, 0x1001
	addi $a0, $a0, 40
	addi $v0, $0, 4
	syscall
	
	#set for array
	lui $a0, 0x1001
	#reset
	addi $a0, $a0, 0
	
	#read in all 10
	jal readvals
	
	lui $a0, 0x1001
	#store the values that return from readvals into a1
	add $a1, $0, $v0
	
	#print all 10 and avg
	jal print
	
	#this is the end
	addi $v0, $0, 10
	syscall
	
#The incoming input is stored in a0
#this function stores all the values given by user in an array
#and then returns the number of new elements in v0
readvals:
	addi $t0, $0, 0	#incrementer (to 10 max)
	addi $t1, $0, 10#limit of 10
	
	#save a0 as its coming in for use later (were using a0 to print prompt)
	#not using stack, thats reserved for array
	addi $t2, $a0, 0

entryloop:
	#body here
	#read entry
	#determine if incr at 10, if so, jump to arrayfull
	#if not, take new entry, increment t0 and jump to entry loops
	
	#address of prompt
	lui $a0, 0x1001
	addi $a0, $a0, 58
	addi $v0, $0, 4	#set to print
	syscall	#print prompt
	
	addi $a0, $0, 0
	#clean a0
	lui $a0 0x1001
	
	addi $v0, $0, 6#take input (float)
	syscall
	
	#start building 0.0
	addi $t6, $0, 0
	mtc1 $t6, $f7
	#0.0 float
	cvt.s.w $f7, $f7
	
	#save user input to f4
	add.s $f4, $f0, $f7
	
	cvt.w.s $f5, $f4
	#convert number to integer (move to coprocessor)
	mfc1 $t7, $f5
	
	#if input < 0, less than entry is over
	addi $t3, $0, 0
	bltz $t7, arrayfull
	
	swc1 $f4, 0($t2)#store number in array (no offset of incremeneter)
	#must happen after
	addi $t2, $t2, 4 #increment array counter (4 bits)
	addi $t0, $t0, 1 #increment loop counter
	
	#check if ten entries read (maxxed incrementer)
	beq $t0, $t1, arrayfull
	j entryloop

arrayfull:
	#return # of new elements in array
	addi $v0, $t0, 0
	
	jr $ra
	
#should print all elements in loop
#after loop, prints average of all floats
#starting address passed in in a0, number of elements passed in in a1
#average function called and printed at end to determine average
print:
	#room for one on stack
	addi $sp, $sp, -4
	#store return on stack
	sw $ra, 0($sp)
	#starting addr of array into t0 (for pointer)
	add $t0, $0, $a0
	#number of entries (counter)
	add $t1, $0, $a1
	#prepare to print float
	addi $v0, $0, 2

printloop:
	#load word from array, float
	lwc1 $f6, 0($t0)
	
	#use t6 for 
	addi $t6, $0, 0
	#user input
	mtc1 $t6, $f7
	#word to precision
	cvt.s.w $f7, $f7#, $f7
	
	#add number to print to reg
	add.s $f12, $f6, $f7
	#print the float
	syscall
	
	#save a0 for counter
	addi $t9, $a0, 0
	
	#print newline
	lui $a0 0x1001
	addi $a0, $a0, 74
	addi $v0, $0, 4
	syscall
	
	#prepare to print float (no longer a string)
	#fix a0
	addi $a0, $t9, 0
	addi $t9, $0, 0
	addi $v0, $0, 2
	
	#decrement counter
	addi $t1, $t1, -1 
	#increment array ptr by 4 bits
	addi $t0, $t0, 4
	
	#if counter runs out, end
	beq $t1, $0, endprint
	
	j printloop
	
endprint:
	jal floataverage
	
	#store return value to printing reg for floats
	add.s $f12, $f7, $f0
	#print final val
	addi $v0, $0, 2
	syscall
	
	#return and clear stack
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
#find average of elements stored in array
#current element comes in as a1, beginning of array passed in as a0
#average of elements is returned in f0git config --get user.name

#add to running total, then after loop divide by counter

floataverage:
	addi $t0, $a1, 0#decrementer (because its current element amt)
	addi $t1, $a0, 0#beginning of array address
	
	addi $t2, $0, 0# new incr
	
	mtc1 $t2, $f1 #t2 new running total at 0 (beginning)
	cvt.s.w $f1 $f1#conv word to float
	
#f3 is current word
#f1 is running total 

#add all 10 elements to running total
stillelementsloop:
	
	beq $t0, $0 noelements#top testing to see if any elements left
	
	lwc1 $f3, 0($t1)#load the word in at current addr
	
	add.s $f1, $f1, $f3 #add the new element to running total
	
	addi $t1, $t1, 4 #increment array address (4 bits)
	addi $t0, $t0, -1 #decr counter by one element
	
	#should restart process pointing at next (lesser) element
	j stillelementsloop
	
#finish up
#return in f0
noelements:
	mtc1 $a1, $f5
	#store counter as float for arithmetic
	cvt.s.w $f5, $f5 
	#get the average using the total/element counter
	div.s $f0, $f1, $f5
	
	jr $ra

	
	
	
	
	
	
