% Software for controlling the MLS203 X-Y stage via the BBD302 
% and reading the current output from the Keithley 2400
% By Morgan Blevins, Feb 2024

%% BB302 control is via Thorlabs github (link)
% BBD30X.m
% Created Date: 2024-01-23
% Last modified date: 2024-01-23
% Matlab Version: R2023b
% Thorlabs DLL version: Kinesis 1.14.44
%% Notes
%
% - For the BBD303 using the MLS203 stage
% - For the PMTSS photodetector current measured with Keithley2400

%% Start of code
clear all; close all; clc

%% Initialize x-y map for MLS203 stage
% x_min = 0; % mm
% y_min = 0; % mm
% x_max = 10; % mm
% y_max = 10; % mm
x_center = 39.43445;
y_center = 34.75185;
span = 0.015;
x_min = x_center-span; % mm
y_min = y_center-span; % mm
x_max = x_center+span; % mm
y_max = y_center+span; % mm
x_step = 0.0005; % mm 
y_step = x_step; % mm
x = x_min:x_step:x_max;
y = y_min:y_step:y_max;
XY = meshgrid(x,y); % meshgrid of (x,y) coordinates

%% Initialize vectors for PMT data
meas = ones(length(x),length(y));
meas_str = meas;
t = meas;

%%
%# define pause time between commands for test
pTime = 0.05;

%% Create Keithley2400 object with specified connection type and port
k = visadev("GPIB24::24::INSTR");
writeline(k,"*IDN?");
idn = readline(k)

writeline(k,':SOUR:FUNC VOLT');
writeline(k,':SOUR:VOLT:MODE FIXED');
writeline(k,':SENS:FUNC "CURR"');
writeline(k,':SOUR:VOLT:RANG MIN');
writeline(k,':SOUR:VOLT:LEV 0');   
writeline(k,':SENS:CURR:PROT 10E-6');
writeline(k,':SENS:CURR:RANG 10E-6');
writeline(k,':FORM:ELEM CURR');

writeline(k, ':OUTP ON');


%% Add and Import Assemblies for BBD30X Brushless Servo Controller
devCLI = NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.DeviceManagerCLI.dll');
genCLI = NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.GenericMotorCLI.dll');
motCLI = NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.Benchtop.BrushlessMotorCLI.dll');

import Thorlabs.MotionControl.DeviceManagerCLI.*
import Thorlabs.MotionControl.GenericMotorCLI.*
import Thorlabs.MotionControl.Benchtop.BrushlessMotorCLI.*

%% Connect to BBD30X Brushless Servo Controller

% Build Device list
DeviceManagerCLI.BuildDeviceList();
DeviceManagerCLI.GetDeviceListSize();
DeviceManagerCLI.GetDeviceList();

% Input Parameters
serialNumber = '103355374'; % BBD302 controller serial number
timeout= 60000;

% Connect to device
device = BenchtopBrushlessMotor.CreateBenchtopBrushlessMotor(serialNumber); %;The output of this line must be suppressed
device.Connect(serialNumber)

% Channels are connected using the same serial number
% CHANNEL 1:
% Connect to channel:
channel1 = device.GetChannel(1); % Get Channel 1
channel1.WaitForSettingsInitialized(10000);
channel1.StartPolling(250);
% Enable device on channel 1
channel1.EnableDevice();
motorSettings1 = channel1.LoadMotorConfiguration(channel1.DeviceID);

% CHANNEL 2:
% Connect to channel:
channel2 = device.GetChannel(2); % Get Channel 1
channel2.WaitForSettingsInitialized(10000);
channel2.StartPolling(250);
% Enable device on channel 1
channel2.EnableDevice();

pos2 = channel2.GetPositionCounter % Get Channel 1
channel2.GetDevParams
% pause(1);
motorSettings2 = channel2.LoadMotorConfiguration(channel2.DeviceID);
% pause(1);

dlgTitle    = 'User Question';
dlgQuestion = 'Home the BBD302 stage?';
choice = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'Yes');

if contains(choice, 'Yes')
    % Home Motor
    fprintf("Homing...\n")
    channel1.Home(timeout);
    fprintf("Homed\n")
    % pause(2);
    
    % Home Motor
    fprintf("Homing 2...\n")
    channel2.Home(timeout);
    fprintf("Homed 2\n")
    % pause(2);
end

%% Loop through grid of positions 
writeline(k, ':READ?');
data = readline(k);
meas = str2double(data).*meas;

%%
for ii = 1:length(x)
    for jj = 1:length(y)
        pos_x = x(ii);
        pos_y = y(jj);
        % fprintf("Moving...\n")
        channel1.MoveTo(pos_x, timeout);
        channel2.MoveTo(pos_y, timeout);
        % fprintf("Moved\n")
        pause(pTime);
        writeline(k, ':READ?');
        data = readline(k);
        meas_str(ii,jj) = data;
        meas(ii,jj) = str2double(data);
        t(ii,jj) = toc;
        pause(pTime);
        % Live plotting:
        figure(1)
        imagesc(-(x-x_center).*1000,(y-y_center).*1000,meas);
        set(gca,'YDir','normal')
        % ylabel('y'); xlabel('x');
        ylabel('y (microns)'); xlabel('x (microns)');
    end
end

dlgTitle    = 'User Question';
dlgQuestion = 'Do you wish to save this data?';
choice = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'Yes');

if contains(choice, 'Yes')
    
end

% dlgTitle    = 'User Question';
% dlgQuestion = 'Do you wish to disconnect Keithley and BBD302 stage?';
% choice = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'Yes');
% 
% if contains(choice, 'Yes')
    % Disconnect Keithley 2400
    %%
    writeline(k, ':OUTP OFF');
    
    % Disconnect BBD302
    channel1.StopPolling();
    channel1.DisableDevice();
    channel2.StopPolling();
    channel2.DisableDevice();
    device.Disconnect();
% end

