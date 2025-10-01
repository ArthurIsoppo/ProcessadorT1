if {[file isdirectory work]} {vdel -all -lib work}
vlib work
vmap work work

set TOP_ENTITY {work.testbench}

vlog -work work +cover=bcesfx ../rtl/IF_SPI.sv
vlog -work work +cover=bcesfx ../rtl/shifter.sv
vlog -work work +cover=bcesfx ../rtl/fetch.sv
vlog -work work +cover=bcesfx ../rtl/decode.sv
vlog -work work +cover=bcesfx ../rtl/writeBack.sv
vlog -work work +cover=bcesfx ../rtl/alu.sv
vlog -work work +cover=bcesfx ../rtl/mul.sv
vlog -work work +cover=bcesfx ../rtl/bas.sv
vlog -work work +cover=bcesfx ../rtl/execute.sv
vlog -work work +cover=bcesfx ../rtl/processor.sv

vlog -work work +cover=bcesfx testbench.sv

vsim -voptargs=+acc ${TOP_ENTITY} -coverage

quietly set StdArithNoWarnings 1
quietly set StdVitalGlitchNoWarnings 1

add wave -divider "Controle Principal"
add wave sim:/testbench/clock
add wave sim:/testbench/reset

add wave -divider "Processador DUT"
add wave sim:/testbench/dut/state
add wave sim:/testbench/dut/memAddr
add wave sim:/testbench/dut/memDataIn

add wave -divider "Banco de Registradores"
add wave -radix decimal sim:/testbench/dut/regbank 

add wave -divider "Interface SPI"
add wave sim:/testbench/spi_bus/sclk
add wave sim:/testbench/spi_bus/mosi
add wave sim:/testbench/spi_bus/miso

add wave -divider "Slave Selects (Ativo Baixo)"
add wave sim:/testbench/dut/executeStage/nssAlu
add wave sim:/testbench/dut/executeStage/nssMul
add wave sim:/testbench/dut/executeStage/nssBas

run -all

echo "==> Simulação finalizada."

