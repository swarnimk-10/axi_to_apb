# AXI_to_APB_Bridge

This project implements a **write-only AXI4 to APB3 Bridge** in **SystemVerilog**. It acts as a protocol converter, enabling communication between an AXI burst-capable master and an APB3-compliant peripheral. This bridge is commonly used in SoC designs to connect high-performance AXI components with simpler, low-power APB devices.

---

## Protocol Descriptions

### AXI (Advanced eXtensible Interface) – AXI4 (Write-Only)

AXI is part of ARM’s AMBA (Advanced Microcontroller Bus Architecture) family. This project uses the **AXI4** protocol in a **write-only** mode, supporting basic burst transactions.

**Key Features:**

- Separate write address and write data channels  
- Burst write support (4-beat bursts)  
- Fully handshaked using `VALID` and `READY` signals  
- Write response channel (`BVALID`, `BREADY`)  
- Address auto-increment during burst  
- No read channel used  

![Screenshot 2025-07-02 222500](https://github.com/user-attachments/assets/318c12bc-d795-4057-8b1b-7c178baf2834)

---

### APB (Advanced Peripheral Bus) – APB3

APB is also part of the AMBA family. It is a simple, low-power bus protocol optimized for **connecting peripheral devices** like timers, UARTs, and GPIOs.

**Key Features:**

- Simple write operation (non-pipelined)  
- Low power and area-efficient  
- Supports only one transfer at a time  
- No burst transfers, no out-of-order transactions  
- Single clock edge operation  

![Screenshot 2025-07-02 222528](https://github.com/user-attachments/assets/53eeeb22-b0af-4a41-9635-b537c5957a58)

---

Together, AXI and APB are often used in SoC designs where a high-performance AXI bus is used to communicate with a protocol bridge, which then interfaces with low-speed peripherals using APB.

### AXI to APB Bridge

The **AXI to APB Bridge** serves as a **protocol converter** between an AXI4 (write-only) master and an APB3 peripheral. It accepts an AXI burst write transaction and converts it into a sequence of single-cycle APB write transactions. Address auto-incrementation is handled internally to support burst translation.

![Screenshot 2025-07-02 222554](https://github.com/user-attachments/assets/499fae8f-e408-487b-8818-a424fb198064)

---

## Schematic

![Screenshot 2025-07-02 222303](https://github.com/user-attachments/assets/81a29cb1-e168-46da-bad7-a34ef3dd4d93)

---

## Simulation Results

![Screenshot 2025-07-02 222040](https://github.com/user-attachments/assets/7aac18a9-194e-4a10-aa9f-84ba167a66bc)

