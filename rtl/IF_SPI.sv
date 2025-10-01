interface IF_SPI(
    input logic clock,
    input logic reset
);

logic sclk;
logic miso;
logic mosi;
logic nss;

modport MASTER (
    input miso,
    
    output sclk,
    output mosi,
    output nss
);

modport SLAVE (
    input sclk,
    input mosi,
    input nss,

    output miso
);

endinterface