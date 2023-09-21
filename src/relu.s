.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    # Prologue
    addi t2 a0 0 # set t2 to the address of the beginning of the array
    addi t4 x0 0 #sets t4 to 0; t4 is incremented in loop
    
    addi t0 x0 1 #set t0 to 1
    bge a1 t0 loop_start #continue if the length is greater than equal to 1, otherwise ends with error code 36
    li a0 36
    j exit
loop_start:
    lw t3 0(t2) #load current int into t2
    bge t3 x0 loop_continue #if the int is greater than or equal to 0, go to loop_continue (no changes need to be made)
    #otherwise, change the value to 0:
    sw x0 0(t2) #replaces the negative value with 0 
    
loop_continue:
    addi t2 t2 4
    addi t4 t4 1 # increments the value of t4
    bne t4 a1 loop_start #if we have not reached the end of the array, go back to loop_start
   
loop_end:
    # Epilogue

    jr ra
