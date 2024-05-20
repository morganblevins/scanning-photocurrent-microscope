# SPCM Laboratory Notebook

**Optical path:**

```mermaid
graph LR
A[633 nm laser] -->B(ND filter)
    B --> C(1/2 W.P.)
    C --> D{B.S.}
    D --> E[PMT]
    D --> F{B.S.}
    G[Lamp] --> F
    F --> H{B.S.}
    H --> I(Camera)
    H --> J(Obj.)
    J --> K[Sample]
```

**Optical path components:**

| Item              | Part # | About |
| :---------------- | :------: | ----: |
| 633 nm laser      | PL202	| Compact Laser Module with USB Connector, 635 nm, 0.9 mW (Typ.)  |
| ND filter, 0.01\% |   NE40A   | Neutral density filter |
| 1/2 Waveplate    | WPH05ME-633 | Linear polarizer, -- \% Reflection |
| Beamsplitter 1  | ...   | Splits optical path to PMT |
| PMT |  PMTSS   | Standard Sensitivity PMT Module|
| Beamsplitter 2  |  ...   | Adds in white lamp |
| Beamsplitter 3  |  ...  | Splits between camera and objective |
| Camera tube    |  WFA4102   | Camera port 0.5x |
| Camera    |  8051C-USB   | 8 MP Color CCD Camera |
| Objective |  LMM40X-P01   | 40X Reflective Objective P01 Coating 0.50 NA BFL = Infinity |

BSW04 - Ø1/2" 50:50 UVFS Plate Beamsplitter, 400-700nm, t=3mm
BSW29P - 50:50 UCFS plate beamsplitter 600-1700nm
BSS10R - 25 x 36 mm 30:70 (R:T) UVFS Plate Beamsplitter, Coating: 400 - 700 nm, t = 1 mm
BSX10 - 90:10 (R:T) UVFS Plate Beamsplitter, Coating: 400-700 nm, t = 5 mm

**Sample**

PbTaSe2 from 2DSemiconductor.com, deposited on HS39626-WO: SSP w/2 Semi-Std Flats & 2850 A°±5% Wet Thermal Oxide.

Electrodes fabricated in the MIT Nano lab May 23, 2023 by Morgan Blevins.


<img width="676" alt="image" src="https://github.com/morganblevins/scanning-photocurrent-microscope/assets/75329182/2f3baff4-8f25-413e-92a7-c0197308f6b1">



<img width="647" alt="image" src="https://github.com/morganblevins/scanning-photocurrent-microscope/assets/75329182/80c6a184-9f9a-4ee1-95b4-d3fe15a23738">


Starting with the "blue" flake on the PbTaSe2 chip 4, which is wirebonded to electrodes 4,5, 20, 21, and 22. First I do a quick reflection map of a flake that is not part of the circuit to confirm the system is working.

<img width="777" alt="image" src="https://github.com/morganblevins/scanning-photocurrent-microscope/assets/75329182/fa484179-6312-4ef2-a536-3d8fb74771e6">


Next I perform a reflection map of the entire flake now that I see the setup is working. 



## Experiment Identifiers

Experiments conducted for the **Scanning Photocurrent Microscope** (SPCM) are identified as follows:

_KBSX-Y_

where
- KBS is the initials of the experimentalist (Klementine Burrell-Sander)
- X is a number used to identify the molecule
- Y is a number that indicates how many times the reaction has been repeated

For example, **KBS19-3** indicates the **third** attempt at synthesising molecule **KBS19**


Experiments conducted for The Breaking Good Project are identified as follows:

Year of program
Underscore
Program the molecule is contributing to e.g. SSP (The University of Sydney's Special Studies program), BG (breaking good core program)
Underscore
One number followed by a letter - the main identifier of the molecule that is being synthesised
Underscore
A number which indicates the batch number/number of attempts

For example, **2022_BG_1J_002** describes the **second** attempt at the synthesis of molecule **1J** for the core Breaking Good program ran in **2022**.


