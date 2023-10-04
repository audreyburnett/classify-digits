.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:
    # Prologue
    addi sp sp -52
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw s8, 32(sp)
    sw s9, 36(sp)
    sw s10, 40(sp)
    sw s11, 44(sp)
    sw ra, 48(sp)
    
    mv s0 a0 
    mv s1 a1
    mv s2 a2
    mv s3 a3
    mv s4 a4
    mv s5 a5
    mv s6 a6
    addi s7 x0 0 #current row index
    addi s8 x0 0 #current col index
    add s9 a6 x0 #memory location in a6
    mv s10 a0 
    mv s10 a3
    
    
    # Error checks
    addi t0 x0 1 #set t0 to 1
    blt a1 t0 error 
    blt a2 t0 error
    blt a4 t0 error
    blt a5 t0 error
    bne a2 a4 error
    j outer_loop_start
    
    error: 
        li a0 38 #exit with error code 38
        j exit

outer_loop_start:
    #rows of d -> 0 to a1
    beq s7 s1 outer_loop_end #break if row index equals num rows
    addi s8 x0 0 #reset col index to 0 
    
   

inner_loop_start:
    #columns of d for each row -> 0 to a5
    beq s8 s5 inner_loop_end #break if col index equals num cols
    
    mul t0 s2 s7 #set t0 to cols in the first array times current row index
    addi t1 x0 4 #set t1 to 4
    mul t0 t0 t1 #multiply t0 by 4
    add s10 s0 t0 #set the pointer to the address of second array + offset of t0
    mv a0 s10 #set pointer to first array
    mul t0 s8 t1 # t0 is s8 (offset) times 4
    add a1 s3 t0 #set pointer to address of second array + offset of current col
    mv a2 s2 #number of elements to use is col of first array 
    addi a3 x0 1 #stride of first array is 1
    mv a4 s5 #stride of second array is # of col of second array
    jal ra, dot 
    
    sw a0 0(s9) #stores returned dot product in current index of the output array
    addi s9 s9 4 #increment s9 by 4
    
    addi s8 s8 1 #increment col counter
    j inner_loop_start #return to start of loop


inner_loop_end:
    addi s7 s7 1 #increment row counter
    j outer_loop_start



outer_loop_end:
    
    mv a6 s6 #move the output array into a6
    
    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw s8, 32(sp)
    lw s9, 36(sp)
    lw s10, 40(sp)
    lw s11, 44(sp)
    lw ra, 48(sp)
    addi sp sp 52

    jr ra
