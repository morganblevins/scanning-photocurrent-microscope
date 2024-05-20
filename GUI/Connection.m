%% Create Keithley2400 object with specified connection type and port
k = visadev("GPIB24::24::INSTR");
writeline(k,"*IDN?"); % ask for the Keithley's identity
idn = readline(k)

writeline(k,':SOUR:FUNC VOLT');     % source voltage
writeline(k,':SOUR:VOLT:MODE FIXED'); % fized constant voltage
writeline(k,':SENS:FUNC "CURR"');   % measure current
writeline(k,':SOUR:VOLT:RANG MIN'); % use minimum voltage source range
writeline(k,':SOUR:VOLT:LEV 0');    % source 0 Volts
writeline(k,':SENS:CURR:PROT 1E-6'); % ???
writeline(k,':SENS:CURR:RANG 1E-6'); % use 1 microAmp current measurement range
writeline(k,':FORM:ELEM CURR');     % ???

writeline(k, ':OUTP ON'); % turn on Keithely output


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
timeout= 60000; % don't change

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