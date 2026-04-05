clear
addpath("D:\University\Control\LAB\FRA233_Lab2_Control_System_Designing")

run("Lab2_params_student.m")
run("config.m")

model = "Lab2_cascade_controller_student";
load_system(model);

save_folder = "results";
if ~exist(save_folder,'dir')
    mkdir(save_folder)
end

nCase = length(Kp_pos_list);

for index = 1:nCase

    fprintf("Running case: %s\n", K_names(index));

    %% ===== Assign gains =====
    Kp_pos_i = Kp_pos_list(index);
    Ki_pos_i = Ki_pos_list(index);
    Kd_pos_i = Kd_pos_list(index);
    N_pos_i = N_pos_list(index);

    Kp_vel_i = Kp_vel_list(index);
    Ki_vel_i = Ki_vel_list(index);
    Kd_vel_i = Kd_vel_list(index);
    N_vel_i = N_vel_list(index);

    assignin('base','Kp_pos',Kp_pos_i);
    assignin('base','Ki_pos',Ki_pos_i);
    assignin('base','Kd_pos',Kd_pos_i);
    assignin('base','N_pos',N_pos_i);

    assignin('base','Kp_vel',Kp_vel_i);
    assignin('base','Ki_vel',Ki_vel_i);
    assignin('base','Kd_vel',Kd_vel_i);
    assignin('base','N_vel',N_vel_i);

    %% ===== Run simulation =====
    simOut = sim(model);
    data = simOut.logsout;

    %% Extract signals
    
    pos = data.getElement('position [rad]');
    vel = data.getElement('velocity [rad/s]');
    
    ref_pos = data.getElement('ref_q [rad]');
    ref_vel = data.getElement('ref_qd [rad/s]');
    
    t = pos.Values.Time;
    
    y_pos = squeeze(pos.Values.Data);
    y_vel = squeeze(vel.Values.Data);
    
    r_pos = squeeze(ref_pos.Values.Data);
    r_vel = squeeze(ref_vel.Values.Data);
    
    %% ===== POSITION OVERSHOOT =====
    
    segments_pos = [0 3; 3 6];   % [start end]
    overshoot_pos_all = zeros(size(segments_pos,1),1);
    
    for k = 1:size(segments_pos,1)
    
        idx = (t >= segments_pos(k,1)) & (t <= segments_pos(k,2));
        r = r_pos(idx);
        y = y_pos(idx);
    
        if k == 1
            % upward motion
            ref  = max(r);
            peak = max(y);
            overshoot_pos_all(k) = max(0,(peak - ref)/ref*100);
        else
            % downward motion
            ref  = r(end);
            peak = min(y);
            overshoot_pos_all(k) = max(0,(peak - ref)/abs(ref)*100);
        end
    
    end
    
    overshoot_pos = max(overshoot_pos_all);
    
    %% ===== VELOCITY OVERSHOOT =====
    
    segments_vel = [
    0   1
    1   2.5
    2.5 4
    4   5.5
    ];
    
    overshoot_vel_all = zeros(size(segments_vel,1),1);
    eps_ref = 1e-6;   % small number to avoid divide-by-zero
    
    for k = 1:size(segments_vel,1)
    
        idx = (t >= segments_vel(k,1)) & (t <= segments_vel(k,2));
    
        r = r_vel(idx);
        y = y_vel(idx);
    
        ref_peak = max(abs(r));
    
        % skip segments where reference velocity is ~0
        if ref_peak < eps_ref
            continue
        end
    
        out_peak = max(abs(y));
    
        overshoot_vel_all(k) = max(0,(out_peak - ref_peak)/ref_peak*100);
    
    end
    
    overshoot_vel = max(overshoot_vel_all);
    
    %% Absolute Tracking Error
    err_pos = abs(r_pos - y_pos);
    err_vel = abs(r_vel - y_vel);
    
    max_err_pos = max(err_pos);
    max_err_vel = max(err_vel);
    
    %% PASS / FAIL CHECK
    
    pass_os_vel = overshoot_vel <= REQ_OS_VEL;
    pass_err_vel = max_err_vel <= REQ_ERR_VEL;
    
    pass_os_pos = overshoot_pos <= REQ_OS_POS;
    pass_err_pos = max_err_pos <= REQ_ERR_POS;
    
    %% ===== Clean 3-Panel Visualization =====
    
    fig1 = figure('Visible','off');
    set(gcf,'Color','white')
    
    tiledlayout(3,1,'TileSpacing','compact','Padding','compact')
    
    %% ---- Position Tracking ----
    nexttile()
    hold on
    grid on
    box on
    
    plot(t,y_pos,'LineWidth',2)
    plot(t,r_pos,'--k','LineWidth',1.5)
    
    ylabel('Position (rad)')
    title('Position Tracking')
    
    legend('Output','Reference','Location','northeast')
    
    %% ---- Velocity Tracking ----
    nexttile()
    hold on
    grid on
    box on
    
    plot(t,y_vel,'LineWidth',2)
    plot(t,r_vel,'--k','LineWidth',1.5)
    
    xlabel('Time (s)')
    ylabel('Velocity (rad/s)')
    title('Velocity Tracking')
    
    legend('Output','Reference','Location','northeast')
    
    %% ---- Requirement Check Panel (Clean Horizontal) ----
    ax = nexttile();
    axis(ax,'off')
    hold(ax,'on')
    
    % Border box
    rectangle(ax,'Position',[0.05 0.20 0.90 0.60], ...
              'EdgeColor',[0.4 0.4 0.4], ...
              'LineWidth',1.5)
    
    % Title
    text(0.5,0.70,'Requirement Check', ...
        'FontSize',14, ...
        'FontWeight','bold', ...
        'HorizontalAlignment','center')
    
    passfail = ["FAIL","PASS"];
    result  = [pass_os_vel pass_err_vel pass_os_pos pass_err_pos];
    
    labels = ["Velocity Overshoot","Velocity Error", ...
              "Position Overshoot","Position Error"];
    
    xpos = [0.28 0.72 0.28 0.72];
    ypos = [0.50 0.50 0.35 0.35];
    
    for i = 1:4
    
        if result(i)
            color = [0 0.5 0];      % dark green
        else
            color = [0.75 0 0];     % dark red
        end
    
        text(xpos(i),ypos(i), ...
            sprintf('%s : %s',labels(i),passfail(result(i)+1)), ...
            'FontSize',12, ...
            'HorizontalAlignment','center', ...
            'Color',color);
    end
    
    %% ===== Error Visualization =====
    
    fig2 = figure('Visible','off');
    set(gcf,'Color','white')
    
    subplot(2,1,1)
    hold on
    grid on
    box on
    
    plot(t,err_pos,'LineWidth',2)
    yline(REQ_ERR_POS,'--r','Requirement')
    
    xlabel('Time (s)')
    ylabel('Position Error (rad)')
    title('Position Tracking Error')
    
    legend('Error','Limit')
    
    subplot(2,1,2)
    hold on
    grid on
    box on
    
    plot(t,err_vel,'LineWidth',2)
    yline(REQ_ERR_VEL,'--r','Requirement')
    
    xlabel('Time (s)')
    ylabel('Velocity Error (rad/s)')
    title('Velocity Tracking Error')
    
    legend('Error','Limit')

    
    %% ===== SAVE =====
    saveas(fig1, fullfile(save_folder, Block + "_" + K_names(index) + "_tracking.png"));
    saveas(fig2, fullfile(save_folder, Block + "_" + K_names(index) + "_error.png"));

    close(fig1)
    close(fig2)

end

disp("DONE ALL CASES")