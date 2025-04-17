# **Hardware Implementation of an Image Decompressor (SystemVerilog)**

This project is focused on developing an image decompressor in **SystemVerilog** based on the **McMaster Image Compression (.mic18) specification**. The decompressed image is displayed on an **Altera DE2-115 FPGA board**.

## **Getting Started**

### **Prerequisites**
- **Quartus Prime** for FPGA synthesis and programming
- **ModelSim** for simulation
- **Altera DE2-115 FPGA Board**
- **Basic knowledge of digital systems and hardware design concepts**

### **Setup**
1. Clone this repository:
   ```bash
   git clone https://github.com/amhar86/image-decompressor.git
   cd image-decompressor
   ```
2. Open the Quartus Prime project file and compile the SystemVerilog source files.
3. Use ModelSim to run testbenches and validate functionality.
4. Program the Altera DE2-115 FPGA and connect a VGA monitor to display the output.

## **Project Overview**
The project is broken into multiple milestones, each addressing a critical part of the image decompression process.

### **Milestone 1: Color Space Conversion and Upsampling**
- Converts **YUV** to **RGB**.
- Upsamples **U and V** components to match the **Y** component.
- Stores the resulting **RGB** image in **SRAM**.

- **Key Components:**
  - Finite State Machines (FSMs)
  - SRAM and Dual-Port RAM (DPRAM) interfacing
  - VGA Display Controller

### **Milestone 2: Inverse Discrete Cosine Transform (IDCT)**
- Utilizes **matrix multiplication** to perform the **IDCT**.
- Recovers the **downsampled image**.

- **Key Components:**
  - **SRAM** fetch and store operations
  - Fixed-point arithmetic for IDCT calculations

### **Milestone 3: Lossless Decoding and Dequantization** *(Incomplete)*
- Implements **lossless decoding** of the bitstream.
- **Dequantizes** the frequency domain image.

## **Controls and Usage**
- **UART Interface**: Transfers compressed image data from PC to FPGA.
- **SRAM Controller**: Manages the storage of the decompressed image.
- **VGA Output**: Displays the decompressed image.

## **Code Structure**
This implementation follows a **modular design approach**, separating different functions into individual **SystemVerilog** modules.

### **Core Components**
#### **project.sv** (Top-Level Module)
- Controls the overall flow of data between the modules.

#### **Milestone1.sv** (Upsampling & Color Conversion)
- Converts **YUV** to **RGB** and performs upsampling.

#### **Milestone2.sv** (IDCT Implementation)
- Uses matrix multiplication to perform **Inverse Discrete Cosine Transform**.

#### **UART_SRAM_interface.sv** (UART Communication)
- Handles image data transfer from PC to FPGA.

#### **sram_controller.sv** (SRAM Read/Write)
- Manages memory operations for decompressed image storage.

#### **vga_controller.sv** (VGA Display)
- Reads decompressed image from SRAM and outputs it to a monitor.

## **Features**
✔️ Hardware-accelerated image decompression  
✔️ Real-time VGA output on an FPGA 
✔️ Efficient use of **SRAM** and **DPRAM**  
✔️ **SystemVerilog** implementation with **FSMs**
✔️ Optimized fixed-point arithmetic for efficient computation
