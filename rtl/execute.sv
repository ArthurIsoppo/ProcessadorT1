module execute (
    input logic clock,
    input logic reset,

    input logic activateExecute,

    input logic [2:0]   decOpcode,
    input logic [31:0]  decOpa,
    input logic [31:0]  decOpb,
    input logic [3:0]   decAddr,

    input  logic miso,
    output logic mosi,
    output logic sclk,
    output logic nssAlu,
    output logic nssMul,
    output logic nssBas,

    output logic [31:0] dataRes,
    output logic [3:0]  dataAddr,

    output logic doneExecute
);

    typedef enum {
        IDLE,
        START,
        SHIFT,
        FINISH
    } executeState_t;
    executeState_t state, nextState;

    logic [66:0] dataSend;
    logic [31:0] result;
    int counter;

    assign dataAddr = decAddr;

    always_ff @(posedge clock or negedge reset) begin
        if (!reset) begin
            state <= IDLE;
        end 
        else begin
            state <= nextState;

            if (state !== nextState) begin
                $display("State transition: %s -> %s @ time %t", state.name(), nextState.name(), $time);
            end
        end
    end

    always_ff @(posedge clock or negedge reset) begin
        if(!reset) begin
            nextState = IDLE;
            mosi <= 1'b0;
            sclk <= 1'b0;
            nssAlu <= 1'b1; // desativado
            nssMul <= 1'b1; // desativado
            nssBas <= 1'b1; // desativado
            doneExecute <= 1'b0;
            counter = '0;
        end 
        else begin
            doneExecute = 0;

            nssAlu <= 1'b1; // desativado
            nssMul <= 1'b1; // desativado
            nssBas <= 1'b1; // desativado            

            unique case(state) 
                IDLE: begin
                    if (activateExecute) begin
                        dataSend <= {decOpcode, decOpa, decOpb};

                        counter <= 67;

                        nextState <= START;
                    end
                    else begin
                        nextState <= IDLE;
                    end
                end

                START: begin
                    if (decOpcode >= 3'b000 && decOpcode <= 3'b010) begin // ALU
                        nssAlu <= 1'b0;
                    end
                    else if (decOpcode == 3'b011) begin // MUL
                        nssMul <= 1'b0;
                    end
                    else begin // BAS
                        nssBas <= 1'b0;
                    end

                    nextState <= SHIFT;
                end

                SHIFT: begin
                    sclk <= ~sclk;

                    if(~sclk) begin
                        if (counter > 0) begin
                            mosi <= dataSend[counter-1];
                        end
                    end
                    else begin
                        counter <= counter -1;

                        if (counter <= 32) begin
                            result <= {result[30:0], miso};
                        end
                    end

                    if (counter == 1) begin
                        nextState <= FINISH;
                    end
                end

                FINISH: begin
                    doneExecute <= 1'b1;
                    sclk <= 1'b0;
                    nssAlu <= 1'b1;
                    nssMul <= 1'b1;
                    nssBas <= 1'b1;
                    nextState <= IDLE;
                end
            endcase
        end
    end

    IF_SPI spi_bus();

    logic miso_alu, miso_mul, miso_bas;
    assign miso = miso_alu | miso_mul | miso_bas; 

    alu alu_inst (
        .clock(clock),
        .reset(reset),
        .nss(nssAlu),  
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso_alu)
    );

    mul mul_inst (
        .clock(clock),
        .reset(reset),
        .nss(nssMul), 
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso_mul) 
    );

    bas bas_inst (
        .clock(clock),
        .reset(reset),
        .nss(nssBas),  
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso_bas) 
    );

    // Barreira
    always_ff @(posedge clock or negedge reset) begin
        if (!reset) begin
            dataRes <= '0;
        end
        else if (state == FINISH) begin
            dataRes <= result;
        end
    end


endmodule