#####################################################
#          A MIPS program which simulates           #
#     how RISC architectures perform division       #
#####################################################

#DATA SEGMENT___________________________________________________________________
  .data

#Declare strings in memory
  Prompt1: .asciiz "Enter in a Divisor (1-7): "
  Prompt2: .asciiz "Enter a Numerator (>= Divisor, 1-7): "
  TryAgain:  .asciiz "Invalid Entry. Please try again: "
  Column: .asciiz "     Step         Quotient     Divisor  Remainder\n"
  Initial: .asciiz "Initial Values   \t"
  Step_1: .asciiz "Rem=Rem-Div      \t"
  Step_2A: .asciiz "2a: Quotient to 1  \t"
  Step_2B: .asciiz "2b: Restore Rem  \t"
  Step_3: .asciiz "Shift Div Right  \t"
  Tab: .asciiz "\t"
  DoubleSpace: .asciiz "  "
  NL:     .asciiz "\n"

  .align 2

#TEXT SEGMENT___________________________________________________________________
  .text
  .globl main

main:

#DIVISOR PROMPT_________________________________________________________________
  li $v0, 4                     #Change syscall to print string
  la $a0, Prompt1               #Load address of Prompt1 string
  syscall                       #Print to console

  li $t0, 1                     #Lower limit for divisor in $t0
  li $t1, 7                     #Upper limit for divisor in $t1

Input:
  li $v0, 5                     #Change syscall to read int
  syscall                       #Read int
  move $s0, $v0                 #DIVISOR in $s0
  move $a0, $s0                 #FUNCTION ARGUMENT
  jal Check                     #JUMP AND LINK CHECK FUNCTION
  move $t2, $v0                 #RETURN VALUE
  move $t3, $v1                 #RETURN VALUE
  bgtz $t2, Error               #If $t2 = 1, branch to Error
  bgtz $t3, Error               #If $t3 = 1, branch to Error
  j Continue                    #Otherwise, check is good; jump to Continue

Error:
  li $v0, 4                     #Change syscall to print string
  la $a0, TryAgain              #Load address of Error string
  syscall                       #Print to console
  j Input

#NUMERATOR PROMPT_______________________________________________________________
Continue:
  li $v0, 4                     #Change syscall to print string
  la $a0, Prompt2               #Load address of Prompt2 string
  syscall                       #Print to console

Input2:
  li $v0, 5                     #Change syscall to read int
  syscall                       #Read int
  move $s1, $v0                 #NUMERATOR in $s1

#NUMERATOR CHECK________________________________________________________________
  blt $s1, $s0, Error2          #If NUMERATOR < DIVISOR, try again
  bgt $s1, $t1, Error2          #If NUMERATOR > 7, try again
  j Continue2                   #If input it valid, jump to Continue2

Error2:
  li $v0, 4                     #Change syscall to print string
  la $a0, TryAgain              #Load address of Error string
  syscall                       #Print to console
  j Input2

#DIVISION CHART_________________________________________________________________
Continue2:
  li $v0, 4                     #Change syscall to print string
  la $a0, Column                #Load address of Column string
  syscall                       #Print to console
  la $a0, Initial               #Load address of Initial string
  syscall                       #Print to console


#DECLARE INITIAL VARIABLES______________________________________________________
  li $t0, 16
  mul $s0, $s0, $t0             #SHIFT DIVISOR left 4 binary (mul by 16) before start

  li $t0, 2                     #Load 2 into $t0, used for binary conversion
  li $t1, 1                     #load 1 into $t1, used in binary conversion
    #$t4 used to temporarily store counter at times
  li $t6, 3                     #Load 3 into $t6, used in PrintDiv2
  li $t7, 4                     #load 4 into $t7, used in binary print
  li $t8, 0                     #TOBINARY_COUNTER = 0 (stack pointer counter)
  li $t9, 8                     #load 8 into $t8, used in remainder print
  li $s2, 0                     #QUOTIENT = 0
  li $s3, 0                     #ITERATION = 0
  li $s5, 0                     #STEP = 0, will increment 1-3, then restart at 1
  li $s6, 5                     #Set to 5 to check for final iteration!
    #$s7 used to store old remainder, in case it needs to be reinstated

#**Some temp variables used in other facets, but saved registers stay consistent
#  with their uses throughout!**

#CALCULATIONS AND PRINT LOOP____________________________________________________

#__________________________________QUOTIENT_____________________________________
PrintQuo:
  beq $s2, $zero, Zero          #If quotient=0, skip to Zero
  move $a0, $s2                 #$a0 is func argument for binary conversion
  jal ToBinary                  #Convert quotient to binary, FUNCTION
  move $t8, $v0                 #ToBinary RETURN VALUE, move counter into $t8

  move $t4, $t8                 #ALSO store COUNTER in $t4, to preserve it in $t8
PrintQuo1:                      #####PRINT#####
  beq $t4, $t7, PrintQuo2       #If 4 digits in stack pointer, jump to Print
                                #OTHERWISE, print appropriate # of 0s first
  li $v0, 1
  move $a0, $zero
  syscall                       #Print zero
  addi $t4, 1                   #$t4++
  j PrintQuo1                   #Repeat

PrintQuo2:
  move $a1, $t8                 #FUNC ARGUMENT (stack pointer COUNTER)
  jal PrintBinary               #Print binary off stack
  move $t8, $v0                 #FUNC RETURN VALUE (COUNTER, which should be 0)
  j Format                      #Jump to Format to tab after quotient

Zero:
  move $a1, $t7                 #Print0 FUNCTION ARGUMENT, move 4 into it
  jal Print0                    #Shortcut to print quotient of 0000, FUNCTION

Format:
  li $v0, 4                     #Change syscall to print string
  la $a0, Tab                   #Load address of Tab string
  syscall                       #Print to console

#____________________________________DIVISOR____________________________________
Divisor:
  move $a0, $s0                 #$a0 is argument for binary conversion
  jal ToBinary                  #Convert divisor to binary, FUNC
  move $t8, $v0                 #ToBinary RETURN VALUE, move counter into $t8

  move $t4, $t8                 #ALSO store COUNTER in $t4, to preserve it in $t8
PrintDiv1:                      #####PRINT#####
  beq $t4, $t9, PrintDiv2       #If eight digits in stack pointer, jump to Print
                                #OTHERWISE, print appropriate # of 0s first
  li $v0, 1
  move $a0, $zero
  syscall                       #Print zero
  addi $t4, 1                   #$t4++
  j PrintDiv1                   #Repeat

PrintDiv2:
  move $a1, $t8                 #FUNC ARGUMENT (stack pointer COUNTER)
  jal PrintBinary               #Print binary off stack
  move $t8, $v0                 #FUNC RETURN VALUE (COUNTER, which should be 0)


Format2:
  li $v0, 4                     #Change syscall to print string
  la $a0, DoubleSpace           #Load address of DoubleSpace string
  syscall                       #Print to console

#___________________________________REMAINDER___________________________________
Rem:
  move $a0, $s1                 #$a0 is FUNCTION ARGUMENT for ToBinary
  bltz $s1, Neg
  j Pos

Neg:
  li $t2, -1                    #Load -1 into $t2
  mul $a0, $a0, $t2             #Make neg int positive before entering ToBinaryNeg
  j ToBinaryNeg

Neg2:
  move $t4, $t8                 #Temporarily store COUNTER in $t4, to preserve it in $t8
PrintRemNeg:                       #####PRINT#####

  beq $t4, $t9, PrintRem2       #If eight digits in stack pointer, jump to Print
                                #OTHERWISE, print appropriate # of 1s first

  li $v0, 1
  move $a0, $t1
  syscall                       #Print zero
  addi $t4, 1                   #$t4++
  j PrintRemNeg                 #Repeat

Pos:
  jal ToBinary                  #FUNCTION CALL, func argument right after Rem
  move $t8, $v0                 #ToBinary RETURN VALUE, move counter into $t8

  move $t4, $t8                 #Temporarily store COUNTER in $t4, to preserve it in $t8
PrintRem:                       #####PRINT#####

  beq $t4, $t9, PrintRem2       #If eight digits in stack pointer, jump to Print
                                #OTHERWISE, print appropriate # of 0s first

  li $v0, 1
  move $a0, $zero
  syscall                       #Print zero
  addi $t4, 1                   #$t4++
  j PrintRem                    #Repeat

PrintRem2:
  move $a1, $t8                 #FUNC ARGUMENT (stack pointer COUNTER)
  jal PrintBinary               #Print binary off stack
  move $t8, $v0                 #FUNC RETURN VALUE (COUNTER, which should be 0)
  beq $s3, $s6, End             #If final iteration is reached, jump to End

Format3:
  li $v0, 4                     #Change syscall to print string
  la $a0, NL                    #Load address of NL string
  syscall                       #Print to console

WhichStep:
  beq $s5, $t6, Step            #If STEP = 3, branch to Step
  addi $s5, 1                   #Otherwise, STEP++
  beq $s5, $t1, Step1           #If STEP = 1, branch to Step1
  beq $s5, $t0, Step2           #If STEP = 2, branch to Step2
  j Step3

#STEP IN DIVISION TABLE_________________________________________________________

Step:
  li $s5, 1                     #Reset STEP to 1 after STEP 3

Step1:
  addi $s3, $s3, 1              #ITERATION++
  move $s7, $s1                 #Store old remainder into $s7
  sub $s1, $s1, $s0             #REM = REM - DIV
  li $v0, 4                     #Change syscall to print string
  la $a0, Step_1                #Load address of Step_1 string
  syscall                       #Print to console
  j PrintQuo                    ####RESTART LOOP####

Step2:
  bltz $s1, Step2_2
  li $v0, 4                     #Change syscall to print string
  la $a0, Step_2A               #Load address of Step_2A string
  syscall                       #Print to console

  #SHIFT QUOTIENT TO LEFT 1 BIT AND PLACE 1 IN RIGHT MOST BIT
  beq $s2, $zero, Step2_1       #If quotient is still 0, branch to Step2_1
  mul $s2, $s2, $t0             #Otherwise, mul quotient by 2
  addi $s2, $s2, 1              #Then add 1
  j PrintQuo                    ####RESTART LOOP####

Step2_1:
  li $s2, 1                     #If first time updating quotient, set to 1
  j PrintQuo                    ####RESTART LOOP####

Step2_2:
  li $v0, 4                     #Change syscall to print string
  la $a0, Step_2B               #Load address of Step_2B string
  syscall                       #Print to console
  move $s1, $s7                 #Reinstate old remainder
  #SHIFT QUOTIENT TO LEFT 1 BIT AND PLACE 0 IN RIGHT MOST BIT
  mul $s2, $s2, $t0
  j PrintQuo                    ####RESTART LOOP####

Step3:
  li $v0, 4                     #Change syscall to print string
  la $a0, Step_3                #Load address of Step_2B string
  syscall                       #Print to console
  div $s0, $t0                  #Shift divisor right one bit
  mflo $s0                      #Quotient stored in $s0
  j PrintQuo                    ####RESTART LOOP####

#END____________________________________________________________________________

End:
  beq $s5, $t1, Format3         #Not quite the end, but almost!! If on last
  beq $s5, $t0, Format3         #iteration, but only on STEP 1 or 2,
                                #branch back to Format3
  li $v0, 10                    #Change syscall to terminate execution
  syscall                       #Exit


#___________________________________FUNCTIONS___________________________________

                                #Pass in DIVISOR through $a0
                                #Previously declared $t0 = 1, $t1 = 7
                                #TWO RETURN VALUES in $v0, $v1
Check:
  slt $v0, $a0, $t0             #If DIVISOR < 1, $v0 = 1 (RETURN VALUE)
                                #Otherwise, $v0 = 0 (RETURN VALUE)
  sgt $v1, $a0, $t1             #If DIVISOR > 7, $v1 = 1 (RETURN VALUE)
                                #Otherwise, $v1 = 0 (RETURN VALUE)
  jr $ra                        #jump to return address


                                #$a0 = FUNCTION ARGUMENT, decimal being converted
                                #BINARY OF THIS ARGUMENT STORED IN STACK
                                #$v0 = STACK COUNTER, RETURN VALUE

ToBinary:
  addi $sp, -4                  #Subtract 4 from stack pointer
  div $a0, $t0                  #Divide input by 2
  mfhi $t5                      #Remainder stored in $t5
  mflo $a0                      #Quotient stored in $t4
  sw $t5, 0($sp)                #Store remainder at top of stack
  addi $t8, 1                   #COUNTER++ ($t8 set to 0 earlier in code)
  bgtz $a0, ToBinary            #If quotient > 0, done converting to binary
  move $v0, $t8                 #RETURN COUNTER IN $v0
  jr $ra                        #jump to return address


                                #Mul $t4 by -1 BEFORE jumping here
                                #### NOT A FUNCTION!!! ####
                                #
                                #Converts to positive binary first, then flips
                                #bits, then adds 1
ToBinaryNeg:
  jal ToBinary                  #Converts to positive version of binary
  move $t8, $v0                 #ToBinary RETURN VALUE, move counter into $t8
  move $t2, $t8                 #Store COUNTER ($t8) in $t2
  move $t3, $sp                 #Store $sp into $t3 to restore later
Flip1:
  lw $t5, 0($sp)                #Load top of stack
  beq $t5, $t1, Flip2           #If $t5 = 1, branch to Flip2
  li $t5, 1                     #Switch "bit"
  sw $t5, 0($sp)                #Store switched "bit" back on stack pointer
  j Flip3
Flip2:
  li $t5, 0                     #Switch "bit"
  sw $t5, 0($sp)                #Store switched "bit" back on stack pointer
Flip3:
  beq $t2, $zero, Add1
  addi $sp, 4                   #Going back up the stack, WILL RESTORE AFTERWARD
  addi $t2, -1                  #Decrement COUNTER
  bgtz $t2, Flip1
Add1:                           #Now that all bits are flipped, need to add 1
  addi $sp, -4
Add1_2:
  lw $t5, 0($sp)                #Load BOTTOM of stack
  beq $t5, $zero, Add1_3        #If $t5 = 0, branch to Add1_2
  move $t5, $0                  #Load 0 into $t5
  sw $t5, 0($sp)                #Store 0 "bit" at current stack pointer
  addi $sp, -4                  #Subtract 4 from stack pointer, moving up stack
  j Add1_2                      #Jump back to Add1_2
Add1_3:
  move $t5, $t1                 #Load 1 into $t5
  sw $t5, 0($sp)                #Store 1 "bit" at current stack pointer
Done:
  move $sp, $t3                 #Restore stack pointer, DONE
  j Neg2                        #Jump back to Neg2 in code (in REMAINDER section)



                                #Prints binary stored on the stack from ToBinary
                                #Pass in COUNTER through $a1 ($a0 used in printing)
                                #RETURN COUNTER in $v0 (should be 0, used to check
                                #                        if this works properly)
                                #Assumes $sp is at top of stack
PrintBinary:
  lw $t5, 0($sp)                #load top of stack pointer to $t5
  li $v0, 1
  move $a0, $t5
  syscall                       #Print top of stack pointer
  addi $sp, 4                   #Add 4 to stack pointer
  addi $a1, -1                  #COUNTER--
  bgtz $a1, PrintBinary         #If COUNTER > 0, repeat
  move $v0, $a1                 #RETURN COUNTER (should be 0 if working properly)
  jr $ra                        #Return to code

                                #Pass in $a1 number of 0s you want to print
                                #Don't use $a0 bc that is used in printing
                                #NO RETURN VALUE
Print0:
  li $v0, 1
  move $a0, $zero
  syscall                       #Prints a 0
  addi $a1, -1                  #$a1--
  bgtz $a1, Print0              #If $s0, is greater than 0, loop back to top
  jr $ra                        #Return to code
