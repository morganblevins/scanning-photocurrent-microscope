% Disconnect Keithley 2400
writeline(k, ':OUTP OFF');

% Disconnect BBD302
channel1.StopPolling();
channel1.DisableDevice();
channel2.StopPolling();
channel2.DisableDevice();
device.Disconnect();