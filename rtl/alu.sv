module alu (
    input logic clock,
    input logic reset,
    
    input  logic nss,
    input  logic sclk,
    input  logic mosi,
    output logic miso
);
    typedef enum logic [2:0] { 
        IDLE     = 3'b001,
        RECEIVE  = 3'b010,
        THINK    = 3'b011,
        WAIT     = 3'b100,
        SEND     = 3'b101
    } alu_state_t;
    alu_state_t state, next_state; 

    logic [2:0]  opcode;
    logic [31:0] opa;
    logic [31:0] opb;
    logic [31:0] res;

    logic [66:0] buffer;
    logic [6:0]  counter;

    always_ff @(posedge clock or negedge reset) begin
        if (!reset) state <= IDLE;
        else        state <= next_state;
    end

    always_ff @(posedge clock or negedge reset) begin
        if (!reset) begin
            next_state <= IDLE;
            counter <= 0;
            miso <= 1'b0;
            buffer <= 0;
            res <= 0;
        end else begin
            unique case (state)
                IDLE: begin
                    counter <= 0;
                    if(~nss) begin
                        next_state <= RECEIVE;
                    end else begin
                        next_state <= IDLE;
                    end
                end

                RECEIVE: begin
                    buffer[66 - counter] <= mosi;
                    counter <= counter + 1;
                    if (counter == 67) begin
                        next_state <= THINK;
                    end else begin
                        next_state <= RECEIVE;
                    end
                end

                THINK: begin
                    opcode <= buffer[66:64];
                    opa    <= buffer[63:32];
                    opb    <= buffer[31:0];
                    
                    case (opcode)
                        3'b000: res <= opa + opb; // ADD
                        3'b001: res <= opa & opb; // AND
                        3'b010: res <= opa | opb; // OR
                        default: res <= 32'h0;
                    endcase

                    counter <= 0;
                    next_state <= WAIT;
                end

                WAIT: begin
                    if (~nss) begin
                        next_state <= SEND;
                    end else begin
                        next_state <= WAIT;
                    end
                end

                SEND: begin
                    miso <= res[31 - counter];
                    counter <= counter + 1;
                    if (counter == 32) begin
                        next_state <= IDLE;
                    end else begin
                        next_state <= SEND;
                    end
                end
            endcase
        end
    end
endmodule