# Voxel Core One (VX-1): 64-bit Parallel JSON Accelerator

![Status](https://img.shields.io/badge/Status-GDS_Hardened-green) ![Process](https://img.shields.io/badge/Process-SkyWater_130nm-blue) ![Speed](https://img.shields.io/badge/Latency-1_Cycle-orange)

**A specialized hardware accelerator for wire-speed JSON structural parsing, designed to eliminate CPU bottlenecks in high-frequency trading and real-time analytics pipelines.**

![Die Shot](PLACE_YOUR_IMAGE_LINK_HERE)
*(Figure 1: GDSII Layout of the Voxel VX-1 Core synthesized for SkyWater 130nm)*

---

## 🚀 The Problem
In modern data infrastructure, **JSON parsing is expensive**.
* **CPU Limitation:** General-purpose CPUs must serialize data, processing 1 byte at a time, often taking **100+ cycles** per byte to handle escape sequences and state machines.
* **The Cost:** This burns CPU cycles, increases latency (jitter), and creates bottlenecks in 10Gbps+ networks.

## ⚡ The Solution: Voxel VX-1
The **Voxel VX-1** is a dedicated RTL core that implements **Parallel Prefix Scanning** to process data at wire speed.
* **Throughput:** Processes **8 Bytes per Clock Cycle** (64-bit bus).
* **Latency:** Deterministic **Single-Cycle** structural identification.
* **Efficiency:** Zero-stall architecture for handling escaped quotes (`\"`) and nested structures.

| Metric | Specification |
| :--- | :--- |
| **Clock Frequency** | 50 MHz (FPGA/ASIC) |
| **Throughput** | 400 MB/s (3.2 Gbps per core) |
| **Latency** | 20 ns (Deterministic) |
| **Technology Node** | SkyWater 130nm (OpenLane Flow) |
| **Logic Cells** | 78 Cells (Ultra-Compact) |

---

## 🛠 Architecture
The core utilizes a **Parallel Input, Parallel Output (PIPO)** architecture:

1.  **Ingest:** 64 bits of raw ASCII data are fetched in parallel.
2.  **Classify:** 8 parallel comparators identify potential structural characters (`{`, `}`, `:`, `,`, `"`).
3.  **Mask Generation:** A combinatorial prefix scan calculates the "String Mask" and "Escape Mask" for all 8 bytes instantly.
4.  **Filter:** Structural characters inside strings (e.g., `{"key": "val:ue"}`) are masked out.
5.  **Output:** A valid bitmap of structural tokens is released in the same clock cycle.

### Block Diagram
```mermaid
graph LR
    A[Data In (64-bit)] --> B[Char Classifiers]
    B --> C[Prefix Scan Logic]
    C --> D[Mask Generation]
    D --> E[Output Filter]
    E --> F[Structural Bitmap]
