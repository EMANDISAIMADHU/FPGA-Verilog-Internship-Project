# FPGA-Verilog-Internship-Project
# FPGA-Based Digital Systems Design & Verification Portfolio
### Host Internship Organization: Codec Technologies
**Developer:** EMANDI SAI MADHU  
**Discipline:** B.Tech in Digital Electronics and VLSI / Electrical and Electronics Engineering (EEE)  
**Academic Year:** 2nd Year  

---

## 🚦 Project 1: Traffic Light Controller with Emergency Priority System

### 1. Abstract & Objective
Traditional traffic signal grids rely on fixed delay intervals that fail to adapt to real-time road anomalies, such as approaching emergency vehicles (ambulances, fire trucks, or police vehicles). This project implements a fully automated, high-speed digital hardware control engine to manage an intersection safely while offering an instantaneous, sensory priority override corridor.

### 2. Core Hardware Architecture
* **Control Model:** Synchronous Moore Finite State Machine (FSM). In this state space, the visual output configurations depend strictly on the current state register value, making the system highly stable and immune to input line noise.
* **State Space Encoding Parameters:**
  * `RED_STATE` (`2'b00`): Active Red LED. Represents a complete traffic stop condition across standard lanes.
  * `GREEN_STATE` (`2'b01`): Active Green LED. Safe vehicular passage allowed.
  * `YELLOW_STATE` (`2'b10`): Active Yellow LED. Warning/transition stage preparing the intersection for a stop sequence.
  * `EMERGENCY_STATE` (`2'b11`): Active Green LED. Interrupt-driven green corridor dedicated to clearing the emergency path.
* **Safety Recovery Protocol:** When the emergency vehicle passes and the sensor drops back down (`emergency = 0`), the FSM transitions directly into the `RED_STATE`. This establishes a brief stop barrier to halt all moving vehicles safely before restarting the regular traffic sequencing loop (`RED` $\rightarrow$ `GREEN` $\rightarrow$ `YELLOW` $\rightarrow$ `RED`).

### 3. Verification & Results
* **Toolchain:** Compiled and behaviorally verified using ModelSim and EDA Playground simulation engines with nanosecond-precision timescale tracks (`1ns/1ps`).
* **Waveform Analysis:** Functional simulation waveform timing diagrams verify that the system holds baseline values during reset, cycles cleanly during normal operation, and intercepts the active pipeline within a fraction of a millisecond upon assertion of the emergency flag.

---

## 🗳️ Project 2: Digital Voting Machine with Secure Memory Integration

### 1. Abstract & Objective
Real-world hardware deployment on physical silicon fabrics (FPGAs/ASICs) requires addressing physical circuit anomalies, such as mechanical switch contact bounce and volatile data loss. This project delivers a secure, tamper-proof, and synthesizable Digital Voting Machine (DVM) that filters out switch vibrations, locks out duplicate voting attempts, and securely backs up voting statistics to permanent storage.

### 2. Core Hardware Architecture
The processing engine consists of five interactive structural module segments:
* **Digital Debouncer Core:** Sits directly between the raw mechanical button lines and internal logic. It runs a 16-bit clock-divider processing loop that samples signals at a scaled-down frequency. This filters out millisecond-range contact vibrations, passing a single clean pulse.
* **FSM Central Controller:** An explicit, synchronous state machine tracking five distinct states:
  * `IDLE` (`2'b00`): Booth is safely locked; candidate selection lines are entirely ignored until administrative authorization is granted (`voter_enable = 1`).
  * `WAIT_VOTE` (`2'b01`): Terminal is unlocked; actively monitors filtered outputs from the debouncer array.
  * `UPDATE_TALLY` (`2'b10`): Dedicated data modification phase incrementing the target candidate register (`count_A`, `count_B`, or `count_C`).
  * `COM_FLASH` / `STORE` (`2'b11`): Memory storage phase that asserts secure write lines before automatically executing a lockdown loop back to `IDLE`.
* **Non-Volatile Memory Bus Controller:** Generates external write-enable strobes (`flash_write_en`) and routes memory sector destination vectors (`flash_addr`) to automatically commit data to an external Flash/EEPROM chip. This ensures data preservation against sudden power failures.
* **7-Segment Matrix Decoder:** An active-low hardware decoder block that converts binary vote tracking registers into an output vector (`seg_display`) for visual alphanumeric monitoring.

### 3. Verification & Results
* **Toolchain:** Compiled, synthesized, and verified within the **ModelSim Intel FPGA Starter Edition 2020.1** environment.
* **Waveform & Schematic Analysis:** The design compiled with zero syntax errors, generating clean functional waveforms running up to `4,200 ns`. Timing traces confirm complete bounce rejection on input lines, successful state advancement, immediate flash-strobe generation, and accurate 7-segment output vector mapping. Gate-level structural logic verification was completed using synthesized RTL schematic view blocks.

---

## 🛠️ Compilation & Hardware Synthesizability
Both modules are engineered using completely standardized, non-blocking behavioral code structures making them fully synthesis-ready for real-world deployment on Field Programmable Gate Array (FPGA) development boards, including:
* **Target Platforms:** Xilinx Spartan / Intel Cyclone silicon series.
* **Resource Allocation Mapping:** Core sequential loops map to rows of physical Look-Up Tables (LUTs) and D-type Flip-Flops, inputs tie to physical surface switches/crystal oscillators, and outputs directly drive active hardware LED structures, external memory communication buses, and multi-segment display grids.

