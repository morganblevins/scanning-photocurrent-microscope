% Measure current sweep of Keithley 2400
% Morgan Blevins Feb. 2024
% Comm protocol is given in manual

clear all; close all; clc

% Initial vectors for data
n = 10;
meas = zeros(1, n);
meas_str = meas;
t = meas;

% cd('.')
% addpath(genpath('.\Common'))
% addpath(genpath('.\CommonDevice\Keithley'))

%# define pause time between commands for test
pTime = 0.25;

%# create Keithley2400 object with specified connection type and port
k = visadev("GPIB24::24::INSTR");
writeline(k,"*IDN?");
idn = readline(k)

pause(pTime)

writeline(k,':SOUR:FUNC VOLT');
writeline(k,':SOUR:VOLT:MODE FIXED');
writeline(k,':SENS:FUNC "CURR"');
writeline(k,':SOUR:VOLT:RANG MIN');
writeline(k,':SOUR:VOLT:LEV 0');   
writeline(k,':SENS:CURR:PROT 10E-6');
writeline(k,':SENS:CURR:RANG 10E-6');
writeline(k,':FORM:ELEM CURR');

writeline(k, ':OUTP ON');
pause(pTime)

tic
for ii = 1:n
    writeline(k, ':READ?');
    data = readline(k)
    meas_str(ii) = data;
    meas(ii) = str2double(data);
    t(ii) = toc;
    pause(pTime)
end

writeline(k, ':OUTP OFF');

figure()
plot(t, meas)
ylabel('PMT Current')
xlabel('Time (s)')

%  Basic Source-Measure Operation 3-19 in Keithley manual
%  *RST
%  :SOUR:FUNC VOLT
%  :SOUR:VOLT:MODE FIXED
%  :SOUR:VOLT:RANG 20
%  :SOUR:VOLT:LEV 10
%  :SENS:CURR:PROT 10E-3
%  :SENS:FUNC "CURR"
%  :SENS:CURR:RANG 10E-3
%  :FORM:ELEM CURR
%  :OUTP ON
%  :READ?
%  :OUTP OFF

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