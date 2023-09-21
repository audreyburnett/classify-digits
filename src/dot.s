.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the number of elements to use is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:

    # Prologue
    addi t1 a0 0 #t1 points to beginning of first array
    addi t2 a1 0 #t2 points to beginning of second array
    addi t5 x0 0 #t5 is the sum
    addi t6 x0 0 #number of elems we have used
    
    addi t0 x0 1 #set t0 to 1
    bge a3 t0 check1
    li a0 37
    j exit
    check1:
        bge a4 t0 check2
        li a0 37
        j exit
    check2:
        bge a2 t0 loop_start #continue if the length is greater than equal to 1, otherwise ends with error code 36
        li a0 36
        j exit
loop_start:
    beq t6 a2 loop_end
    lw t3 0(t1) #gets value of first list elem
    lw t4 0(t2) #gets val of second list elem
    mul t3 t3 t4 #stores product into t3
    add t5 t5 t3 #updates sum
    addi t4 x0 4 #sets t4 to 4
    mul t4 t4 a3 #multiplies t4 by stride of first array
    add t1 t1 t4 #sets pointer to next elem
    addi t4 x0 4 #sets t4 to 4
    mul t4 t4 a4 #multiplies t4 by stride of first array
    add t2 t2 t4 #sets pointer to next elem
    addi t6 t6 1 #increment number of elems we've visited
    j loop_start


loop_end:
    mv a0 t5
    # Epilogue


    jr ra
