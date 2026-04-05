%% Run parameter scripts
clear
close all
addpath("D:\University\Control\LAB\FRA233_Lab2_Control_System_Designing")

run("Lab2_params_student.m")
run("config.m")

model = "Lab2_single_loop_controller_student";
load_system(model);

%% Create folder
save_folder = "results";
if ~exist(save_folder,'dir')
    mkdir(save_folder)
end

%% ===== LOOP =====
for k = 1:length(Kp_list)
    Kp = Kp_list(k);
    assignin('base','Kp',Kp);

    for i = 1:length(references)
        reference = references(i);
        assignin('base','reference',reference);   % send to Simulink workspace
    
        %% Run simulation
        simOut = sim(model);
    
        %% Extract signal
        data = simOut.logsout;
        pos = data.getElement('position [deg]');
    
        t = pos.Values.Time;
        y = pos.Values.Data;
    
        %% Step characteristics
        info = stepinfo(y,t);
    
        percent_overshoot = info.Overshoot;
        peak_time = info.PeakTime;
        settling_time = info.SettlingTime;
        peak_value = info.Peak;
    
        %% Steady state
        steady_state = y(end);
        steady_state_error = abs(reference - steady_state);
    
        %% ±2% band
        upper_band = reference * 1.02;
        lower_band = reference * 0.98;
    
        %% Plot
        figure('Color','white')
        hold on
        grid on
        box on
    
        fill([t(1) t(end) t(end) t(1)], ...
             [lower_band lower_band upper_band upper_band], ...
             [0.9 0.9 0.9], ...
             'EdgeColor','none')
    
        plot(t,y,'LineWidth',2)
        yline(reference,'--k','LineWidth',1.5)
    
        yline(steady_state,'--r','LineWidth',1.5)
    
        plot(peak_time,peak_value,'o','MarkerFaceColor',[0.85 0.33 0.1])
    
        xline(peak_time,'--','Color',[0.85 0.33 0.1])
        xline(settling_time,'--','Color',[0.2 0.6 0.2])
    
        xlabel('Time (s)')
        ylabel('Position (deg)')
        title(sprintf('%s Step Response (%s)', Block, Kp_names(k)))
    
        %% Performance box
        annotation('textbox',[0.60 0.25 0.25 0.25],...
        'String',sprintf(['Performance Metrics\n\n' ...
        'Overshoot = %.2f %%\n' ...
        'Peak Value = %.2f deg\n' ...
        'Peak Time = %.2f s\n' ...
        'Settling Time = %.2f s\n' ...
        'Steady-State Value = %.2f deg\n' ...
        'Steady-State Error = %.4f\n\n' ...
        'Controller Parameters\n' ...
        'Kp = %.6f\n' ...
        'Reference = %.2f deg'], ...
        percent_overshoot, peak_value, peak_time, settling_time, ...
        steady_state, steady_state_error, Kp, reference),...
        'FitBoxToText','on',...
        'BackgroundColor','white',...
        'EdgeColor',[0.4 0.4 0.4]);
    
        %% Save figure
        filename = sprintf("%s/%s_%s_ref_%d.png", ...
            save_folder, Block, Kp_names(k), reference);

        exportgraphics(gcf,filename,'Resolution',300)
        close(gcf)
 
    end
end