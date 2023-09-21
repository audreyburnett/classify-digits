.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue
    addi t1 x0 0 #initialize the current array index t1 t0 0
    addi t2 a0 0 #t2 points to first integer of the array
    
    
    addi t0 x0 1 #set t0 to 1
    bge a1 t0 loop_start #continue if the length is greater than equal to 1, otherwise ends with error code 36
    li a0 36
    j exit
loop_start:
    beq t1 x0 else #if we're at first element, go to else
    
    lw t4 0(t2) #set t4 to current int
    bge t3 t4 loop_continue
    mv t3 t4 #set t4 to new max
    mv t5 t1 #set the max index to the current index
    j loop_continue
    
    
    else:
        lw t3 0(t2) #initialize t3 to the first int in the array
        addi t5 x0 0 #set the max index to 0 

loop_continue:
    addi t2 t2 4 #move the pointer by one integer
    addi t1 t1 1 # increments the value of t1
    bne t1 a1 loop_start #if we have not reached the end of the array, go back to loop_start

loop_end:
    # Epilogue
    mv a0 t5 #set the return value to the max index
    jr ra
