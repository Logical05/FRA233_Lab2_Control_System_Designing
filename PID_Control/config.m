%% Define references
step = 90;
references = step:step:360-step;

%% Define Kpid cases
Kp_list = [
    0.06413                            % CSD
    0                                  % PID(s)
    0                                  % PID(z)
];
Ki_list = [
    0                                  % CSD
    0                                  % PID(s)
    0                                  % PID(z)
];
Kd_list = [
    0                                  % CSD
    0                                  % PID(s)
    0                                  % PID(z)
];

K_names = ["CSD","PID(s)","PID(z)"];
Blocks = ["Block","PID(s)","PID(z)"];
Block = Blocks(1);