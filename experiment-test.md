# SPCM Laboratory Notebook

Optical path:

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

Optical path parts:

| Item              | Part # | About |
| :---------------- | :------: | ----: |
| 633 nm laser      |   P..   | diode |
| ND filter, 0.01\%        |   NE40A   | Neutral density filter |
| 1/2 Waveplate    |   ---   | Linear polarizer |
| Beamsplitter 1    |  False   | splits optical path to PMT |
| PMT |  False   | Photomultipler tube, measures refl. |
| Beamsplitter 2  |   P..   | diode |
| Beamsplitter 3  |   NE40A   | Neutral density filter |
| Camera tube    |  False   | splits optical path to PMT |
| Camera    |  False   | splits optical path to PMT |
| Objective |  False   | Photomultipler tube, measures refl. |

Starting with the "orange" flake on the PbTaSe2 chip 4. First I do a quick reflection map of a flake that is not part of the circuit to confirm the system is working.

![flake_refl_test_camera](https://github.com/morganblevins/scanning-photocurrent-microscope/assets/75329182/38e2ec4a-0a4a-44e4-83aa-66895ee68e83)

![flake_refl_test](https://github.com/morganblevins/scanning-photocurrent-microscope/assets/75329182/5d307bfe-04dc-4dbc-b712-e6bbfcc5f514)

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


