.data

.text
.globl main

main:
    lw      $t0,    0($zero)
    addi    $t0,    $t0,    7
    addi    $t1,    $zero,  16
    sw      $t0,    0($t1)
    
     
    
    