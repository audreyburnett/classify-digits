.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:
    addi sp sp -32
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw ra, 28(sp)
    # Prologue

    mv s0 a0 #s0: pointer to string of filename
    mv s1 a1 #s1: pointer to matrix in mem
    mv s2 a2 #s2: pointer to integer for num of rows
    mv s3 a3 #s3: pointer to integer for num of cols

    #a0 is already a pointer to a string of the filename
    addi t0 t0 1 #set t0 to 1
    mv a1 t0 #set permission bits to 1 for write-only
    jal ra fopen
    
    addi t0 x0 -1 #set t0 to -1
    bne a0 t0 continue #if return value a0 is not -1, don't raise an error
    li a0 27 #exit with error code 27
    j exit

    continue:
        mv s4 a0 #store file descriptor in s4
        
        #WRITE ROW NUM
        #a0 already returned by fopen
        mv a2 s2 #a2 is pointer to store num rows
        addi a3 x0 4 #set a3 to 4 to read 4 bytes from the file
        addi s6 a3 0 #set s6 to a3
        jal ra fwrite 
        bne a0 s6 write_error #if we recieve fwrite error or eof
        
        #WRITE COL NUM
        mv a0 s4 #set a0 to file descriptor
        mv a3 s3 #a3 is pointer to store num cols
        addi a4 x0 4 #set a4 to 4 to read 4 bytes from the file
        addi s6 a4 0 #set s6 to a4
        jal ra fwrite
        bne a0 s6 write_error #if we recieve fwrite error or eof
        
        
        #WRITE MATRIX
        
        mv a0 s4 #set a0 to file descriptor
        mv a1 s1 #a1 is pointer to store matrix
        mv a2 s2 #a2 is number of elems to write 
        mv a3 s3 #a3 is size of each elem
        mul a5 a2 a3
        jal ra fwrite
        beq a0 s5 continue2 #if there is no error, go to continue2
        
        write_error: 
            li a0 30 #exit with error code 30
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
