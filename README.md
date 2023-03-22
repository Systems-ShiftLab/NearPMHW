# NearPM

Near data accelerator for crash consistency overhead forcusing on data intensive tasks

##Pre-requirements

SW:

Vivado 2018.2 licensed

HW setup:

Virtex UltraScale+ VCU118 Evaluation Platform
AMD Ryzen 7 3700X 


##Building

Clone the repository

Build Vivado project
```bash
	vivado -mode batch -source build.tcl
```

Lauch Vivado and open project in gui
Note: If submodule run fails rerun the bitstream generation (This is probably due to a bug in Vivado)

Generate the bitsream for the design5



