% Measure current sweep of Keithley 2400
% Morgan Blevins Feb. 2024
% Comm protocol is given in manual

clear all; close all; clc

cd('.')
addpath(genpath('.\Common'))
addpath(genpath('.\CommonDevice\Keithley'))

%# define pause time between commands for test
pTime = 2;

%# create Keithley2400 object with specified connection type and port
k = visadev("GPIB24::24::INSTR");
writeline(k,"*IDN?");
idn = readline(k)

pause(pTime)

start = 0;
stop = 0.2;
step = 0.1;
lengthRange = length(min(start,stop):abs(step):max(start,stop));
lR = num2str(lengthRange);

writeline(k,':SENS:FUNC:CONC OFF');
writeline(k,':SOUR:FUNC CURR');
writeline(k,':SENS:FUNC "VOLT:DC"');
writeline(k,':SENS:VOLT:PROT 1');

writeline(k,[':SOUR:CURR:STAR ',num2str(start)]);    % Specify start level for I-sweep.
writeline(k,[':SOUR:CURR:STOP ',num2str(stop)]);     % Specify stop level for I-sweep.
writeline(k,[':SOUR:CURR:STEP ',num2str(step)]);     % Specify step value for I-sweep.
writeline(k,':SOUR:CURR:MODE SWE');
writeline(k,':SOUR:SWE:RANG AUTO');

%# set sweep spacing type (LINear or LOGarithmic).
writeline(k,':SOUR:SWE:SPAC LIN');    

%# set trigger counts (must be = # sweep points)
% writeline(k,':TRIG:COUN %s', num2str(lengthRange));
writeline(k,[':TRIG:COUN ', lR]);

writeline(k, ':OUTP ON');
writeline(k, ':SOUR:DEL 0.1');

pause(pTime)


writeline(k, ':READ?');
data = readline(k)

pause(pTime)

writeline(k, ':OUTP OFF');

% *RST
% :SENS:FUNC:CONC OFF
% :SOUR:FUNC CURR
% :SENS:FUNC ‘VOLT:DC’
% :SENS:VOLT:PROT 1
% :SOUR:CURR:START 1E-3
% :SOUR:CURR:STOP 10E-3
% :SOUR:CURR:STEP 1E-3
% :SOUR:CURR:MODE SWE
% :SOUR:SWE:RANG AUTO
% :SOUR:SWE:SPAC LIN
% :TRIG:COUN 10
% :SOUR:DEL 0.1
% :OUTP ON
% :READ?


% c= datestr(now,'mm-dd-yyyy-HH-MM') + "_IVCurve.mat";
% 
% [file,path] = uiputfile(c,'Save data as');
% if file~=0
%    save([path file],'dataSweepV2','resistance'); 
% else
%    disp('User selected Cancel');
% end