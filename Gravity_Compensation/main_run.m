%% Run parameter scripts
clear
close all
addpath("D:\University\Control\LAB\FRA233_Lab2_Control_System_Designing")

run("Lab2_params_student.m")
run("config.m")

model = "Lab2_single_loop_controller_student";
load_system(model);

%% Angles for experiment
for k = 1:length(angles)

    Angle = angles(k);

    fprintf("\n===== Experiment Angle %d deg =====\n",Angle)

    % Run Simulink model
    simOut = sim(model);

    pos_signal = simOut.logsout.getElement("position [deg]");
    t = pos_signal.Values.Time;
    pos = pos_signal.Values.Data;

    % Linearize system
    io = getlinio(model);
    sys = linearize(model,io);

    % ===== Pole analysis =====
    analysis_text = "==== POLE ANALYSIS ====" + newline;

    [wn,zeta,poles] = damp(sys);

    for i = 1:length(poles)

        sigma = real(poles(i));
        omega = imag(poles(i));

        if sigma < 0
            stability = "Stable";
        elseif sigma > 0
            stability = "Unstable";
        else
            stability = "Marginal";
        end

        if omega == 0

            mode_type = "Real mode (non-oscillatory)";
            tau = -1/sigma;

            analysis_text = analysis_text + ...
                sprintf("Pole %d : %8.4g\n",i,sigma) + ...
                sprintf("  Type      : %s\n",mode_type) + ...
                sprintf("  Stability : %s\n",stability) + ...
                sprintf("  TimeConst : %.4f s\n\n",tau);

        else

            mode_type = "Oscillatory mode";
            freq = abs(omega)/(2*pi);

            analysis_text = analysis_text + ...
                sprintf("Pole %d : %8.4g %+8.4gj\n",i,sigma,omega) + ...
                sprintf("  Type      : %s\n",mode_type) + ...
                sprintf("  Stability : %s\n",stability) + ...
                sprintf("  Damping ζ : %.4f\n",zeta(i)) + ...
                sprintf("  NatFreq ωn: %.4f rad/s\n",wn(i)) + ...
                sprintf("  Frequency : %.4f Hz\n\n",freq);

        end
    end

    disp(analysis_text)

    % Plot result
    plot_pz(sys, sprintf("NoDFF-Plant-%ddeg", Angle), t, pos, analysis_text);
    
    % ===== SAVE RESULT FOR COMPARISON =====
    results(k).Angle = Angle;
    results(k).Poles = poles;
    results(k).Zeta = zeta;
    results(k).Wn = wn;
end

%% Save results for later plotting
save("nodff_experiment_results.mat","results")

%% ===== FUNCTION =====
function plot_pz(sys, plot_title, t, pos, analysis_text)

p = pole(sys);
z = zero(sys);

figure('Name',plot_title,'Position',[200 100 1200 650])

%% ================= Pole-Zero Map =================
subplot(2,2,[1 2])
hold on
grid on
box on

all_real = [real(p); real(z)]; 

x_min = min(all_real)-50; 
x_max = max(all_real)+50; 
y_min = -100; 
y_max = 100; 

xlim([x_min x_max]) 
ylim([y_min y_max]) 

% stable region 
patch([x_min 0 0 x_min],[y_min y_min y_max y_max],... 
    [0.8 0.9 0.8],'EdgeColor','none','FaceAlpha',0.4) 

% unstable region 
patch([0 x_max x_max 0],[y_min y_min y_max y_max],... 
    [0.9 0.8 0.8],'EdgeColor','none','FaceAlpha',0.4) 

plot([0 0],[y_min y_max],'k','LineWidth',1.5) 
plot([x_min x_max],[0 0],'k','LineWidth',1)

% poles / zeros
plot(real(p),imag(p),'bx','MarkerSize',10,'LineWidth',2)
plot(real(z),imag(z),'ro','MarkerSize',10,'LineWidth',2)

xlabel("Real Axis")
ylabel("Imaginary Axis")
title("Pole-Zero Map")

%% ===== ZOOM AREA (Ellipse) =====

idx = real(p) > -1000; 
p_ = p(idx); 

if ~isempty(p_) 
    cx = (real(p_(1)) + real(p_(2))) / 2; 
    cy = (imag(p_(1)) + imag(p_(2))) / 2; 

    width = abs(real(p_(1)) - real(p_(2))) + 10;
    height = abs(imag(p_(1)) - imag(p_(2))) + 10;

    theta = linspace(0,2*pi,200);

    x = cx + width*cos(theta);
    y = cy + height*sin(theta);

    plot(x,y,'r','LineWidth',2)
end

%% ================= Zoom Plot =================

axes('Position',[0.72 0.80 0.20 0.15])
hold on
grid on
box on

x_min = cx-width; 
x_max = cx+width; 
y_min = -height; 
y_max = height; 

xlim([x_min x_max]) 
ylim([y_min y_max]) 

% stable region 
patch([x_min 0 0 x_min],[y_min y_min y_max y_max],... 
    [0.8 0.9 0.8],'EdgeColor','none','FaceAlpha',0.4) 

% unstable region 
patch([0 x_max x_max 0],[y_min y_min y_max y_max],... 
    [0.9 0.8 0.8],'EdgeColor','none','FaceAlpha',0.4) 

plot([0 0],[y_min y_max],'k','LineWidth',1.5) 
plot([x_min x_max],[0 0],'k','LineWidth',1)

plot(real(p),imag(p),'bx','MarkerSize',8,'LineWidth',2)
plot(real(z),imag(z),'ro','MarkerSize',8,'LineWidth',2)

title("Zoom",'FontSize',8)
set(gca,'FontSize',8)

%% ================= Position Response =================
subplot(2,2,3)

plot(t,pos,'LineWidth',2)
grid on

xlabel("Time (s)")
ylabel("Position (deg)")
title("Position Response")

%% ================= Pole Analysis =================
subplot(2,2,4)
axis off

text(0,1,analysis_text,...
    'FontName','Consolas',...
    'FontSize',10,...
    'VerticalAlignment','top')

%% ================= Save =================

if ~exist("pic","dir")
    mkdir("pic")
end

filename = "pic/" + plot_title + ".png";
exportgraphics(gcf,filename,'Resolution',300)

end