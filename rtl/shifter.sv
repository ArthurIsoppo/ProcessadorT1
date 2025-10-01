module shifter #(parameter REG_WIDTH=32) (
    input  logic sin,
    input  logic [REG_WIDTH-1:0] op_a,
    output logic [REG_WIDTH-1:0] result,
    output logic sout,
    input  logic [4:0] nbits,
    input  logic [2:0] mode
);

always_comb begin
    result = '0;
    sout = 1'b0;
    unique case (mode)
        3'b000: begin // shift lógico à esquerda
            result = op_a << nbits;
            if (nbits > 0 && nbits <= REG_WIDTH)
                sout = op_a[REG_WIDTH - nbits];
            else
                sout = 1'b0;
        end
        3'b001: begin // shift lógico à direita
            result = op_a >> nbits;
            if (nbits > 0 && nbits <= REG_WIDTH)
                sout = op_a[nbits-1];
            else
                sout = 1'b0;
        end
        3'b010: begin // shift aritmético à direita
            result = $signed(op_a) >>> nbits;
            if (nbits > 0 && nbits <= REG_WIDTH)
                sout = op_a[nbits-1];
            else
                sout = 1'b0;
        end
        default: begin
            result = op_a;
            sout = 1'b0;
        end
    endcase
end

endmodule: shifter
