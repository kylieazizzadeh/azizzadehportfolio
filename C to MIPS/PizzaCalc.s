.text
.align 2

.globl main

# s0 = head
# s1 = tail

main:
    # OPEN STACK
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)

    # set head and tail to null IS THIS THE CORRECT WAY TO DO IT????
    # move $s0, $0
    # move $s1, $0

    # sw $0, 0($s0)
    # sw $0, 0($s1)

    li $s0, 0
    li $s1, 0

_while:
    # while loop, dynamically adding new structs and sorting 
    # $t0 = temporary string
    # $f4 = temporary diameter
    # $f5 = temporary cost
    # $f0 = temporary ppd
    # $a0 = added in struct
    # $t1 = allocated memory

    # prompt user for pizza name and read in
    li $v0, 4
    la $a0, prompt_name
    syscall

    # read in 
    li $v0, 8 
    la $a0, buffer                          # read the string into the global memory space called buffer
    li $a1, 64 
    syscall

    # dynamically allocating memory
    li $v0, 9
    li $a0, 72
    syscall
    move $t1, $v0                           # allocated memory in t1

    la $t2, buffer
    move $t5, $t1           # t5 is temp parsing through strcopy

_strcopy:
    lb $t6, 0($t2)      # t6 = first character of buffer

    li $t7, 10
    beq $t6, $t7, _finishedcopy
    sb $t6, 0($t5)

    addi $t5, $t5, 1        # t1 is destination by editing $t5 
    addi $t2, $t2, 1

    j _strcopy

_finishedcopy:
    sb $0, 0($t5)       
    
    # load argument and call stringcmp (SEE IF IT IS EQUAL TO DONE)
    move $a0, $t1
    la $a1, done
    # save t registers being used
    addi $sp, $sp, -4
    sw $t1, 0($sp)
    jal strcmp       
    # restoring t registers to stack 
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    beqz $v0, _endloop                       # end loop if equal to done 
    la $t0, buffer                           # $t0 = str temp 

    # prompt user for diameter 
    li $v0, 4
    la $a0, prompt_diameter
    syscall

    # read in diameter as float
    li $v0, 6
    syscall
    mov.s $f4, $f0                           # $f4 = diameter temp (OR USE LA HERE???)

    # prompt user for cost 
    li $v0, 4
    la $a0, prompt_cost
    syscall

    # read in cost as float
    li $v0, 6
    syscall
    mov.s $f5, $f0                          # $f5 = cost temp (OR USE LA HERE???)

    # branch if either diameter or cost are zero
    li.s $f6, 0.0
    c.eq.s $f4, $f6
    bc1t _ifzero

    c.eq.s $f5, $f6
    bc1t _ifzero

    # calculate ppd
    mul.s $f6, $f4, $f4                     # $f6 = square inches calculation (diameter*diamteter)
    l.s $f7, PI                             # $f7 = PI
    l.s $f8, quarter                        # $f8 = quarter (0.25) 
    mul.s $f6, $f6, $f8                     # $f6 = (d*d)*.25
    mul.s $f6, $f6, $f7                     # $f6 = (d*d)*.25*PI = square inches
    div.s $f0, $f6, $f5                     # $f0 = ppd = square inches / cost
    j _notcalculating

_ifzero:
    li.s $f0, 0.0                           # make ppd 0 if cost or diameter are zero
    j _notcalculating

_notcalculating:
    move $a0, $t1                           # allocated memory now in $a0

    # putting ppd in memory
    s.s $f0, 64($a0)

    sw $0, 68($a0)

    move $a1, $s0                           # make next argument head
    move $a2, $s1                           # make next argument tail

    # DON'T CARE ABOUT ANY TEMPORARY REGISTERS SO DON'T HAVE TO SAVE (CALLING CONVENTIONS)  
    jal sortlist

    # put return values back into head and tail
    move $s0, $v0
    move $s1, $v1

    #jump back to top of _while
    j _while

_endloop:
    move $t0, $s0

_print:
    # loop through and print out everything
    # lw $t3, 68($s0)                          # if next is null, end loop, $t1 = head's next
    beq $t0, $0, _closestack

    # print name
    move $a0, $t0
    li $v0, 4
    syscall

    # print space
    la $a0, space
    li $v0, 4
    syscall

    # print ppd (float)
    l.s $f12, 64($t0)
    li $v0, 2
    syscall

    # print new line
    la $a0, newline
    li $v0, 4
    syscall

    lw $t0, 68($t0)     # s0 = s0.next

    j _print

_closestack:
    # CLOSE STACK
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    
    # sets return value for main to be 0 (like return EXIT_SUCCESS)
    li $v0, 0
    jr $ra

.end main 

strcmp:
    # a0 = str1, a1 = str2
    # DON'T FORGET STACK STUFF

_loop:
    # loading first character
    lb $t1, 0($a0)
    lb $t2, 0($a1)

    bgt $t1, $t2, _greater              # branch if greater than
    blt $t1, $t2, _less
    beq $t1, $t2, _true                 # branch if equals

_greater:
    li $v0, -1
    jr $ra

_less:
    li $v0, 1
    jr $ra

_true:
    beqz $t1, _returnequals             # if at the end of the string and they've stayed equal
    addi $a0, $a0, 1
    addi $a1, $a1, 1                    # moving pointer
    j _loop                             # if not at the end keep going and loop again

_returnequals:
    li $v0, 0
    jr $ra

sortlist:
    # a0 = address of newly added "struct"
    # a1 = head
    # a2 = tail

    # t0 = insert
    # t7 = head
    # t8 = tail

    # t1 = temp tracing (1)
    # t6 = temp tracing (2)

    # DON'T NEED THESE STRING THINGS
    # t2 = insert string
    # t3 = head string
    # t4 = tail string

    # f4 = insert ppd
    # f5 = head ppd
    # f6 = tail ppd
    # f7 = temp 2 ppd

    # return head in v0
    # return tail in v1
    # STACK STUFF CHECK IF CORRECT!!!!!

    # check if empty

    move $t0, $a0
    move $t7, $a1
    move $t8, $a2

    beqz $t7, _emptylist

    l.s $f4, 64($t0)     # f4 = insert ppd
    # lw $t2, 0($t0)      # t2 = insert string

    # check if better than head
    l.s $f5, 64($t7)     # f5 = head ppd
        # check if greater than 
    c.le.s $f4, $f5   # check if insert ppd less than or equal to head
    bc1f _betterthanhead    # branch if false
        # check if equal to head and greater alphebetical 
    c.eq.s $f4, $f5, # check if equal
    bc1t _checkalphebeticalhead

    # check if worse than tail
    l.s $f6, 64($t8)     # f6 = tail ppd
        # check if ppd less than 
    c.lt.s $f4, $f6
    bc1t _worsethantail
        # check if equal to tail and worse alphebetical
    c.eq.s $f4, $f6
    bc1t _checkalphebeticaltail

_inserting:
    move $t1, $t7       # t1 = head (1)
    lw $t6, 68($t1)     # t6 = head.next (2)

_gothroughlist:
    l.s $f7, 64($t6)     # f7 = ppd2
    # insert if ppd greater than ppd2
    c.le.s $f4, $f7
    bc1f _insert

    # check if insert ppd = ppd2
    c.eq.s $f4, $f7
    bc1t _checkalphebeticalinsert

    j _tokeeplooping

_checkalphebeticalinsert:
    move $a0, $t0
    move $a1, $t6
    # saving registers to stack 
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $t0, 4($sp)
    sw $t7, 8($sp)
    sw $t8, 12($sp)
    sw $t1, 16($sp)
    sw $t6, 20($sp)
    jal strcmp
    # restoring registers to stack
    lw $ra, 0($sp)
    lw $t0, 4($sp)
    lw $t7, 8($sp)
    lw $t8, 12($sp)
    lw $t1, 16($sp)
    lw $t6, 20($sp)
    addi $sp, $sp, 24
    bgtz $v0, _insert
    j _tokeeplooping

_insert:
    sw $t0, 68($t1)     # one.next = insert
    sw $t6, 68($t0)     # insert.next = two

    # return (head and tail stay the same)
    move $v0, $t7
    move $v1, $t8
    jr $ra

_tokeeplooping:
    move $t1, $t6       # one = two
    lw $t6, 68($t6)     # two = two.next
    j _gothroughlist
    
_emptylist:
    move $v0, $t0
    move $v1, $t0
    j _return

_checkalphebeticalhead:
    move $a0, $t0
    move $a1, $t7

    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $t0, 4($sp)
    sw $t7, 8($sp)
    sw $t8, 12($sp)

    jal strcmp

    # restoring registers to stack
    lw $ra, 0($sp)
    lw $t0, 4($sp)
    lw $t7, 8($sp)
    lw $t8, 12($sp)
    addi $sp, $sp, 16

    bgtz $v0, _betterthanhead
    j _inserting

_checkalphebeticaltail:
    move $a0, $t0
    move $a1, $t8

    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $t0, 4($sp)          # saving registers to stack 
    sw $t7, 8($sp)
    sw $t8, 12($sp)

    jal strcmp

    lw $ra, 0($sp)
    lw $t0, 4($sp)          # restoring registers to stack 
    lw $t7, 8($sp)
    lw $t8, 12($sp)
    addi $sp, $sp, 16

    bltz $v0, _worsethantail
    j _inserting

_betterthanhead:
    move $v0, $t0       # v0 has insert (new head being returned)
    sw $t7, 68($v0)     # insert next = head
    move $v1, $t8       # second return has tail
    jr $ra

_worsethantail:
    sw $t0, 68($t8)     # current tail.next = insert
    move $v1, $t0       # returning new tail as second value
    move $v0, $t7       # first return has head
    jr $ra


_return:
    jr $ra

.data
    prompt_name:        .asciiz "Pizza name:"
    prompt_diameter:    .asciiz "Pizza diameter:"
    prompt_cost:        .asciiz "Pizza cost:"
    newline:            .asciiz "\n"
    space:              .asciiz " "
    buffer:             .space 64
    done:               .asciiz "DONE"
    PI:                 .float 3.14159265358979323846
    quarter:            .float 0.25