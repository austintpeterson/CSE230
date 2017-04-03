# CSE/EEE230 Spring 2017
# Name: Austin Peterson
# PIN: 498
# Assignment: 3
	
.data
	numbers: .space 80 #declare 80 bytes of storage to hold array of 20 integers
	prompt: .asciiz "How many values to read? " #start at 81
	space: .asciiz " " #starts at 106
	
.text
.globl main

main:
#read data into array
	lui $a0, 0x1001 #Array address loaded for parameter
	jal readData #jump and return to the Read Data function
	ori $s0, $v0, 0 #save number of integers read into $s0

#print array
	lui $a0, 0x1001 #Array address loaded for parameter
	jal print #call print function

#sort array
	lui $a0, 0x1001 #Array address loaded for parameter
	jal sort #call sort function

#print array
	lui $a0, 0x1001 #Array address loaded for parameter
	jal print #call print function

#exit
	ori $v0, $0, 10 #set command to end program
	syscall #end program

#function swap is called by sort
swap:
	lw $t0, 0($a0) #get first value
	lw $t1, 0($a1) #get second value
	sw $t0,0 ($a1) #set second value to first value
	sw $t1, 0($a0) #set first value to second value
	jr $ra

#works
readData:
	#save s registers on stack
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	
	#save the a0 coming into function (address of array),
	#so that I can use a0 to print the prompt
	ori $s0, $a0, 0
	
	#print prompt (use addi to save ui)
	addi $a0, $a0, 80#address of prompt
	ori $v0, $0, 4	#set v0 for printing the prompt
	syscall
	
	#get integer from user
	ori $v0, $0, 5
	syscall
	#save user int into s1 so that we can use v0 for other stuff
	ori $s1, $v0, 0
	
	#set second arb. register to 0 to use for counter in loop
	#to compare to s1, our user int
	ori $s2, $0, 0  
	
	addi $a0, $s0, 0 #change a0 back to address of array (saved earlier)
	#runs through to next function
	
	#newcode:
	#save int count from user to t0 so can clean s1
	ori $t0, $s1, 0
	
#========LOOPSTART========
begin:
	ori $v0, $0, 5
	syscall
	#right here, v0 is the integer the user gives us
	#store word of the int given by user
	sw $v0, 0($a0)#a0 will be incremented at bottom 
	
	#save s2 and s1 on stack, restore at end
	
	#increment counter by one at end of loop
	addi $s2, $s2, 1
	#increment a0 at end of loop by 4 bytes to change 
	#address to the next int in the array
	addi $a0, $a0, 4
	#bottom testing loop, jump back to top if counters not =
	bne $s1, $s2, begin
	
	#restore s0,1,2 from stack
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	addi $sp, $sp, 12
	
	#use temp value to get the last address of the last item in array (for sort)
	#not used at this time, might be handy for sort (descending)
	addi $t9, $a0, 0
	
	#after this function ends naturally, loop cond. not met.
	jr $ra
	
	
	
	
#works
print:
	#initialize count (max value of array for comparator to incrementer)
	#use t0 from when we saved it at end of the last funtion
	ori $a1, $t0, 0
	
	#initialize counter using temp register
	ori $t1, $0, 0
	
#========LOOPSTART========
begin2:
	#save the a0 (address of array in t2)
	ori $t2, $a0, 0
	#load word at current a0 to t3
	lw $t3, 0($a0)
	#load t3 into a0 and print int in array
	ori $a0, $t3, 0
	
	#print int in array
	ori $v0, $0, 1
	syscall#print the int ($t3)
	
	#restore a0 using t2
	ori $a0, $t2, 0
	
	#save a0 (address of int in array) to s0 (needed?)
	#needed to save the current ints address each loop cycle
	ori $s0, $a0, 0
	
	#load upper initial to fix issue
	#previous use of a0 means the upper init isnt 1001 anymore
	lui $a0, 0x1001
	#set a0 to the address of the " "
	ori $a0, $a0, 106
	#set v0 to print string
	ori $v0, $0, 4
	syscall
	
	#restore a0 to the address of array for top of loop and incrementing
	ori $a0, $s0, 0
	
	#increment counter at end 
	addi $t1, $t1, 1
	
	#increment a0 at end of loop by 4 bytes to change 
	#address to the next int in the array
	addi $a0, $a0, 4
	
	bne $t1, $a1, begin2
	
	#restore the t1,2,3 registers we used for this function
	#back to 0, NOT killing t0 because it holds the master count
	#of values in array (user input)
	ori $t1, $0, 0
	ori $t2, $0, 0
	ori $t3, $0, 0
	
	jr $ra

	#HALF WORKING: sometimes I can get it to swap the first couple but it exits
	#all the code I wrote is solid and logical but I can't get it to work at this time
	#a1 is still the count of ints given
	#a0 is the starting address of the array
sort:
	#check if array is empty, exit if so 
	#beq $a0, 0, outer_end
	#init outer loop limit using (count -1)
	addi $s3, $a1, -1
	#t5 is a swap counter (prob wont use)
	addi $t5, $0, 0
outer:
	#if 0 is greater or equal to s3
	blez $s3, outerend
	#set inner loop counter
	addi $s0, $0, 0
	#set current element offset (as an address)
	lui $s1, 0x1001

	#start of inner loop
inner:
	#s0 - s3 will return greater than or equal to 0
	sub $t4, $s0, $s3
	#branch if s0 is greater or equal to s3
	bgez $t4, innerend

	#load words from place i in array and place i+1
	#load a0 as the address to the first word
	addi $a0, $s1, 0
	#load a1 as the second address to the second word
	addi $a1, $s1, 4

	#load words from address a0 and a1 for my own testing
	lw $t7, 0($a0)#first int value
	lw $t8, 0($a1)#second int value
	
	#reset t4 for comparison
	ori $t4, $0, 0
	#t7-t8 will give less than or equal to zero
	sub $t4, $t7, $t8
	# no swap if first int less than second
	#branch if t7 is less than or equal to t8
	blez $t4 noswap
	
	addi $t5, $0, 1
	j swap

noswap:
	#increment address
	addi $s1, $s1, 4
	#increment inner loop
	addi $s0, $s0, 1
	#restart inner loop
	j inner

	#end of inner loop
innerend:

	#decrement outer loop
	addi $s3, $s3, -1

	#restart the outer loop
	j outer

outerend:
	jr $ra


