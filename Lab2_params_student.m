% Pendulum Param
l = 0.1;     % [m]  (massless link)
mp = 0.05;   % [kg] (point mass)
g = 9.81;    % [m/s^2]
% Motor Param from experiment 
Rm = 3.18;          % [ohm]
Lm = 2.8445e-3;     % [H]
Bm = 77.581e-6;     % [N * S/M]
Jm = 58.559e-6;     % [kg * m^2]
Km = 50.6e-3;       % [N * m/A]
Ke = 52.8e-3;       % [V * S/rad]

tau = Lm / Rm;

% Transfer function
denominator = [
    Lm * (Jm + (mp * l * l));
    (Rm * Jm) + (Bm * Lm) + (mp * l * l * Rm);
    (Bm * Rm) + (Ke * Km);
]';

plant = tf(Km, denominator);
disturbance = tf([Lm, Rm], denominator);

dis_feedforward = tf([Lm, Rm], [Km * tau, Km]);
ref_feedforward = (1 / plant) * tf(1, [tau * tau, 2 * tau, 1]);