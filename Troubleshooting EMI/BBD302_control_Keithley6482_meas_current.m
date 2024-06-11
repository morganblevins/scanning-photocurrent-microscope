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

%% Create Keithley6482 object with specified connection type and port
k = visadev("GPIB24::25::INSTR");
writeline(k,"*IDN?");
idn = readline(k)

% • Channel 2 measurement range: 2 μA
% • Channel 2 source range: 10 V
% • Channel 2 source output level: 10 V

writeline(k,'*RST'); % Restore GPIB defaults.
writeline(k,':SENS1:CURR:RANG 2e-6'); % Select 200 microAmp range
% writeline(k,':SENS1:CURR:RANG 2e-4'); % Select 200 microAmp range
writeline(k,':FORM:ELEM CURR1'); % Return channel 1 reading
writeline(k,':SOUR1:VOLT:RANG 1'); % Select 1 V source range (10 or 30)
writeline(k,':SOUR1:VOLT 0'); % Source 2 output = 0V
writeline(k,':OUTP1 ON'); % Output on before measuring
writeline(k,':READ?'); % Trigger, aquire reading
data = readline(k); % Read
% writeline(k,':OUTP2 OFF'); % Output off after measuring


%% Add and Import Assemblies for BBD30X Brushless Servo Controller
devCLI = NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.DeviceManagerCLI.dll');
genCLI = NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.GenericMotorCLI.dll');
motCLI = NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.Benchtop.BrushlessMotorCLI.dll');

import Thorlabs.MotionControl.DeviceManagerCLI.*
import Thorlabs.MotionControl.GenericMotorCLI.*
import Thorlabs.MotionControl.Benchtop.BrushlessMotorCLI.*

% Connect to BBD30X Brushless Servo Controller

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

pos2 = channel2.GetPositionCounter; % Get Channel 1
channel2.GetDevParams;
% pause(1);
motorSettings2 = channel2.LoadMotorConfiguration(channel2.DeviceID);
% pause(1);

%%
velParams = channel1.GetVelocityParams_DeviceUnit;
velParams.Acceleration = 1;
velParams.MaxVelocity = 100;
channel1.SetVelocityParams_DeviceUnit(velParams)
channel1.GetVelocityParams_DeviceUnit
channel2.SetVelocityParams_DeviceUnit(velParams)
channel2.GetVelocityParams_DeviceUnit

%% Initialize x-y map for MLS203 stage
posY = channel2.GetPositionCounter % Get Channel 2 position
posX = channel1.GetPositionCounter % Get Channel 2 position


x_center = double(posX)/20000.0;
y_center = double(posY)/20000.0;

span = 0.005;

x_min = x_center-span; % mm
% x_min = x_center; % mm
y_min = y_center-span; % mm
x_max = x_center+span; % mm
y_max = y_center+span; % mm

x_step = 0.00025; % mm 
y_step = x_step; % mm
x = x_min:x_step:x_max;
y = y_min:y_step:y_max;
XY = meshgrid(x,y); % meshgrid of (x,y) coordinates

%% Initialize vectors for PMT data
meas = ones(length(x),length(y));
meas_str = meas;
t = meas;
% define pause time between commands for test
pTime = 0.05;
% pTime = 2;
MeasTime = (length(x)*length(y)*pTime)/60; % seconds

%% Confirm Location %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pos_x = x_center;
pos_y = y_center;
fprintf("Moving to center...\n")
channel1.MoveTo(pos_x, timeout);
fprintf("Moved to x...\n")
channel2.MoveTo(pos_y, timeout);
fprintf("Moved to y...\n")

dlgTitle    = 'User Question';
dlgQuestion = 'Is location correct?';
choice = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'Yes');

if contains(choice, 'No')
    % Disconnect BBD302
    channel1.StopPolling();
    channel1.DisableDevice();
    channel2.StopPolling();
    channel2.DisableDevice();
    device.Disconnect();
    fprintf("BBD302 disconnected. \n")
    % end
    return
end

%% Loop through grid of positions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
writeline(k, ':READ?');
data = readline(k);
meas = abs(str2double(data)).*meas;
for jj = 1:length(y)
    for ii = 1:length(x)
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
        subplot(1,2,1)
        imagesc(-(x-x_center).*1000,(y-y_center).*1000,abs(meas).*10^6); % signal, microAmps
        set(gca,'YDir','normal')
        % colormap(hot)
        % ylabel('y'); xlabel('x');
        ylabel('y (microns)'); xlabel('x (microns)');
        a=colorbar;
        a.Label.String = 'microA';
        subplot(1,2,2)
        imagesc(-(x-x_center).*1000, (y-y_center).*1000, abs(meas).*10^9 - min(min(abs(meas))).*10^9 ); % net signal, nanoAmps
        set(gca,'YDir','normal')
        % colormap(hot)
        % ylabel('y'); xlabel('x');
        ylabel('y (microns)'); xlabel('x (microns)');
        b=colorbar;
        b.Label.String = 'nA';

    end
    % Progress update.
    disp([num2str(round(100*jj/length(y),3,'significant')) '% completed...']);
end

% dlgTitle    = 'User Question';
% dlgQuestion = 'Do you wish to save this data?';
% choice = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'Yes');
% 
% if contains(choice, 'Yes')
% 
% end

% dlgTitle    = 'User Question';
% dlgQuestion = 'Do you wish to disconnect Keithley and BBD302 stage?';
% choice = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'Yes');
% 
% if contains(choice, 'Yes')
    % Disconnect Keithley 2400

%% Move away from flake to prevent burning
% pos_x = x_center+0.3; % move 300 microns away from last position
% pos_y = y_center;
% channel1.MoveTo(pos_x, timeout);
% channel2.MoveTo(pos_y, timeout);

%%
writeline(k, ':OUTP OFF');
fprintf("Keithley off. \n")

% Disconnect BBD302
channel1.StopPolling();
channel1.DisableDevice();
channel2.StopPolling();
channel2.DisableDevice();
device.Disconnect();
% end
fprintf("BBD302 disconnected. \n")


%%
timeStr = datestr(now, 'yyyy-mm-dd-HHMM');

fileName = "SPCM_result_"+ timeStr +".mat";
figName = "SPCM_result_"+ timeStr +".fig";

save(fileName)
savefig(figName)
