cd AsmTest
make all
cd ..
iverilog *.v
./a.out
gtkwave wave.vcd