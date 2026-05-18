// File: voting_tb.v
`timescale 1ns/1ps

module voting_tb;

    reg clk;
    reg reset;
    reg voter_enable;
    reg raw_btnA;
    reg raw_btnB;
    reg raw_btnC;

    wire flash_write_en;
    wire [3:0] flash_addr;
    wire [7:0] count_A;
    wire [7:0] count_B;
    wire [7:0] count_C;
    wire [6:0] seg_display;

    // Instantiate the upgraded Unit Under Test (UUT)
    digital_voting_machine uut (
        .clk(clk), 
        .reset(reset), 
        .voter_enable(voter_enable),
        .raw_btnA(raw_btnA), 
        .raw_btnB(raw_btnB), 
        .raw_btnC(raw_btnC),
        .flash_write_en(flash_write_en), 
        .flash_addr(flash_addr),
        .count_A(count_A), 
        .count_B(count_B), 
        .count_C(count_C),
        .seg_display(seg_display)
    );

    // Continuous 50MHz master timing oscillator generation (10ns period)
    always #5 clk = ~clk;

    initial begin
        // Setup initial unexcited trace state conditions
        clk = 0; reset = 1; voter_enable = 0;
        raw_btnA = 0; raw_btnB = 0; raw_btnC = 0;
        #20; 
        reset = 0; // Release master reset to start system operations
        
        // --- TESTING APPLIED CONTACT BOUNCE TRANSVERSALS (VOTER 1) ---
        #10; voter_enable = 1; // Admin official clears terminal booth
        
        // Simulate high-frequency mechanical tactile switch contact bounces
        #10; raw_btnA = 1; #5; raw_btnA = 0; #5; raw_btnA = 1; 
        #2000; // Maintain hold to let the debouncer sampling window filter settle
        raw_btnA = 0; voter_enable = 0; // Return terminal to locked state
        
        // --- TESTING APPLIED SELECTION STABILITY (VOTER 2) ---
        #40; voter_enable = 1; // Admin official unlocks booth for next voter
        #10; raw_btnC = 1; // Voter 2 selects Candidate C
        #2000; // Hold steady for debouncer processing window
        raw_btnC = 0; voter_enable = 0;

        #100;
        $finish; // End the simulation run cleanly
    end

endmodule