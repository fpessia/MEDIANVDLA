# MEDIANVDLA Open Source Hardware, version 1.0
---

## MEDIANVDLA

The NVIDIA Deep Learning Accelerator (NVDLA) is a free and open architecture that promotes
a standard way to design deep learning inference accelerators. With its modular architecture,
NVDLA is scalable, highly configurable, and designed to simplify integration and portability.
Learn more about NVDLA on the project web page.

<http://nvdla.org/>

## About this release

This release, in the `nvdlav1` branch, contains the non-configurable
"full-precision" version of NVDLA.  This non-configurable version is fixed
at 2048 8-bit MACs (or 1024 16-bit fixed- or floating-point MACs).  This
branch is expected to be a stable sustaining release; although bug fixes may
be added, new RTL feature improvements will not appear in this branch. 
Additionally, this branch will diverge from the `master` branch; commits
from that branch may be cherry-picked into this branch, but wholesale merges
from `master` will not appear on `nvdlav1`.

## Online Documentation

NVDLA documentation is located [here](http://nvdla.org/contents.html).  Hardware specific 
documentation is located at the following pages.
* [Hardware Architecture](http://nvdla.org/hwarch.html).
* [Integrator's Manual](http://nvdla.org/integration_guide.html).

This README file contains only basic information.

## Directory Structure

This repository contains the RTL, C-model, and testbench code associated with the NVDLA hardware 
release.  In this repository, you will find:

  * vmod/ -- RTL model, including:
    * vmod/nvdla/ -- Verilog implementation of NVDLA
    * vmod/vlibs/ -- library and cell models
    * vmod/rams/ -- behavioral models of RAMs used by NVDLA
  * syn/ -- example synthesis scripts for NVDLA
  * perf/ -- performance estimator spreadsheet for NVDLA
  * verif/ -- trace-player testbench for basic sanity validation
    * verif/traces/ -- sample traces associated with various networks
  * tools -- tools used for building the RTL and running simulation/synthesis/etc.
  * spec -- RTL configuration option settings.

## Building the MEDIANNVDLA Hardware

See the [integrator's manual](http://nvdla.org/integration_guide.html) for more information on 
the setup and other build commands and options.  The basic build command to compile the design
and run a short sanity simulation is:

    bin/tmake

## Testing MEDIANVDLA
In order to perform a functional test performing execution of  a Median Pooling Layer please ensure following additonal requirements:
* Anaconda3
* PyTorch
* build Verilator V5.019  from source code

```python
#!/bin/bash
# Cloning GitHub repo
git clone git@github.com:fpessia/MEDIANVDLA.git
#running configuration tree script
cd MEDIANVDLA
make
# Computing golden values
cd verif/traces/traceplayer/pdp_med2x2_pooling_int8
python LayerIOgeneration.py
# Compiling Soc with Verilator V5.019 
#configured from source code (Ubuntu 20.04)
cd ../../../../
./tools/bin/tmake -build verilator
#Running simulation script 2x2 kernel conf
cd verif/verilator
make run TEST=pdp_med2x2_pooling_int8
#or 3x3
#make run TEST=pdp_med3x3_int8
 
