module decode (
    input  logic        clock,
    input  logic        reset,
    input  logic        activateDecoder,
    input  logic [15:0] dataFetch,
    input  logic [31:0] regbank [0:15],
    output logic [2:0]  opcode,
    output logic [31:0] dataOpa,
    output logic [31:0] dataOpb,
    output logic [3:0]  addrMor
); 

    // --- Decodificação da Instrução (Lógica Combinacional) ---
    // Sinais intermediários que "fatiam" a instrução de entrada.
    logic [2:0] Topcode;
    logic       i;
    logic [3:0] TaddrMor;
    logic [3:0] Topa; 
    logic [3:0] Topb;
    logic [7:0] Timm;

    assign Topcode  = dataFetch[15:13];
    assign i        = dataFetch[12];
    assign TaddrMor = dataFetch[11:8];
    assign Topa     = dataFetch[7:4]; 
    assign Topb     = dataFetch[3:0];
    assign Timm     = dataFetch[7:0];

    always_ff @(posedge clock or negedge reset) begin
        if (!reset) begin
            opcode  <= 0;
            dataOpa <= 0;
            dataOpb <= 0;
            addrMor <= 0;
        end
        else if (activateDecoder) begin
            opcode   <= Topcode;
            dataOpa  <= regbank[Topa];
            addrMor  <= TaddrMor;

            if (i) begin
                dataOpb <= {{24{Timm[7]}}, Timm};
            end
            else begin
                dataOpb <= regbank[Topb];
            end
        end
    end
endmodule

