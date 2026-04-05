%% Define references
step = 45;
references = step:step:360-step;

%% Define Kp cases
Wn = 1.29835;
Kp_list = [
    ((Wn^2) * Rm * (Jm + (mp * l^2))) / Km    % Calculate
    0.063101                                  % CSD
    0.064429                                  % P(s)
    0.06499                                   % P(z)
];

Kp_names = ["Calculate","CSD","P(s)","P(z)"];
Blocks = ["Block","P(s)","P(z)"];
Block = Blocks(3);

%Kp = 0.06413;