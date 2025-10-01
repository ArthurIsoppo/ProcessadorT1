`timescale 1ns/1ps
module testbench();

    logic clock = 0;
    logic reset;

    always #5 clock = ~clock;
    initial begin
        reset = 1'b0
        #12;          
        reset = 1'b1; 
    end

    logic [7:0]  memAddr;
    logic [15:0] memDataIn;
    
    IF_SPI spi_bus(.*);

    // sintruções
    logic [15:0] mem[0:255];
    initial begin
        mem[0] = 16'b000_0_0011_0001_0010; // add r3, r1, r2
        mem[1] = 16'b011_0_0100_0011_0001; // mul r4, r3, r1
        mem[2] = 16'b100_1_0101_0100_0010; // shl r5, r4, #2
    end
    assign memDataIn = mem[memAddr];

    processor dut (
        .clock(clock),
        .reset(reset),
        .memAddr(memAddr),
        .memDataIn(memDataIn),
        .spi(spi_bus) 
    );

    alu alu_inst (.clock(clock), .reset(reset), .nss(tb_nss), .sclk(tb_sclk), .mosi(tb_mosi), .miso(tb_miso) );
    mul mul_inst (.clock(clock), .reset(reset), .nss(tb_nss), .sclk(tb_sclk), .mosi(tb_mosi), .miso(tb_miso) );
    bas bas_inst (.clock(clock), .reset(reset), .nss(tb_nss), .sclk(tb_sclk), .mosi(tb_mosi), .miso(tb_miso) );
    
    initial begin
        @(posedge reset);
        
        force dut.regbank[1] = 32'd10; // r1 = 10
        force dut.regbank[2] = 32'd20; // r2 = 20
        
        #250;

        $display("--- Verificação Final dos Registradores ---");
        // esperado: r3 = r1 + r2 = 10 + 20 = 30
        if (dut.regbank[3] == 30) $display("OK: Reg[3] (r3) = %d", dut.regbank[3]);
        else $display("ERRO: Reg[3] (r3) = %d (esperado: 30)", dut.regbank[3]);

        // esperado: r4 = r3 * r1 = 30 * 10 = 300
        if (dut.regbank[4] == 300) $display("OK: Reg[4] (r4) = %d", dut.regbank[4]);
        else $display("ERRO: Reg[4] (r4) = %d (esperado: 300)", dut.regbank[4]);

        // esperado: r5 = r4 << 2 = 300 * 4 = 1200
        if (dut.regbank[5] == 1200) $display("OK: Reg[5] (r5) = %d", dut.regbank[5]);
        else $display("ERRO: Reg[5] (r5) = %d (esperado: 1200)", dut.regbank[5]);

        $finish;
    end

endmodule

