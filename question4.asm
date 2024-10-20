.data
    wav_name:    .space 256                                    

.text
.globl main

main:
    #get the wav file name
    li $v0, 8                                                           
    la $a0, wav_name                                              
    li $a1, 256                                                         
    syscall                                                             

    #remove newline
    la $a0, wav_name                                              
    li $t1, 10                                                          
clean_in:
    lb $t0, 0($a0)                                                      
    beqz $t0, params                                                    
    beq $t0, $t1, end_str                                      
    addi $a0, $a0, 1                                                    
    j clean_in                                                    

end_str:
    sb $zero, 0($a0)                                                    
    j params                                                            

    #collect audio parameters
params:
    li $v0, 5                                                           
    syscall                                                             
    move $s0, $v0                                                       

    li $v0, 5                                                           
    syscall                                                             
    move $s1, $v0                                                       

    li $v0, 5                                                           
    syscall                                                             
    move $s2, $v0                                                       

    #calculate properties of the wave
    div $s1, $s0                                                        
    mflo $s5                                                            

    li $t6, 2                                                           
    div $s5, $t6                                                        
    mflo $s6                                                            

    mul $t0, $s2, $s1                                                   
    div $t0, $s6                                                        
    mflo $s7                                                            

    #determine file size and allocate memory
    mul $t0, $s1, $s2                                                   
    add $t0, $t0, $t0                                                   
    addi $t0, $t0, 44                                                   
    li $v0, 9                                                           
    move $a0, $t0                                                       
    syscall                                                             
    move $s3, $v0                                                       
    move $s4, $t0                                                       

    #generate square wav
    li $t0, 0                                                           
    addi $t1, $s3, 44                                                  
    li $t2, 32767                                                      
    li $t3, -32768                                                     

create_wave:
    li $t4, 0 
                                                          
hi_amp:
    sh $t2, 0($t1)                                                      
    addi $t1, $t1, 2                                                    
    addi $t4, $t4, 1                                                    
    slt $t5, $t4, $s6                                                    
    bnez $t5, hi_amp                                           
    li $t4, 0                                                           
lo_amp:
    sh $t3, 0($t1)                                                      
    addi $t1, $t1, 2                                                    
    addi $t4, $t4, 1                                                    
    slt $t5, $t4, $s6                                                    
    bnez $t5, lo_amp                                            

    addi $t0, $t0, 2                                                    
    bne $t0, $s7, create_wave                                          

    #save the wav file
save_file:
    li $v0, 13                                                          
    la $a0, wav_name                                              
    li $a1, 65     #read-write mode
    li $a2, 511    #file permissions
    syscall                                                             
    move $t0, $v0                                                       

    li $v0, 15                                                          
    move $a0, $t0                                                       
    move $a1, $s3                                                       
    move $a2, $s4                                                       
    syscall                                                             

    #close
    li $v0, 16                                                          
    move $a0, $t0                                                       
    syscall                                                             

exit:
    li $v0, 10                                                          
    syscall
