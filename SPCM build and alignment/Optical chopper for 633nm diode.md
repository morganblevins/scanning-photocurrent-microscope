**August 29th, 2024**

Note, <span style="color: black;">I followed the alignment procedure in the “alignment procedure” document. <span style="color: black;">Very important to have alignment of the beamsplitter, compensator, and the objective and PMT.</span></span>

<img src="../_resources/b49b07a15e9291233a238db1436017e6.png" alt="b49b07a15e9291233a238db1436017e6.png" width="466" height="621" class="jop-noMdConv">

![bbc21b7856a410d6f615ad2f453ef3b3.png](../_resources/bbc21b7856a410d6f615ad2f453ef3b3.png)

**Procedure:**

1.  1<span style="color: black;">Position the chopper wheel in front of the laser such that the laser hits the outer slots</span>
2.  <span style="color: black;">Connect the SR540 ‘f’ output to the the reference input of the SR830 Lock-in amp</span>
3.  <span style="color: black;">Turn on the SR540 and set to desired frequency (avoid 60 Hz and its harmonics)</span>
4.  <span style="color: black;">The SR830 lock in should immediately pick up the reference frequency and track is very easily</span>
5.  <span style="color: black;">Connect the photodetector output to the SR830 input A and select current measurement</span>
6.  <span style="color: black;">Set SR830 Channel 1 to display X or R (I did X in this test)</span>
7.  <span style="color: black;">Set SR830 Channel 2 to display phase (theta)</span>
8.  <span style="color: black;">Adjust setting of SR830 until Channel 2 phase is constant (follow 2f rule,</span> <span style="color: black;">etc</span><span style="color: black;">)</span>
9.  <span style="color: black;">Connect the Channel 1 output to the Keithley 2400 and perform a scanning map over a gold-silicon interface on a wafer</span>

<span style="color: black;">![4df352abc03d44a949926eac960aa1db.png](../_resources/4df352abc03d44a949926eac960aa1db.png)</span>

<span style="color: black;"><span style="color: black;">This is the best reflection map I’ve ever gotten!! The gradation is</span> <span style="color: black;">really nice</span> <span style="color: black;">and exact. And it seems to even pick up a little hole in the upper right side.</span></span>

Note,

- <span style="color: black;">The PMT gets saturated depending on the gain you use to power it, so it may show “overload” if the conditions are too bright in the room. Reduce gain or lower lighting</span>
- There is an extra 635 bandpass filter in Mathias’ cupboard- may add this in front of the PMT to get rid of this issue.
- In this test I used a 30ND filter and had 1 small over-the-optical-bench light on