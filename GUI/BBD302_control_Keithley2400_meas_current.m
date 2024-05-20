% Control code for measuring spatial photocurrent maps in the SPCM:
% Software for controlling the MLS203 X-Y stage via the BBD302 
% and reading the current output from the Keithley 2400
% By Morgan Blevins, Feb 2024

%% Notes
% - For the BBD303 using the MLS203 stage
% - For the PMTSS photodetector current measured with Keithley2400

%% BB302 control code is via Thorlabs github:
% https://github.com/Thorlabs/Motion_Control_Examples
% BBD30X.m
% Created Date: 2024-01-23
% Last modified date: 2024-01-23
% Matlab Version: R2023b
% Thorlabs DLL version: Kinesis 1.14.44

%% Start of code
clear all; close all; clc

%% Initialize x-y map for MLS203 stage

% This should be updated based on the current position of the x-y stage
% when the code is run:
x_center = 50.69280; 
y_center = 47.14280;

% Define how big the scanning picture is:

%APP CONTROLLED
%span = 0.015; % mm
%span = 0.004; % mm

% Define the edge coordinates of the picture:
x_min = x_center-span; % mm
x_min = x_center; % mm
y_min = y_center-span; % mm
x_max = x_center+span; % mm
y_max = y_center+span; % mm

% Define the step size for the picture:

%CONTROLLED BY APP
%x_step = 0.00025; % mm 
%y_step = x_step; % mm

% Define the [x,y] grid for looping:
x = x_min:x_step:x_max;
y = y_min:y_step:y_max;
XY = meshgrid(x,y); % meshgrid of (x,y) coordinates

%% Initialize vectors for PMT (photodetector) data
meas = ones(length(x),length(y));
meas_str = meas; % for holding the string version of the data
t = meas; % time of the measurement

% define pause time between commands for test
pTime = 0.05;
% pTime = 0.25;



%%% draft code for future %%%
pos2 = channel2.GetPositionCounter % Get Channel 1 (should be how I eventually get the position from the intial position)
channel2.GetDevParams
% pause(1);
motorSettings2 = channel2.LoadMotorConfiguration(channel2.DeviceID);
% pause(1);

% Prompt the user to see if you'd to HOME stage
%dlgTitle    = 'User Question';
%dlgQuestion = 'Home the BBD302 stage?';
%choice = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'Yes');

%IN APP HOME.m
%if contains(choice, 'Yes')
    % Home Motor
 %   fprintf("Homing...\n")
  %  channel1.Home(timeout);
   % fprintf("Homed\n")
    % pause(2);
    
    % Home Motor
    %fprintf("Homing 2...\n")
    %channel2.Home(timeout);
   % fprintf("Homed 2\n")
    % pause(2);
%end

% Initialize measurement with basline reading
writeline(k, ':READ?');
data = readline(k);
meas = str2double(data).*meas;

%% Loop through grid of positions 
for ii = 1:length(x)
    for jj = 1:length(y)
        pos_x = x(ii); % define next x position
        pos_y = y(jj); % define next y position

        channel1.MoveTo(pos_x, timeout); % move to x position
        channel2.MoveTo(pos_y, timeout); % move to y position

        pause(pTime); % pause 

        writeline(k, ':READ?'); % ask for the current value from Keithely 
        data = readline(k);     % read the current value recieved [string]
        meas_str(ii,jj) = data; % save data in string form
        meas(ii,jj) = str2double(data); % save data in double form 
        t(ii,jj) = toc;         % save time of reading

        pause(pTime); % pause

        % Live plotting:

        %MAY CHANGE !!!!!
        %-(x-x_center).*1000,(y-y_center).*1000

        imagesc(app.UIAxis,meas); % position in micrometers
        
        set(gca,'YDir','normal')
        ylabel('y (microns)'); xlabel('x (microns)');
    end
end

% ask user if they'd like to save data
dlgTitle    = 'User Question';
dlgQuestion = 'Do you wish to save this data?';
choice = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'Yes');

% Save data is answer was yes
if contains(choice, 'Yes')
    %save DATA
end
    
