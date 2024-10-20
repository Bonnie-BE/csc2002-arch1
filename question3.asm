.data
buffer: .space 4096  #reading/writing data buffer
header: .space 44
error_message: .asciiz "Error: File operation failed\n"

.text
.globl main

main:
    #input file name
    li $v0, 8
    la $a0, ($sp)
    li $a1, 256
    syscall
    jal rm_newline


    #output file name
    addi $sp, $sp, -256
    li $v0, 8
    move $a0, $sp
    li $a1, 256
    syscall
    jal rm_newline


    #read file size
    li $v0, 5
    syscall
    move $s2, $v0  

    #open input file
    li $v0, 13
    la $a0, 256($sp)
    li $a1, 0  
    li $a2, 0
    syscall
    bltz $v0, file_error
    move $s0, $v0  

    #open output file
    li $v0, 13
    move $a0, $sp
    li $a1, 0x41  #create and write-only
    li $a2, 0x1FF  #file permissions
    syscall
    bltz $v0, file_error
    move $s1, $v0  

    #read and write header
    li $v0, 14
    move $a0, $s0
    la $a1, header
    li $a2, 44
    syscall
    bne $v0, 44, file_error

    #header output
    li $v0, 15
    move $a0, $s1
    la $a1, header
    li $a2, 44
    syscall
    bne $v0, 44, file_error

    #data size calc
    addi $s3, $s2, -44 
    move $s4, $s3       

    #memory allocation for audio data
    move $a0, $s3
    li $v0, 9  
    syscall
    move $s5, $v0  

    #read audio data
    li $v0, 14
    move $a0, $s0
    move $a1, $s5
    move $a2, $s3
    syscall
    bne $v0, $s3, file_error

    #reverse audio data
    move $t0, $s5               
    add $t1, $s5, $s3
    addi $t1, $t1, -2           
reverse:
    bge $t0, $t1, write_data
    lhu $t2, ($t0)
    lhu $t3, ($t1)
    sh $t3, ($t0)
    sh $t2, ($t1)
    addi $t0, $t0, 2
    addi $t1, $t1, -2
    j reverse

write_data:
    #write reversed audio data
    li $v0, 15
    move $a0, $s1
    move $a1, $s5
    move $a2, $s3
    syscall
    bne $v0, $s3, file_error

close_file:
    li $v0, 16
    move $a0, $s0
    syscall
    li $v0, 16
    move $a0, $s1
    syscall
    j exit

file_error:
    li $v0, 4
    la $a0, error_message
    syscall
    j exit

exit:
    li $v0, 10
    syscall

rm_newline:
    li $t0, 0

rm_loop:
    lb $t1, ($a0)
    beqz $t1, end_rm
    bne $t1, 10, next_character
    sb $zero, ($a0)
    jr $ra

next_character:
    addi $a0, $a0, 1
    j rm_loop

end_rm:
    jr $ra
