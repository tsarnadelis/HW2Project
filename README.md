# Floating Point Single Precision Multiplier in SystemVerilog

## Overview

This project implements a floating point single precision multiplier in SystemVerilog. The implementation is divided into several modules, each handling different aspects of the multiplication process. Additionally, testbenches are provided to verify the functionality and correctness of the multiplier.

## Course Info
This project is part of the course Low-Level HW Digital Systems 2

Course Professor: [Vasilis Pavlidis](https://thessis.web.auth.gr/?page_id=436)

ΤΑ (responsible for the Project): Arisotelis Tsekouras

## Repository Structure

The project is organized into three main directories, each corresponding to different exercises or parts of the implementation.

### Folder exercise 1

This folder contains the core modules for the floating point multiplication process:

- **fp_mult.sv**: The main module that integrates the overall floating point multiplication process.
- **normalize_mult.sv**: This module handles the normalization of the result after multiplication.
- **exception_mult.sv**: This module manages exceptions that may occur during multiplication, such as overflow, underflow, and invalid operations.
- **round_mult.sv**: This module performs rounding on the final result of the multiplication.

### Folder exercise 2

This folder includes the testbench for verifying the multiplier:

- **fp_mult_tb.sv**: A comprehensive testbench that includes tests for rounding and various corner cases to ensure the robustness of the multiplier.

### Folder exercise 3

This folder contains additional test modules to further validate the implementation:

- **test_status_bits.sv**: Contains immediate assertions to check the status bits during the multiplication process.
- **test_status_z_combinations.sv**: Contains concurrent assertions to validate different status and zero combinations during the operation.

## Software
For design and simulation the [ModelSim/Questa](https://www.intel.com/content/www/us/en/software/programmable/quartus-prime/questa-edition.html) software from Intel was used.
