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

writeline(k,':SOUR:FUNC CURR');
writeline(k,':SOUR:CURR:MODE FIXED');
writeline(k,':SENS:FUNC "VOLT"');
writeline(k,':SOUR:CURR:RANG MIN');
writeline(k,':SOUR:CURR:LEV 0');   
writeline(k,':SENS:VOLT:PROT 25');
writeline(k,':SENS:VOLT:RANG 20');
writeline(k,':FORM:ELEM VOLT');

writeline(k, ':OUTP ON');
pause(pTime)
writeline(k, ':READ?');
data = readline(k)
pause(pTime)
writeline(k, ':OUTP OFF');

% *RST
% :SOUR:FUNC CURR
% :SOUR:CURR:MODE FIXED
% :SENS:FUNC “VOLT”
% :SOUR:CURR:RANG MIN
% :SOUR:CURR:LEV 0
% :SENS:VOLT:PROT 25
% :SENS:VOLT:RANG 20
% :FORM:ELEM VOLT
% :OUTP ON
% :READ?
% :OUTP OFF

% Restore GPIB defaults.
% Current source function.
% Fixed current source mode.
% Volts measure function.
% Lowest source range.
% 0A source level.
% 25V compliance.
% 20V range.
% Volts only.
% Output on before measuring.
% Trigger, acquire reading.
% Output off after measuring.


% c= datestr(now,'mm-dd-yyyy-HH-MM') + "_IVCurve.mat";
% 
% [file,path] = uiputfile(c,'Save data as');
% if file~=0
%    save([path file],'dataSweepV2','resistance'); 
% else
%    disp('User selected Cancel');
% end