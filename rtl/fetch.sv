module fetch (
    input clock,
    input reset,
    
    input activateFetch,

    input logic [15:0]  dataIn,

    output logic [7:0]   addr,
    output logic [15:0] dataOut
);

    //Bloquinho PC
    logic [7:0] PC;
    assign addr = PC;

    logic [15:0] barreiraTemp;
    assign dataOut = barreiraTemp;

    //Bloco 
    always_ff @(posedge clock or negedge reset) begin
        if (!reset) begin
            PC <= 0;
            barreiraTemp <= 0;
        end 
        else if (activateFetch) begin
            barreiraTemp <= dataIn;

            PC <= PC + 1;
        end
    end

endmodule