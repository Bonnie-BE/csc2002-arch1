.data
    filename_input:	.asciiz "Enter a wave file name:\n"
    filesize_input:	.asciiz "Enter the file size (in bytes):\n"
    info_lab:		.asciiz "Information about the wave file:\n================================\n"
    numChannels:	.asciiz "Number of channels: "
    sampleRate:	        .asciiz "Sample rate: "
    byteRate:	        .asciiz "Byte rate: "
    bitsPerSample:	.asciiz "Bits per sample: "
    newline:		.asciiz "\n"
    filename:           .space 256
    buffer:             .space 44 #WAVE header-44 bytes
.text
.globl main
main:
    #prompting the user for the filename the loading the address of the prompt
    li $v0, 4  #syscall for print string
    la $a0, filename_input
    syscall
    
    li $v0, 8  #syscall for read string
    la $a0, filename  #buffer for filename
    li $a1, 256  #maximum length of filename
    syscall
    
    #remove newline from filename
    la $t0, filename

rmv_newline:
    lb $t1, ($t0)
    beqz $t1, rmv_newline_end
    bne $t1, 10, next_character
    sb $zero, ($t0)
    j rmv_newline_end    	
    
next_character:
    addi $t0, $t0, 1
    j rmv_newline
    
rmv_newline_end:        
    #prompting the user for the filesize
    li $v0, 4
    la $a0, filesize_input
    syscall
    
    #read integer syscall 
    li $v0, 5
    syscall
    #move $t0, $v0
    
    #open the file to read it
    li $v0, 13   #open_file syscall
    la $a0, filename   #get the filename
    li $a1, 0   #file flag
    #li $a2, 0
    syscall
    move $s0, $v0   #save file descriptor
    
    bltz $s0, exit
    
    #read header
    li $v0, 14
    move $a0, $s0
    la $a1, buffer
    li $a2, 44
    syscall
    
    #close file
    li $v0, 16
    move $a0, $s0
    syscall
    
    #print info label
    li $v0, 4
    la $a0, info_lab
    syscall
    
    #print num of channels
    li $v0, 4
    la $a0, numChannels
    syscall
    
    la $t0, buffer
    lhu $a0, 22($t0)
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall
    
    #print sample rate
    li $v0, 4
    la $a0, sampleRate
    syscall
    
    la $t0, buffer
    lw $a0, 24($t0)
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall
    
    #print byte rate
    li $v0, 4
    la $a0, byteRate 
    syscall
    
    la $t0, buffer
    lw $a0, 28($t0)
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall
    
    #print bits per sample
    li $v0, 4
    la $a0, bitsPerSample
    syscall
    
    la $t0, buffer
    lhu $a0, 34($t0)
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall
    
exit:        
    #syscall to exit
    li $v0, 10
    syscall
