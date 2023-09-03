.data
# A is the augmented matrix(5 * 6) having the IEEE 754 32 bit floating point corresponding representation of numbers
A : .float 1,3,10,-4,-1,-5,-6,-8,-6,2,-8,24,7,-4,-8,-10,-5,-5,5,-7,2,8,-4,-57,-7,2,10,-7,-2,69

INFINITE_SOLUTION : .asciiz "INFINITE SOLUTION EXISTS!\n" 
NO_SOLUTION : .asciiz "NO SOLUTION EXISTS!\n"  
one_representation : .float 1 # 1 in floating point representation
zero_representation : .float 0
constants : .word 0 0 0 5 6 # i , j , k , row_number , col_number
x : .word 0 0 0 0 0 # final solution x
temp : .word        # for storing temporary float values during calculation

.text

##############################################################################
# Start of the row swapping stage 


1_FOR_BOUND_CHECK:
la a0,constants # loading the base address of the constants
lw a1,12(a0) # a1 = row_number
lw a2,0(a0) # a2 = i
addi a1,a1,-1 # a1 = row_number - 1
bge a2,a1,1_FOR_EXIT # if (i >= row_number - 1 ) branch to 1_FOR_EXIT label
j 1_FOR_1_FOR_ENTRY # It means jump to first "for" child loop (Entry code) of the first parent "for" loop 

1_FOR_1_FOR_ENTRY: # This branch is basically for initialization of k = i + 1 in memory
la a0,constants 
lw a1,0(a0) # a1 = i
addi a1,a1,1 # a1 = i + 1
sw a1,8(a0) # k = i+1, This is done because the loop starts with (k = i+1;k<m;k++) and 8(a0) refers to location where k is stored
j 1_FOR_1_FOR_BOUND_CHECK 

1_FOR_1_FOR_BOUND_CHECK : #This branch basically checks the 'k < m' condition in (k = i+1;k<m;k++)
la a0,constants
lw a1,8(a0) # ai = k
lw a2,12(a0) # a2 = row_number(m)
bge a1,a2,1_FOR_1_FOR_EXIT # if ( k >= m ) jump to 1_FOR_1_EXIT
j 1_FOR_1_FOR_IF

1_FOR_1_FOR_IF:
la a0,constants
la t3,A # t3 = contains the base address of A
lw a1,0(a0) # a1 = i
addi a2, zero,24 # a2 = 24
mul a3,a1,a2 # a3 = 24 * i 
slli a1,a1,2 # computing effective address for i by 4 * i
add a3,a3,a1 # a3 = 24 * i + 4 * i This is basically for finding the index of A[i][i], 24 because 5 * 4 , 1 word= 4 bytes
add a3,a3,t3 # computing effective address ==> base + offset
flw ft0,0(a3) # ft0 = A[i][i]
fabs.s ft0,ft0 # ft0 = abs(ft0)
lw a3,8(a0) # a3 = k
mul a3,a3,a2 # a3 = 24*k
add a3,a3,a1 # a3 = 24 * k + 4 * i ==> [k][i]
add a3,a3,t3 # computing effective address ==> base + offset
flw ft1,0(a3) # ft1 = A[k][i]
fabs.s ft1,ft1 # ft1 = abs(ft1)
flt.s a3,ft0,ft1 # a3 = bool ( ft0 < ft1)
xori a3,a3,1 # a3 = a3 XOR 1, If a3 is true then result is false, else if a3 is false, then result will be true
bnez a3,1_FOR_1_FOR_IFEXIT # jumps to 1_FOR_1_FOR_IFEXIT if ft0 > ft1, inuitively if the pivot in the upper row is bigger, then dont go for row swapping
j 1_FOR_1_FOR_IF_FOR_ENTRY

1_FOR_1_FOR_IF_FOR_ENTRY: # This branch will basically be responsible for doing the rows swapping 
la a0,constants 
mv a1,zero
sw a1,4(a0) # initializing j = 0
j 1_FOR_1_FOR_IF_FOR_BOUND_CHECK

1_FOR_1_FOR_IF_FOR_BOUND_CHECK:
la a0, constants
lw a1,4(a0) # a1 = j
lw a2,16(a0) # a2 = col_number(n)
bge a1,a2,1_FOR_1_FOR_IF_FOR_EXIT # doing the check if ( j >= n) come out of the loop
j 1_FOR_1_FOR_IF_FOR_BODY

1_FOR_1_FOR_IF_FOR_BODY:
la t3,A # t3 = base addr of A
la a0,constants
lw a1 , 0(a0) # a1 = i
lw a2 , 4(a0) # a2 = j
lw a3 , 8(a0) # a3 = k
addi a4 , zero , 24 # a4 = 24
mul t4 , a4 , a1 # t4 = 24 * i
slli a2,a2,2 # computing effective address for j by 4 * j
add t4 , t4 , a2 # t4 = 24 * i + 4 * j ==> [i][j]
add t4, t4, t3 # computing effective address ==> base + offset
flw ft0 , 0(t4) # ft0 = A[i][j]
mul t5 , a4 , a3 # t5 = 24 * k 
add t5 , t5 , a2 # t5 = 24 * k + 4 * j ==> [k][j]
add t5,t5,t3 # computing effective address ==> base + offset
flw ft1 , 0(t5) # ft1 = A[k][j]
fsw ft1, 0(t4) # A[i][j] = ft1 = A[k][j]
fsw ft0, 0(t5) # A[k][j] = ft0 
j 1_FOR_1_FOR_IF_FOR_INCREMENT


1_FOR_1_FOR_IF_FOR_INCREMENT:
la a0 , constants
lw a1 , 4(a0) # a1 = j
addi a1 , a1, 1 # j = j+1
sw a1 , 4(a0)
j 1_FOR_1_FOR_IF_FOR_BOUND_CHECK


1_FOR_1_FOR_IF_FOR_EXIT:
j 1_FOR_1_FOR_IFEXIT

1_FOR_1_FOR_IFEXIT:
j 1_FOR_1_FOR_INCREMENT

1_FOR_1_FOR_INCREMENT:
la a0,constants
lw a1,8(a0) # a1 = k
addi a1,a1,1 # k=k+1
sw a1 , 8(a0)
j 1_FOR_1_FOR_BOUND_CHECK

# 1_FOR_1_FOR_EXIT:
# j 1_FOR_INCREMENT

1_FOR_1_FOR_EXIT:
j 1_FOR_2_FOR_ENTRY


########################################################################

# # Now we will begin Gaussian elimination steps

1_FOR_2_FOR_ENTRY:
la a0,constants
lw a1,0(a0) # a1 = i
addi a1,a1,1 # a1 = i + 1
sw a1 , 8(a0) # k = i + 1
j 1_FOR_2_FOR_BOUND_CHECK

1_FOR_2_FOR_BOUND_CHECK:
la a0,constants
lw a1 , 8(a0) # a1 = k
lw a2, 12(a0) # a2 = row_number(m)
bge a1 , a2 ,1_FOR_2_FOR_EXIT # if k>=m break the loop
j 1_FOR_2_FOR_IF_CONDITIONAL

1_FOR_2_FOR_IF_CONDITIONAL:
la a0,constants
la t3,A # t3 = base addr of A
lw a1,0(a0) # a1 = i
addi a2 , zero , 24 # a2 = 24
mul a2,a2,a1 # a2 = 24 * i
slli a1 , a1 ,2 # computing effective address of i by 4 * i
add a2 , a2, a1 # a2 = 24 * i + 4 * i
add t3 , t3 ,a2 # A[i][i] = 24 * i + 4 * i + base address
flw ft0 , 0(t3) # ft0 = A[i][i]
lw t5,zero_representation
flw ft1 , 0(t5) # ft1 = 0 
feq.s a3, ft0 , ft1
xori a3, a3 , 1 # if A[i][i] == 0 then a3 = 1
bnez a3 , 1_FOR_2_FOR_BODY
j 1_FOR_2_FOR_IF_EXIT # break encountered

1_FOR_2_FOR_IF_EXIT:
j 1_FOR_2_FOR_EXIT

1_FOR_2_FOR_BODY:#temp = a[k][i]/a[i][i]
la a0,constants
la t3,A # t3 = contains the base address of A
lw a1,0(a0) # a1 = i
addi a2, zero,24 # a2 = 24
mul a3,a1,a2 # a3 = 24 * i 
slli a1,a1,2 # computing effective address for i by 4 * i
add a3,a3,a1 # a3 = 24 * i + 4 * i This is basically for finding the index of A[i][i], 24 because 5 * 4 , 1 word= 4 bytes
add a3,a3,t3 # computing effective address ==> base + offset
flw ft0,0(a3) # ft0 = A[i][i]
lw a3,8(a0) # a3 = k
mul a3,a3,a2 # a3 = 24*k
add a3,a3,a1 # a3 = 24 * k + 4 * i ==> [k][i]
add a3,a3,t3 # computing effective address ==> base + offset
flw ft1,0(a3) # ft1 = A[k][i]
fdiv.s ft1,ft1,ft0 # ft1 = A[k][i]/A[i][i]
la a2,temp #loading the base address of temp variable in a2 to store ft1 temporarily
fsw ft1,0(a2) # temp = A[k][i]/A[i][i]
mv a1,zero
sw a1, 4(a0) # making j = 0
j 1_FOR_2_FOR_1_FOR_BOUND_CHECK

1_FOR_2_FOR_1_FOR_BOUND_CHECK:
la a0,constants
lw a1,4(a0) # x1 = j
lw a2,16(a0) # x2 = col_number(n)
bge a1,a2,1_FOR_2_FOR_1_FOR_EXIT # if j >= n break the loop
j 1_FOR_2_FOR_1_FOR_BODY

1_FOR_2_FOR_1_FOR_BODY:
la t3,A # t3 = base addr of A
la a0,constants
lw a1 , 0(a0) # a1 = i
lw a2 , 4(a0) # a2 = j
lw a3 , 8(a0) # a3 = k
addi a4 , zero , 24 # a4 = 24
mul t4 , a4 , a1 # t4 = 24 * i
slli a2,a2,2 # computing effective address for j by 4 * j
add t4 , t4 , a2 # t4 = 24 * i + 4 * j ==> [i][j]
add t4, t4, t3 # computing effective address ==> base + offset
flw ft0 , 0(t4) # ft0 = A[i][j]
mul t5 , a4 , a3 # t5 = 24 * k 
add t5 , t5 , a2 # t5 = 24 * k + 4 * j ==> [k][j]
add t5,t5,t3 # computing effective address ==> base + offset
flw ft1 , 0(t5) # ft1 = A[k][j]
la a4,temp
flw ft2,0(a4) # ft2 = temp
fmul.s ft2, ft2 , ft0 # ft2 = temp * A[i][j]
fsub.s ft1, ft1 , ft2 # ft1 = A[k][j] - temp * A[i][j]
fsw ft1 , 0(t5) # A[k][j] = ft1
j 1_FOR_2_FOR_1_FOR_INCREMENT

1_FOR_2_FOR_1_FOR_INCREMENT:
la a0 , constants
lw a1 , 4(a0) # a1 = j
addi a1 , a1, 1 # j = j+1
sw a1 , 4(a0)
j 1_FOR_2_FOR_1_FOR_BOUND_CHECK

1_FOR_2_FOR_1_FOR_EXIT:
j 1_FOR_2_FOR_INCREMENT



1_FOR_2_FOR_INCREMENT:
la a0,constants
lw a1,8(a0) # a1 = i
addi a1,a1,1 # a1 = i + 1
sw a1 , 8(a0) # k = k + 1
j 1_FOR_2_FOR_BOUND_CHECK

1_FOR_2_FOR_EXIT:
j 1_FOR_INCREMENT



1_FOR_INCREMENT:
la a0,constants
lw a1,0(a0) # a1 = i
addi a1,a1,1 # i = i+1
sw a1,0(a0)
j 1_FOR_BOUND_CHECK


########################################################
#Now we will start the back substitution

1_FOR_EXIT:
j 2_FOR_ENTRY

2_FOR_ENTRY:
la a0,constants
lw a1,12(a0) # a1 = m
addi a1,a1,-1 # a1 = m-1
sw a1,0(a0) # i = m-1
j 2_FOR_BOUND_CHECK

2_FOR_BOUND_CHECK:
la a0,constants
lw a1,0(a0) # a1 = i
blt a1,zero,2_FOR_EXIT # if i < 0 then branch to 2_FOR_EXIT
j 2_FOR_BODY

2_FOR_BODY:
la a0,constants
la t3,A # t3 = Base addr for A matrix
la t4,x # t4 = Base addr of the x matrix where solution will be stored
lw a1,0(a0) # a1 = i
lw a2,16(a0) # a2 = n
addi a2 , a2,-1 # a2 = n-1
addi a3,zero,24 # a3 = 24
mul a3,a3,a1 # a3 = 24 * i
slli a2,a2,2 # a2 = (n-1) * 4 --> This is basically computing the effective address
add a3,a3,a2 # a3 = 24 * i + (n-1) * 4
add t3,t3,a3 # computing effective address = A[i][n-1] = base address + a3
flw ft0,0(t3) # ft0 = A[i][n-1]
slli a2,a1,2 # a2 = i * 4 --> [i]
add t4,t4,a2 # computing effective address --> t4 = Base addr of x + i * 4
fsw ft0,0(t4) # x[i]= ft0 = A[i][n-1]
# Now we will initialize write the initialize j operation for another inner loop
addi a1,a1,1 # a1 = i+1
sw a1,4(a0) # j = a1 = i+1
j 2_FOR_1_FOR_BOUND_CHECK

2_FOR_1_FOR_BOUND_CHECK:
la a0,constants # loading the base address of the constants
lw a1,16(a0) # a1 = col_number = n
lw a2,4(a0) # a2 = j
addi a1,a1,-1 # a1 = n - 1
bge a2,a1,2_FOR_1_FOR_EXIT # if (j >= n - 1 ) branch to 2_FOR_1_FOR_EXIT
j 2_FOR_1_FOR_BODY

2_FOR_1_FOR_BODY:
la a0,constants
la t3,A # t3 = Base addr for A matrix
la t4,x # t4 = Base addr of the x matrix where solution will be stored
lw a1,0(a0) # a1 = i
lw a2,4(a0) # a2 = j
addi a3,zero,24 # a3 = 24
mul a3,a3,a1 # a3 = 24 * i
slli a2,a2,2 # a2 = j * 4 --> This is basically computing the effective address
add a3,a3,a2 # a3 = 24 * i + j * 4
add t3,t3,a3 # computing effective address t3 = A[i][j] = base address + a3
flw ft0,0(t3) # ft0 = A[i][j]
add a2,a2,t4 # a2 = 4 * j + x = x[j]
flw ft1,0(a2) # ft1 = x[j]
fmul.s ft0,ft0,ft1 # ft0 = A[i][j] * x[j]
slli a2,a1,2 # a2 = i * 4 --> [i]
add t4,t4,a2 # computing effective address --> t4 = Base addr of x + i * 4 = x[i]
flw ft1,0(t4) # ft1 = x[i]  
fsub.s ft1,ft1,ft0 # ft1 = x[i] - A[i][j]*x[j]
fsw ft1,0(t4) # x[i] = ft1 = x[i] - A[i][j]*x[j]
j 2_FOR_1_FOR_INCREMENT

2_FOR_1_FOR_INCREMENT:
la a0,constants
lw a1,4(a0) # a1 = i
addi a1,a1,1 # j = j+1
sw a1,4(a0)
j 2_FOR_1_FOR_BOUND_CHECK

2_FOR_1_FOR_EXIT:
j 2_FOR_1_IF_CONDITION

2_FOR_1_IF_CONDITION:
la a0,constants 
la t3,x # t3 = base addr of x
lw a2,0(a0) # a2 = i
slli a2,a2,2 # a2 = i * 4 --> [i]
add t3,t3,a2 # computing effective address --> t3 = Base addr of x + i * 4 = x[i]
flw ft0,0(t4) # ft0 = x[i]  
la a1,zero_representation
flw ft1,0(a1) # ft1 = 0
feq.s a0,ft0,ft1 # if x[i] == 0 then sets a0 = 1
xori a0,a0,1
bnez a0,2_FOR_1_IF_CONDITION_EXIT
j 2_FOR_1_IF_CONDITION_IF_CONDITION

2_FOR_1_IF_CONDITION_IF_CONDITION:
la a0,constants
la t3,A # t3 = base addr of A
lw a1,0(a0) # a1 = i
addi a2 , zero , 24 # a2 = 24
mul a2,a2,a1 # a2 = 24 * i
slli a1 , a1 ,2 # computing effective address of i by 4 * i
add a2 , a2, a1 # a2 = 24 * i + 4 * i
add t3 , t3 ,a2 # A[i][i] = 24 * i + 4 * i + base address
flw ft0 , 0(t3) # ft0 = A[i][i]
la t5,zero_representation
flw ft1 , 0(t5) # ft1 = 0 
feq.s a3, ft0 , ft1
# xori a3, a3 , 1 # if A[i][i] == 0 then a3 = 1
bnez a3 , INFINITE_SOLUTION_EXISTS
j 2_FOR_1_IF_CONDITION_IF_CONDITION_EXIT

2_FOR_1_IF_CONDITION_IF_CONDITION_EXIT:
j 2_FOR_1_IF_CONDITION_EXIT

2_FOR_1_IF_CONDITION_EXIT:
j 2_FOR_2_IF_CONDITION

2_FOR_2_IF_CONDITION:
la a0,constants 
la t3,x # t3 = base addr of x
lw a2,0(a0) # a2 = i
slli a2,a2,2 # a2 = i * 4 --> [i]
add t3,t3,a2 # computing effective address --> t3 = Base addr of x + i * 4 = x[i]
flw ft0,0(t4) # ft0 = x[i]  
la a1,zero_representation
flw ft1,0(a1) # ft1 = 0
feq.s a0,ft0,ft1 # if x[i] == 0 then sets a0 = 1
bnez a0,2_FOR_2_IF_CONDITION_EXIT # if a0 = 1 then it will branch to exit, means x[i] is equal to 0
j 2_FOR_2_IF_CONDITION_IF_CONDITION

2_FOR_2_IF_CONDITION_IF_CONDITION:
la a0,constants
la t3,A # t3 = base addr of A
lw a1,0(a0) # a1 = i
addi a2 , zero , 24 # a2 = 24
mul a2,a2,a1 # a2 = 24 * i
slli a1 , a1 ,2 # computing effective address of i by 4 * i
add a2 , a2, a1 # a2 = 24 * i + 4 * i
add t3 , t3 ,a2 # A[i][i] = 24 * i + 4 * i + base address
flw ft0 , 0(t3) # ft0 = A[i][i]
la t5,zero_representation
flw ft1 , 0(t5) # ft1 = 0 
feq.s a3, ft0 , ft1
# xori a3, a3 , 1 # if A[i][i] == 0 then a3 = 1
bnez a3 , NO_SOLUTION_EXISTS
j 2_FOR_2_IF_CONDITION_IF_CONDITION_EXIT

2_FOR_2_IF_CONDITION_IF_CONDITION_EXIT:
j 2_FOR_2_IF_CONDITION_EXIT


2_FOR_2_IF_CONDITION_EXIT:
j 2_FOR_BODY_REMAINING

2_FOR_BODY_REMAINING:
la a0,constants
la t3,A # t3 = base addr of A
la t4,x # t4 = base addr of x
lw a1,0(a0) # a1 = i
addi a2 , zero , 24 # a2 = 24
mul a2,a2,a1 # a2 = 24 * i
slli a1 , a1 ,2 # computing effective address of i by 4 * i
add a2 , a2, a1 # a2 = 24 * i + 4 * i
add t3 , t3 ,a2 # A[i][i] = 24 * i + 4 * i + base address
flw ft0 , 0(t3) # ft0 = A[i][i]
add t4,a1,t4 # t4 = a1 + t4 = base addr of x + 4 * i
flw ft1,0(t4) # ft1 = x[i]
fdiv.s ft1,ft1,ft0 # ft1 = x[i] / A[i][i]
fsw ft1,0(t4) # x[i] = ft1 = x[i] / A[i][i]
j 2_FOR_DECREMENT


2_FOR_DECREMENT:
la a0,constants
lw a1,0(a0) # a1 = i
addi a1,a1,-1 # a1 = i - 1
sw a1,0(a0) # i = i - 1
j 2_FOR_BOUND_CHECK


2_FOR_EXIT:
j PRINT_MATRIX_X
# j PRINT_MATRIX_A


NO_SOLUTION_EXISTS:
li a0,4 #call id 4 to print string , should be in a0
la a1,NO_SOLUTION # address of s should be in a1
ecall
j exit

INFINITE_SOLUTION_EXISTS:
addi a0,x0,4 #call id 4 to print string , should be in a0
la a1,INFINITE_SOLUTION # address of s should be in a1
ecall
j exit



########################################################

# The block of code below is for printing the A matrix after Gaussian elimination 
PRINT_MATRIX_A:
la t3,A #Base address of A
addi t4, zero, 5 # t4 = 5 --> keeps the total elements to be printed in single line which is 6
addi t5, zero, 5 # t5 = 4 --> keeps the total lines to be printed which is 5
mv a2, zero # keeps track of the current element number in a line
mv a3, zero # keeps track of the line number
j parent_loop

child_loop:
addi a0,x0,34 # ecall id number for printing hex
lw a1,0(t3)
ecall
li a0,11 # ecall id number for printing ascii character
li a1,32 # 32 is the ASCII number for space
ecall
addi t3,t3,4
bge a2,t4,parent_loop
addi a2,a2,1
j child_loop

parent_loop:
li a0,11
li a1,10 # 10 is the ASCII number for enter. 
ecall # print newline
bge a3,t5,exit
mv a2, zero # resetting a2 
addi a3,a3,1
j child_loop


PRINT_MATRIX_X:
la t3,x #Base address of x
addi t4, zero, 4 # t4 = 4 --> keeps the total elements to be printed 
mv a2, zero # keeps track of the current element number 
j print_loop

print_loop:
addi a0,x0,34 # ecall id number for printing hex
lw a1,0(t3)
ecall
li a0,11 # ecall id number for printing ascii character
li a1,32 # 32 is the ASCII number for space
ecall
addi t3,t3,4
bge a2,t4,exit
addi a2,a2,1
j print_loop

exit:














