# CSE/EEE230 Spring 2017
# Name: Austin Peterson
# PIN: 498
# Assignment: 1

#notes for self:
.data	#data segment contains global data
.word 1 #located at 0x10010000 w value 0x00000001
.word 2 #located at 0x10010004 w value 0x00000002
.word 3 #located at 0x10010008 w value 0x00000003
.asciiz "Austin Peterson\n" #located at 0x1001000C

.globl main
.text
main:

#1) set base register to start of our segment (0x10010000)
lui $t0, 0x1001

#2) print name on own line using syscall command (determine displacement)
lui $a0, 0x1001
ori $a0, $a0, 12
ori $v0, $0, 4
syscall

#3) Init. following registers:

#a. put value 10 into register $s0
addi $s0, $0, 10

#b. put value 5 into register $s1
addi $s1, $0, 5

#c. put value -3 into register $s2
addi $s2, $0, -3

#4) store values into memory (sw command writes to memory):
# registerread, offset from base(base)

#a. store val in $s1 into memory at 0x10010000 
sw $s1, 0($t0)

#b. store val in $s2 into memory at 0x10010004
sw $s2, 4($t0)

#5) calc and store into memory (store at 0008 don't change vals in registers!)

#a. Calc value of $s0 - ($s1 + $s2 - 4)
#note: reusing and replacing $t1 for full thing
add $t1, $s1, $s2
sub $t1, $t1, 4
sub $t1, $s1, $t1

#b. store result in memory 0x10010008 note: this will be overwriting the #data designed at the beginning of the assembly correct?

sw $t0, 8($t0)

#6) update registers to following values (don't change vals in memory!)

#a. change val in $s1 to 4
addi $s1, $0, 4

#b. change val in $s2 to 7
addi $s2, $0, 7

#7) swap vals in addresses 0x10010000 and 0x10010004
#holding the values in temp variables
lw $t1, 0($t0)
lw $t2, 4($t0)
#reinserting values into new addresses (swapped)
sw $t1, 4($t0)
sw $t2, 0($t0)

#8) set val in $s0 to -$s0
sub $s0, $0, $s0

#9) calc val of $s0 + $s1 - $s2 and print result (dont change vals in reg!)
add $t1, $s0, $s1
sub $t2, $t1, $s2

#1 to print
addi $v0, $0, 1
add $a0, $t2, $0

syscall

#10) stop program by using syscall w command 102222
addi $v0, $0, 10 #puts val 10 into command register
syscall #syscall to execute/end program




