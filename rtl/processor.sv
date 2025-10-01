module processor (
    input  logic        clock,
    input  logic        reset,

    output logic [7:0]  memAddr,
    input  logic [15:0] memDataIn,

    IF_SPI.MASTER spi
);

    typedef enum { FETCH, DECODE, EXECUTE, WRITE_BACK } processorState_t;
    processorState_t state, nextState;

    always_ff @(posedge clock or negedge reset) begin
        if (!reset) state <= FETCH;
        else        state <= nextState;
    end

    always_ff @(posedge clock or negedge reset) begin
        if (!reset) begin
            nextState <= FETCH;
        end else begin
            case(state)
                FETCH:      nextState <= DECODE;
                DECODE:     nextState <= EXECUTE;
                EXECUTE:    nextState <= WRITE_BACK;
                WRITE_BACK: nextState <= FETCH;
                default:    nextState <= FETCH;
            endcase
        end
    end

    logic activateFetch  = (state == FETCH);
    logic activateDecode = (state == DECODE);
    logic activateExecute = (state == EXECUTE);
    logic activateWb     = (state == WRITE_BACK);
    
    logic [31:0] regbank [0:15];
    
    logic        wbEn;
    logic [3:0]  wbAddr;
    logic [31:0] wbData;

    always_ff @(posedge clock) begin
        if (wbEn) begin
            regbank[wbAddr] <= wbData;
        end
    end

    // Saída do Fetch -> Entrada do Decode
    logic [15:0] fetchInstruction;

    // Saída do Decode -> Entrada do Execute
    logic [2:0]  decOpcode;
    logic [31:0] decOpa;
    logic [31:0] decOpb;
    logic [3:0]  decAddr;

    // Saída do Execute -> Entrada do Write-Back
    logic [31:0] exeRes;
    logic [3:0]  exeAddr;
    logic        doneExecute;

    fetch fetchStage (
        .clock(clock),
        .reset(reset),
        .activateFetch(activateFetch),
        .dataIn(memDataIn),
        .addr(memAddr),
        .dataOut(fetchInstruction)
    );

    decode decodeStage (
        .clock(clock),
        .reset(reset),
        .activateDecoder(activateDecode),
        .dataFetch(fetchInstruction),
        .regbank(regbank),
        .opcode(decOpcode),
        .dataOpa(decOpa),
        .dataOpb(decOpb),
        .addrMor(decAddr)
    );

    execute executeStage (
        .clock(clock),
        .reset(reset),
        .activateExecute(activateExecute),
        .decOpcode(decode_to_execute_opcode),
        .decOpa(decode_to_execute_opa),
        .decOpb(decode_to_execute_opb),
        .decAddr(decode_to_execute_addr),
        .miso(miso),
        .mosi(mosi),
        .sclk(sclk),
        .nssAlu(nssAlu),
        .nssMul(nssMul),
        .nssBas(nssBas),
        .dataRes(execute_to_wb_res),
        .dataAddr(execute_to_wb_addr),
        .doneExecute(doneExecute)
    );

    write_back wbStage (
        .activateWb(activateWb),
        .exeRes(exeRes),
        .exeAddr(exeAddr),
        .wbEn(wbEn),
        .wbAddr(wbAddr),
        .wbData(wbData)
    );

endmodule