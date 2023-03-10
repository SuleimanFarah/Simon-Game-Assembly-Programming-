.data
players: .zero 50
exitString: .string "Do you want to play again?(1 = Yes/ 0 = No):"
newline_msg: .string "\n"
sequence: .byte 0,0,0,0
numPlayers: .string "How many players are there:"
score: .string "Score: "
player_msg: .string "Player "
turn: .string " Turn"

.globl main
.text

main: #reset all variables
    li t0, 0
    li t1, 4
    li s7, 0 #delay variable
    li s4, 0 #players acc
    
    li a7, 4
    la a0, numPlayers
    ecall
    
    call readInt
    mv s5, a0 #numPlayers
    mul t2, s5, t1
    la s2, players #ENHANCEMENT FEATURE: MULTIPLAYER IS ACTIVE. THE USER WILL DECIDE THE NUMBER OF PLAYERS AT THE START OF THE PROGRAM. THE PROGRAM UPDATES THE ARRAY OF PLAYERS WITH THEIR POINTS EACH TURN. 
    #A ROUND IS RESET WHEN THE PLAYER IS PROMPTED TO PLAY ANOTHER ROUND, A TURN IS OUTPUTTED TO THE CONSOLE AND LOOPS THROUGH THE NUMBER OF PLAYERS UNTIL THEY ALL GET A TURN THEN A ROUND ENDS.
    add t3, s2, t2
    
loop:
    sw t0, 0(s2)
    addi s2, s2, 4
    bne s2, t3, loop
    


 reset:
    li a7, 4 #indicate player turn
    la a0, player_msg
    ecall
    
    mv t1, s4
    addi t1,t1,1
    li a7, 1
    mv a0, t1
    ecall
    
    li a7, 4
    la a0, turn
    ecall
    
    li a7, 4
    la a0, newline_msg
    ecall
    
    li t1, 0
    li t2, 0
    li t3, 0
    li t4, 0
    li t5, 0
    li t6, 0
    li s1, 0
    li s2, 0
    li s3, 0 
    li s6, 0

        
    
    # Initialize LED matrix
    li a0, 0x000000
    li a1, 0
    li a2, 0
    jal setLED

    
    li a0, 0x000000
    li a1, 0
    li a2, 1
    jal setLED
    
    li a0, 0x000000
    li a1, 1
    li a2, 0
    jal setLED
    
    li a0, 0x000000
    li a1, 1
    li a2, 1
    jal setLED
    # Before we deal with the LEDs, we need to generate a random
    # sequence of numbers that we will use to indicate the button/LED
    # to light up. For example, we can have 0 for UP, 1 for DOWN, 2 for
    # LEFT, and 3 for RIGHT. Store the sequence in memory. 
    # We use the psuedo-random function provided to generate each number
 
 
    li t6, 0 #accumulator
    li s6, 4
    la t3, sequence
randLoop:
    bne t6, s6, else
    j endLoop
else:
    li a0, 4
    addi sp, sp, -4
    sw a0, 0(sp)
    jal rand
    lw ra, 0(sp)
    addi sp, sp, 4
    addi t3, t3, 1
    sb ra, 0(t3)
    addi t6, t6, 1
    j randLoop
endLoop:
    
    # Read the sequence and replay it on the LEDs. You will
    # need to use the delay function to ensure that the LEDs light up 
    # slowly. In general, for each number in the sequence you should:
    # 1. Figure out the corresponding LED location and colour
    # 2. Light up the appropriate LED (with the colour)
    # 2. Wait for a short delay (e.g. 500 ms)
    # 3. Turn off the LED (i.e. set it to black)
    # 4. Wait for a short delay (e.g. 1000 ms) before repeating
    
    li t6, 0
    addi t3, t3, -3
displayLEDS:
    beq t6, s6, endDisplay
    lbu t5, 0(t3)
    addi t6, t6, 1
    addi t3, t3, 1

    li t1, 1
    li t4, 2
    li s3, 3
    li t0, 0
    switch:
        beq t5, t0, up
        beq t5, t1, down
        beq t5, t4, left
        beq t5, s3, right
        j endSwitch
    up: #0
        li a0, 0xFF0000 #red
        li a1, 0
        li a2, 0
        jal setLED
        li a0, 500 #short delay
        sub a0, a0, s7 #ENHANCEMENT FEATURE: INCREASE SPEED PER ROUND BY REDUCING DELAY TIME, THE AMOUNT OF TIME REDUCTION IS STORED IN S7
        jal delay
        j endSwitch
    down: #1
        li a0, 0x00FF00 #green
        li a1, 1
        li a2, 0
        jal setLED
        li a0, 500 #short delay
        sub a0, a0, s7
        jal delay
        j endSwitch
    right: #3
        li a0, 0x0000FF #blue
        li a1, 1
        li a2, 1
        jal setLED
        li a0, 500 #short delay
        sub a0, a0, s7
        jal delay
        j endSwitch
    left: #2
        li a0, 0xFFFFFF #white
        li a1, 0
        li a2, 1
        jal setLED
        li a0, 500 #short delay 
        sub a0, a0, s7
        jal delay 
        j endSwitch
    endSwitch: #reset back to black, delay, and then go back to main loop
        li a0, 0x000000
        li a1, 1
        li a2, 0
        jal setLED
        li a0, 0x000000
        li a1, 1
        li a2, 1
        jal setLED
        li a0, 0x000000
        li a1, 0
        li a2, 0
        jal setLED
        li a0, 0x000000
        li a1, 0
        li a2, 1
        jal setLED
        
        li a0, 1000 #longer delay 1000
        sub a0, a0, s7
        jal delay
        j displayLEDS
        
endDisplay:   

    
    # Read through the sequence again and check for user input
    # using pollDpad. For each number in the sequence, check the d-pad
    # input and compare it against the sequence. If the input does not
    # match, display some indication of error on the LEDs and exit. 
    # Otherwise, keep checking the rest of the sequence and display 
    # some indication of success once you reach the end.
    addi t3, t3, -4
    li t6, 0
dPadLoop:
    beq t6, s6, endDpad
    lbu t5, 0(t3)
    addi t6, t6, 1
    addi t3, t3, 1

    jal pollDpad
    li t0, 0
    li t1, 1
    li t4, 2
     dPadReturn:
        beq t5, a0, correctLight
        j incorrectLight
correctLight: #turn green then black after a pause
    li a0, 0x00FF00
    li a1, 0
    li a2, 0
    jal setLED

    li a0, 0x00FF00
    li a1, 0
    li a2, 1
    jal setLED
    
    li a0, 0x00FF00
    li a1, 1
    li a2, 0
    jal setLED
    
    li a0, 0x00FF00
    li a1, 1
    li a2, 1
    jal setLED
    
    
    li a0, 500
    jal delay
    #turning black
    li a0, 0x000000
    li a1, 0
    li a2, 0
    jal setLED

    li a0, 0x000000
    li a1, 0
    li a2, 1
    jal setLED
    
    li a0, 0x000000
    li a1, 1
    li a2, 0
    jal setLED
    
    li a0, 0x000000
    li a1, 1
    li a2, 1
    jal setLED 
    
    li a0, 500
    jal delay
    li t2, 4
    li s2, 1
    j dPadLoop
incorrectLight:
    # Initialize LED matrix
    li a0, 0xFF0000
    li a1, 0
    li a2, 0
    jal setLED

    
    li a0, 0xFF0000
    li a1, 0
    li a2, 1
    jal setLED
    
    li a0, 0xFF0000
    li a1, 1
    li a2, 0
    jal setLED
    
    li a0, 0xFF0000
    li a1, 1
    li a2, 1
    jal setLED
    
    li a0, 500
    jal delay
    
    #turning black
    li a0, 0x000000
    li a1, 0
    li a2, 0
    jal setLED

    li a0, 0x000000
    li a1, 0
    li a2, 1
    jal setLED
    
    li a0, 0x000000
    li a1, 1
    li a2, 0
    jal setLED
    
    li a0, 0x000000
    li a1, 1
    li a2, 1
    jal setLED 
    
    li a0, 500
    jal delay
    
    li s2, 0
    j endDpad
endDpad:
    # TODO: Ask if the user wishes to play again and either loop back to
    # start a new round or terminate, based on their input.

    
    li a7, 4
    la a0, newline_msg
    ecall
    
    addi s7, s7, 20 #delay variable
    jal incrementScore
    jal printScore

    bne s4, s5, reset
    li s4, 0
    li t1,1
    
    la a0, newline_msg   
    li a7, 4           
    ecall
    li a0, 0
    la a0, exitString
    li a7, 4
    ecall

    call readInt
    mv t2, a0
    beq t2, t1, reset

exit:
    li a7, 10
    ecall
    
    
# --- HELPER FUNCTIONS ---
incrementScore:
    li t0, 4
    mul t0, t0, s4
    li t1, 0
    la t3, players #load player array
    add t3, t3, t0 #get to the appropriate address aka player index
    lw t2, 0(t3) #load the player score from that address
    
    add t2, t2, s2 #add the player score with the current round state (win = 1, loss = 0)
    sw t2, 0(t3) #store the value back at that address at the player array

    addi s4, s4, 1 #change to the next player
    jr ra

printScore:
    li t6, 0      # initialize accumulator
    la t1, players # address of start of array
    
    print_loop:
        beq t6, s5, exit_print  # exit loop when all players have printed
        addi t6, t6, 1        # increment accumulator
        mv a1, t6             # set argument to player number
        li a7, 4
        la a0, score
        ecall
        
        li a7, 4
        la a0, newline_msg
        ecall
        
        li a7, 4              # set system call for print string
        la a0, player_msg     # load message for printing
        ecall
        mv a0, a1
        li a7, 1 #print player number
        ecall
        
        li a7, 4
        la a0, newline_msg #put a space between score and player identification
        ecall
        
        lw t4, 0(t1)         # load player score
        addi t1, t1, 4        # increment player score pointer
        mv a0, t4             # set argument to player score
        li a7, 1              # set system call for print integer
        ecall
        la a0, newline_msg    # load message for printing newline
        li a7, 4              # set system call for print string
        ecall
        j print_loop
    exit_print:
        jr ra
     
# Takes in the number of milliseconds to wait (in a0) before returning
delay:
    mv t0, a0
    li a7, 30
    ecall
    mv t1, a0
delayLoop:
    ecall
    sub t2, a0, t1
    bgez t2, delayIfEnd
    addi t2, t2, -1
delayIfEnd:
    bltu t2, t0, delayLoop
    jr ra

# Takes in a number in a0, and returns a (sort of) random number from 0 to
# this number (exclusive)
rand:
    mv t0, a0
    li a7, 30
    ecall
    remu a0, a0, t0
    addi sp, sp, -4
    sw a0, 0(sp)
    jr ra

    
# Takes in an RGB color in a0, an x-coordinate in a1, and a y-coordinate
# in a2. Then it sets the led at (x, y) to the given color.
setLED:
    li t1, LED_MATRIX_0_WIDTH
    mul t0, a2, t1
    add t0, t0, a1
    li t1, 4
    mul t0, t0, t1
    li t1, LED_MATRIX_0_BASE
    add t0, t1, t0
    sw a0, 0(t0)
    jr ra
    
# Polls the d-pad input until a button is pressed, then returns a number
# representing the button that was pressed in a0.
# The possible return values are:
# 0: UP
# 1: DOWN
# 2: LEFT
# 3: RIGHT
pollDpad:
    mv a0, zero
    li t1, 4
pollLoop:
    bge a0, t1, pollLoopEnd
    li t2, D_PAD_0_BASE
    slli t4, a0, 2
    add t2, t2, t4
    lw t4, (0)t2
    bnez t4, pollRelease
    addi a0, a0, 1
    j pollLoop
pollLoopEnd:
    j pollDpad
pollRelease:
    lw t4, (0)t2
    bnez t4, pollRelease
pollExit:
    jr ra

readInt:
    addi sp, sp, -12
    li a0, 0
    mv a1, sp
    li a2, 12
    li a7, 63
    ecall
    li a1, 1
    add a2, sp, a0
    addi a2, a2, -2
    mv a0, zero
parse:
    blt a2, sp, parseEnd
    lb a7, 0(a2)
    addi a7, a7, -48
    li a3, 9
    bltu a3, a7, error
    mul a7, a7, a1
    add a0, a0, a7
    li a3, 10
    mul a1, a1, a3
    addi a2, a2, -1
    j parse
parseEnd:
    addi sp, sp, 12
    ret

error:
    li a7, 93
    li a0, 1
    ecall