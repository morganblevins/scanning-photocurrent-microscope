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