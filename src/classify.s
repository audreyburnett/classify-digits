.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    addi t0 x0 5 #set t0 to 5
    bne a0 t0 arg_fail #error if the num of argumetns provided is not 5
    
    #prologue
    addi sp sp -52
    sw s0 0(sp)
    sw s1 4(sp)
    sw s2 8(sp)
    sw s3 12(sp)
    sw s4 16(sp)
    sw s5 20(sp)
    sw s6 24(sp)
    sw s7 28(sp)
    sw s8 32(sp)
    sw s9 36(sp)
    sw s10 40(sp)
    sw s11 44(sp)
    sw ra 48(sp)
    
    mv s0 a0 #argc
    mv s1 a1 #arcv
    mv s2 a2 #silent mode
    
    # Read pretrained m0
    addi a0 x0 4 #set a0 to 4
    jal ra malloc 
    beq a0 x0 malloc_fail
    mv s3 a0 #set s3 to pointer to rows of m0
    
    addi a0 x0 4 #set a0 to 4
    jal ra malloc 
    beq a0 x0 malloc_fail
    mv s4 a0 #set s4 to pointer to cols of m0
    
    lw a0 4(s1) #set a0 to pointer to filepath of m0
    mv a1 s3 #a1: pointer to num of rows
    mv a2 s4 #a2: pointer to num of cols
    jal ra read_matrix
    mv s5 a0 #set s5 to a pointer to the matrix
    
    # Read pretrained m1
    addi a0 x0 4 #set a0 to 4
    jal ra malloc 
    beq a0 x0 malloc_fail
    mv s6 a0 #set s6 to pointer to rows of m1
    
    addi a0 x0 4 #set a0 to 4
    jal ra malloc 
    beq a0 x0 malloc_fail
    mv s7 a0 #set s7 to pointer to cols of m1
    
    lw a0 8(s1) #set a0 to pointer to filepath of m1
    mv a1 s6 #a1: pointer to num of rows
    mv a2 s7 #a2: pointer to num of cols
    jal ra read_matrix
    mv s8 a0 #set s8 to a pointer to the matrix
    

    # Read input matrix
    addi a0 x0 4 #set a0 to 4
    jal ra malloc
    beq a0 x0 malloc_fail
    mv s9 a0 #set s6 to pointer to rows of input
    
    addi a0 x0 4 #set a0 to 4
    jal ra malloc 
    beq a0 x0 malloc_fail
    mv s10 a0 #set s10 to pointer to cols of input
    
    lw a0 12(s1) #set a0 to pointer to filepath of input
    mv a1 s9 #a1: pointer to num of rows
    mv a2 s10 #a2: pointer to num of cols
    jal ra read_matrix
    mv s11 a0 #set s11 to a pointer to the matrix
    

    # Compute h = matmul(m0, input)
    lw t0 0(s3) #t0: num of rows of m0
    lw t1 0(s10) #t1: num of cols of input
    mul t0 t0 t1 #dimensions of h: rows of m0 x cols of input
    addi t1 x0 4 #t1 = 4
    mul a0 t0 t1 #a0 = dim of h x 4 bytes per element
    jal ra malloc 
    beq a0 x0 malloc_fail
    

    
    mv a6 a0 #a6: pointer to where h should be stored
    mv s0 a6 #store a6 in s0
    mv a0 s5 #a0: pointer to m0
    lw a1 0(s3) #a1: rows of m0
    lw a2 0(s4) #a2: cols of m0
    mv a3 s11 #a3: pointer to input
    lw a4 0(s9) #a4: rows of input
    lw a5 0(s10) #a5: cols of input
    jal ra matmul

    # Compute h = relu(h)
    mv a0 s0 #a0: pointer to h
    lw t0 0(s3) #t0: num of rows of m0
    lw t1 0(s10) #t1: num of cols of input
    mul a1 t0 t1 #a1: size of h
    jal ra relu

    # Compute o = matmul(m1, h)
    lw t0 0(s6) #t0: num of rows of m1
    lw t1 0(s10) #t1: num of cols of h (= cols of input)
    mul t0 t0 t1 #dimensions of o: rows of m1 x cols of h
    addi t1 x0 4 #t1 = 4
    mul a0 t0 t1 #a0 = dim of o x 4 bytes per element
    jal ra malloc 
    beq a0 x0 malloc_fail
    
   
    
    mv a6 a0 #a6: pointer to where o should be stored
    mv a3 s0 #a3: pointer to h
    mv s0 a6 #store a6 in s0
    mv a0 s8 #a0: pointer to m1
    lw a1 0(s6) #a1: rows of m1
    lw a2 0(s7) #a2: cols of m1
    lw a4 0(s3) #a4: rows of h (= rows of m0)
    lw a5 0(s10) #a5: cols of h (= cols of input)
    jal ra matmul
    
    # Write output matrix o
    mv a1 s0 #a1: pointer to matrix o
    lw a0 16(s1) #a0: pointer to filepath of output 
    lw a2 0(s6) #a2: num rows of o (= rows of m1)
    lw a3 0(s10) #a3: num cols of o (= cols of h)
    jal ra write_matrix

    # Compute and return argmax(o)
    mv a0 s0 #a0: pointer to matrix o
    lw t0 0(s6) #t0: num rows of o (= rows of m1)
    lw t1 0(s10) #t1: num cols of o (= cols of h)
    mul a1 t0 t1 #a1: size of o
    jal ra argmax
    
    mv s0 a0 #store argmax(o) in s0

    # If enabled, print argmax(o) and newline
    bne s2 x0 continue #if set to 0, print classification
    #a0 already set to output of argmax(o)
    jal ra print_int
    
    li a0 '\n' #print newline character
    jal ra print_char
    
    j continue
    
    # errors
    malloc_fail: 
        li a0 26 #exit with error code 26
        j exit
    arg_fail: 
        li a0 31 #exit with error code 31
        j exit
    continue:  
        mv a0 s3 #free s3 pointer (rows of m0)
        jal ra free
        mv a0 s4 #free s4 pointer (cols of m0)
        jal ra free
        mv a0 s5 #free s5 pointer (pointer to m0)
        jal ra free
        mv a0 s6 #free s6 pointer (rows of m1)
        jal ra free
        mv a0 s7 #free s7 pointer (cols of m1)
        jal ra free
        mv a0 s8 #free s8 pointer (pointer to m1)
        jal ra free
        mv a0 s9 #free s9 pointer (rows of input)
        jal ra free
        mv a0 s10 #free s10 pointer (cols of input)
        jal ra free
        mv a0 s11 #free s11 pointer (pointer to input)
        jal ra free
        
        #set return value
        mv a0 s0 
        
        #epilogue
        lw s0 0(sp)
        lw s1 4(sp)
        lw s2 8(sp)
        lw s3 12(sp)
        lw s4 16(sp)
        lw s5 20(sp)
        lw s6 24(sp)
        lw s7 28(sp)
        lw s8 32(sp)
        lw s9 36(sp)
        lw s10 40(sp)
        lw s11 44(sp)
        lw ra 48(sp)
        addi sp sp 52
    
        jr ra
