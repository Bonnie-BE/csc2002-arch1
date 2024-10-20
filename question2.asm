.data
    filename_input:  .asciiz "Enter a wave file name:\n"
    filesize_input:  .asciiz "Enter the file size (in bytes):\n"
    info_lab:        .asciiz "Information about the wave file:\n================================\n"
    max_amp:         .asciiz "Maximum amplitude: "
    min_amp:         .asciiz "Minimum amplitude: "
    newline:         .asciiz "\n"
    filename:        .space 256
    file_des:        .word 0
    buffer:          .space 100

.text
.globl main

main:
    #prompting the user for the filename the loading the address of the prompt
    li $v0, 4
    la $a0, filename_input
    syscall
    
    li $v0, 8
    la $a0, filename
    li $a1, 256
    syscall
    
    #remove newline from filename
    la $t0, filename

rmv_newline:
    lb $t1, ($t0)
    beqz $t1, rmv_newline_end
    bne $t1, 10, not_newline
    sb $zero, ($t0)
    j rmv_newline_end

not_newline:
    addi $t0, $t0, 1
    j rmv_newline

rmv_newline_end:
    #prompting the user for the filesize
    li $v0, 4
    la $a0, filesize_input
    syscall
    
    li $v0, 5
    syscall
    move $s0, $v0 
    
    #open the file to read it
    li $v0, 13
    la $a0, filename
    li $a1, 0     
    li $a2, 0
    syscall
    move $s1, $v0  
    
    #skip the first 44 bytes
    li $v0, 14
    move $a0, $s1
    la $a1, buffer
    li $a2, 44
    syscall
    
    #initialize maximum and minimum values
    li $s2, -32768  #store minimum
    li $s3, 32767  #store maximum 
    li $s4, 0       
    
    #read and process audio data
    subu $s0, $s0, 44 
    li $t0, 0          

loop:
    bge $t0, $s0, display_results 
    
    #read a chunk of data
    li $v0, 14
    move $a0, $s1
    la $a1, buffer
    li $a2, 4096
    syscall
    
    move $t1, $v0 
    add $t0, $t0, $t1 
    
    #process chunk
    la $t2, buffer  
    li $t3, 0       

process_chunk:
    bge $t3, $t1, loop  
    
    #load 2 bytes then combine into a single signed integer
    lbu $t4, 0($t2)
    lbu $t5, 1($t2)
    sll $t5, $t5, 8
    or $t4, $t4, $t5
    
    sll $t4, $t4, 16
    sra $t4, $t4, 16
    
    #updating the maximum and minimum
    beqz $s4, first_sample
    bgt $t4, $s2, update_max
    blt $t4, $s3, update_min
    j continue

first_sample:
    li $s4, 1       
    move $s2, $t4  
    move $s3, $t4
    j continue

update_max:
    move $s2, $t4
    j continue

update_min:
    move $s3, $t4

continue:
    addi $t2, $t2, 2  
    addi $t3, $t3, 2  
    j process_chunk

display_results:
    #display header 
    li $v0, 4
    la $a0, info_lab
    syscall

    #print maximum value
    li $v0, 4
    la $a0, max_amp
    syscall
    move $a0, $s2
    li $v0, 1
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    
    #print minimum value
    li $v0, 4
    la $a0, min_amp
    syscall
    move $a0, $s3
    li $v0, 1
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    
    #close file
    li $v0, 16
    move $a0, $s1
    syscall
    
    #exit program
    li $v0, 10
    syscall
