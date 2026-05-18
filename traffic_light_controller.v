module traffic_light_controller(
    input wire clk,
    input wire reset,
    input wire emergency,
    output reg red,
    output reg yellow,
    output reg green
);

    parameter RED_STATE       = 2'b00;
    parameter GREEN_STATE     = 2'b01;
    parameter YELLOW_STATE    = 2'b10;
    parameter EMERGENCY_STATE = 2'b11;

    reg [1:0] current_state, next_state;

    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= RED_STATE;
        else
            current_state <= next_state;
    end

    always @(*) begin
        case (current_state)
            RED_STATE:       next_state = emergency ? EMERGENCY_STATE : GREEN_STATE;
            GREEN_STATE:     next_state = emergency ? EMERGENCY_STATE : YELLOW_STATE;
            YELLOW_STATE:    next_state = emergency ? EMERGENCY_STATE : RED_STATE;
            EMERGENCY_STATE: next_state = emergency ? EMERGENCY_STATE : RED_STATE;
            default:         next_state = RED_STATE;
        endcase
    end

    always @(*) begin
        case (current_state)
            RED_STATE:       begin red = 1; yellow = 0; green = 0; end
            GREEN_STATE:     begin red = 0; yellow = 0; green = 1; end
            YELLOW_STATE:    begin red = 0; yellow = 1; green = 0; end
            EMERGENCY_STATE: begin red = 0; yellow = 0; green = 1; end
            default:         begin red = 1; yellow = 0; green = 0; end
        endcase
    end
endmodule