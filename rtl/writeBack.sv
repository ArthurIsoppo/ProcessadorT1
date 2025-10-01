module write_back (
    input  logic        activateWb,

    input  logic [31:0] exeRes,
    input  logic [3:0]  exeAddr,

    output logic        wbEn,
    output logic [3:0]  wbAddr,
    output logic [31:0] wbData
);

    assign wbAddr = exeAddr;

    assign wbData = exeRes;

    assign wbEn = activateWb;

endmodule