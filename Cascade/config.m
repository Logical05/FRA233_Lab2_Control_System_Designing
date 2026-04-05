%%{
Kp_pos = 1;
Ki_pos = 0; 
Kd_pos = 0;
N_pos = 100;

Kp_vel = 1;
Ki_vel = 0; 
Kd_vel = 0;
N_vel = 100;
%%}

sampling_time = 0.001;

%% Define Pos cases (Outer)
Kp_pos_list = [
    13.249          % PI-PD CSD
    7.1050888       % PD-PI CSD
    6.76            % PID-PID CSD
    6.1352978863740 % PI-PD (s)
    2.8380351186159 % PD-PI (s)
    1.5050791008613 % PID-PID (s)
    1.5037897145523 % PI-PD (z)
    1.5892759438256 % PD-PI (z)
    0.5459273612730 % PID-PID (z)
];
Ki_pos_list = [
    3.059           % PI-PD CSD
    0               % PD-PI CSD
    8.59            % PID-PID CSD
    1.6291010949201 % PI-PD (s)
    0               % PD-PI (s)
    0.4582172377421 % PID-PID (s)
    0.4413395413387 % PI-PD (z)
    0               % PD-PI (z)
    0.0951400561356 % PID-PID (z)
];
Kd_pos_list = [
    0               % PI-PD CSD
    0.20162         % PD-PI CSD
    0.32293         % PID-PID CSD
    0               % PI-PD (s)
    1.3852261755224 % PD-PI (s)
    0.36830329660541 % PID-PID (s)
    0               % PI-PD (z)
    0.9803371232566 % PD-PI (z)
    0.1274238211062 % PID-PID (z)
];
N_pos_list = [
    100             % PI-PD CSD
    100             % PD-PI CSD
    100             % PID-PID CSD
    100             % PI-PD (s)
    7.890644451e+02 % PD-PI (s)
    3.972014807e+02 % PID-PID (s)
    100             % PI-PD (z)
    5.482906730e+02 % PD-PI (z)
    20.035201218701 % PID-PID (z)
];

%% Define Vel cases (Inner)
Kp_vel_list = [
    14.14           % PI-PD CSD
    1.2182          % PD-PI CSD
    1.41            % PID-PID CSD
    0.2841275215401 % PI-PD (s)
    0.1722400301993 % PD-PI (s)
    0.1227573527064 % PID-PID (s)
    0.1402402507663 % PI-PD (z)
    0.1722400301993 % PD-PI (z)
    0.2288807464927 % PID-PID (z)
];
Ki_vel_list = [
    0               % PI-PD CSD
    0.74017832      % PD-PI CSD
    5.75            % PID-PID CSD
    0               % PI-PD (s)
    0.005757666     % PD-PI (s)
    0.0341894125447 % PID-PID (s)
    0               % PI-PD (z)
    0.0057576660887 % PD-PI (z)
    0.0943853881014 % PID-PID (z)
];
Kd_vel_list = [
    0.0126          % PI-PD CSD
    0               % PD-PI CSD
    0.0042422       % PID-PID CSD
    0.0836570070938 % PI-PD (s)
    0               % PD-PI (s)
    0.0583134267580 % PID-PID (s)
    0.0621084755537 % PI-PD (z)
    0               % PD-PI (z)
    0.1013703857033 % PID-PID (z)
];
N_vel_list = [
    100             % PI-PD CSD
    100             % PD-PI CSD
    100             % PID-PID CSD
    47.519589602123 % PI-PD (s)
    100             % PD-PI (s)
    4.2458267158460 % PID-PID (s)
    27.235991019297 % PI-PD (z)
    100             % PD-PI (z)
    17.287920655585 % PID-PID (z)
];

K_names = ["PI-PD CSD", "PD-PI CSD", "PID-PID CSD", "PI-PD (s)", "PD-PI (s)", "PID-PID (s)", "PI-PD (z)", "PD-PI (z)", "PID-PID (z)"];
Blocks = ["Block","PID(s)","PID(z)"];
Block = Blocks(3);

%% ===== Requirement Limits =====

REQ_OS_VEL = 2;        % %
REQ_ERR_VEL = 0.02;    % rad/s

REQ_OS_POS = 2;        % %
REQ_ERR_POS = 4e-3;    % rad
