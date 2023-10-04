.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:

    # Prologue
    addi sp sp -32
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw ra, 28(sp)
    
    
    mv s0 a0 #s0: pointer to string of filenam
    mv s1 a1 #s1: pointer to integer for num of rows
    mv s2 a2 #s2: pointer to integer for num of cols

    #a0 is already a pointer to a string of the filename
    mv a1 x0 #set permission bits t0 0 for read-only
    jal ra fopen
    
    addi t0 x0 -1 #set t0 to -1
    bne a0 t0 continue #if return value a0 is not -1, don't raise an error
    li a0 27 #exit with error code 27
    j exit
    
    continue:
        mv s3 a0 #store file descriptor in s3
        
        #READ ROW NUM
        #a0 already returned by fopen
        mv a1 s1 #a1 is pointer to store num rows
        addi a2 x0 4 #set a2 to 4 to read 4 bytes from the file
        addi s6 a2 0 #set s6 to a2
        jal ra fread 
        bne a0 s6 read_error #if we recieve fread error or eof
        
        #READ COL NUM
        mv a0 s3 #set a0 to file descriptor
        mv a1 s2 #a1 is pointer to store num cols
        addi a2 x0 4 #set a2 to 4 to read 4 bytes from the file
        addi s6 a2 0 #set s6 to a2
        jal ra fread
        bne a0 s6 read_error #if we recieve fread error or eof
        
        #ALLOCATE SPACE TO STORE MATRIX
        lw t1 0(s1) #load num of rows into t1
        lw t2 0(s2) #load num of cols into t1
        addi t3 x0 4 #set t3 to 4
        mul s5 t1 t2 #set s5 to rows times cols
        mul s5 s5 t3 #set s5 to 4 times (rows times cols): 4 bytes per integer
        mv a0 s5 #set a0 to the bytes to allocate
        jal ra malloc 
        
        beq a0 x0 malloc_error #branch if malloc returns an error
        
        #READ MATRIX
        mv s4 a0 #store pointer to allocated memory for the matrix
        mv a0 s3 #set a0 to file descriptor
        mv a1 s4 #a1 is pointer to store matrix
        mv a2 s5 #a2 is number of bytes to read (prev. calculated in s5)
        jal ra fread
        beq a0 s5 continue2 #if there is no error, go to continue2
        
        read_error: 
            li a0 29 #exit with error code 29
            j exit
        malloc_error:
            li a0 26 #exit with error code 26
            j exit
        continue2:
            mv a0 s3 #set a0 to file descriptor
            jal ra fclose
            beq a0 x0 finish #go to finish if no error, otherwise throw an error
            
            li a0 28 #exit with error code 28
            j exit
        
    finish: 
        mv a0 s4 #move pointer to array to a0
        
        # Epilogue
        lw s0, 0(sp)
        lw s1, 4(sp)
        lw s2, 8(sp)
        lw s3, 12(sp)
        lw s4, 16(sp)
        lw s5, 20(sp)
        lw s6, 24(sp)
        lw ra, 28(sp)
        addi sp sp 32

        jr ra
