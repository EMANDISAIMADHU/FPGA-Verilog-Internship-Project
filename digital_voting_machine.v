// File: digital_voting_machine.v
module digital_voting_machine (
    input wire clk,              // Master high-frequency onboard clock input (50MHz)
    input wire reset,            // Master clear baseline reset line (Active-High)
    input wire voter_enable,     // Administrative activation switch managed by poll officer
    input wire raw_btnA,         // Raw mechanical switch line from Candidate A button
    input wire raw_btnB,         // Raw mechanical switch line from Candidate B button
    input wire raw_btnC,         // Raw mechanical switch line from Candidate C button
    
    output reg flash_write_en,   // Command strobe output line to external Flash/EEPROM
    output reg [3:0] flash_addr, // 4-bit memory block sector allocation target address
    output reg [7:0] count_A,    // Secure internal tally register array for Candidate A
    output reg [7:0] count_B,    // Secure internal tally register array for Candidate B
    output reg [7:0] count_C,    // Secure internal tally register array for Candidate C
    output reg [6:0] seg_display // 7-Segment cathode active configuration control vector
);

    // Operational FSM State Space Encoding
    parameter IDLE         = 2'b00;
    parameter WAIT_VOTE    = 2'b01;
    parameter UPDATE_TALLY = 2'b10;
    parameter COM_FLASH    = 2'b11;

    reg [1:0] current_state, next_state;
    reg [2:0] vote_registered;

    // ----------------------------------------------------------------
    // SECTION 1: TACTILE SWITCH DIGITAL DEBOUNCING FILTER ENGINE
    // ----------------------------------------------------------------
    reg [15:0] debounce_div;
    reg sample_clk;
    reg stable_btnA, stable_btnB, stable_btnC;

    // Clock divider process creating a stable low-frequency sampling clock
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            debounce_div <= 16'd0;
            sample_clk   <= 1'b0;
        end else begin
            if (debounce_div == 16'd50000) begin 
                debounce_div <= 16'd0;
                sample_clk   <= ~sample_clk; // Toggle low-frequency sample pulse
            end else begin
                debounce_div <= debounce_div + 1'b1;
            end
        end
    end

    // Input sampling block to filter out mechanical contact bounce noise
    always @(posedge sample_clk or posedge reset) begin
        if (reset) begin
            stable_btnA <= 1'b0;
            stable_btnB <= 1'b0;
            stable_btnC <= 1'b0;
        end else begin
            stable_btnA <= raw_btnA; // Capture logic values only after line bounces settle
            stable_btnB <= raw_btnB;
            stable_btnC <= raw_btnC;
        end
    end

    // ----------------------------------------------------------------
    // SECTION 2: SYNCHRONOUS FSM CENTRAL CORE & DATA BUS ROUTING
    // ----------------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state  <= IDLE;
            count_A        <= 8'd0;
            count_B        <= 8'd0;
            count_C        <= 8'd0;
            flash_write_en <= 1'b0;
            flash_addr     <= 4'b0000;
        end else begin
            current_state <= next_state;
            
            // Accumulate choices within the secure update phase
            if (current_state == UPDATE_TALLY) begin
                case (vote_registered)
                    3'b001: count_A <= count_A + 1'b1;
                    3'b010: count_B <= count_B + 1'b1;
                    3'b100: count_C <= count_C + 1'b1;
                endcase
            end
            
            // Assert secure memory storage interface triggers inside COM_FLASH
            if (current_state == COM_FLASH) begin
                flash_write_en <= 1'b1;
                flash_addr     <= 4'b1010; // Target designated non-volatile memory block sector
            end else begin
                flash_write_en <= 1'b0;
            end
        end
    end

    // FSM Next-State combinational evaluation pathways
    always @(*) begin
        case (current_state)
            IDLE: begin
                next_state = voter_enable ? WAIT_VOTE : IDLE;
            end
            WAIT_VOTE: begin
                next_state = (stable_btnA || stable_btnB || stable_btnC) ? UPDATE_TALLY : WAIT_VOTE;
            end
            UPDATE_TALLY: begin
                next_state = COM_FLASH; // Auto-advance to trigger secure flash write cycle
            end
            COM_FLASH: begin
                next_state = IDLE; // Automatic lockdown sequence execution
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Buffer to safely register and hold voter selections
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            vote_registered <= 3'b000;
        end else if (current_state == WAIT_VOTE) begin
            if (stable_btnA)      vote_registered <= 3'b001;
            else if (stable_btnB) vote_registered <= 3'b010;
            else if (stable_btnC) vote_registered <= 3'b100;
        end else if (current_state == IDLE) begin
            vote_registered <= 3'b000;
        end
    end

    // ----------------------------------------------------------------
    // SECTION 3: 7-SEGMENT DISPLAY HARDWARE GENERATOR MATRIX DECODER
    // ----------------------------------------------------------------
    wire [3:0] total_votes = count_A + count_B + count_C;
    always @(*) begin
        case (total_votes)
            4'h0: seg_display = 7'b1000000; // Binary 0 -> Displays '0'
            4'h1: seg_display = 7'b1111001; // Binary 1 -> Displays '1'
            4'h2: seg_display = 7'b0100100; // Binary 2 -> Displays '2'
            4'h3: seg_display = 7'b0110000; // Binary 3 -> Displays '3'
            4'h4: seg_display = 7'b0011001; // Binary 4 -> Displays '4'
            default: seg_display = 7'b1111111; // Off / Error Condition
        endcase
    end

endmodule