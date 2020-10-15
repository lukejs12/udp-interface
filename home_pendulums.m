% PID loop to home pendulums

T_MAX = 0.1;            % Nm
V_SET = 50;%25.6128;    % mm/s
PULLEY_RAD = 30.60/2;   % mm
FREQUENCY = 500;        % Hz
T = 1/FREQUENCY;        % s
TIMEOUT = 20;           % s
P = .0008;
I = .000001;
D = -.00000001;

t = tic;
elapsed_time = 0;
[theta, theta_dot, enabled, homed, estop, limit] = interface.sendPacket(interface.CMD_ENABLE, 0);
lpos = theta(1);
err_delta = 0;
err_sum = 0;
while limit ~= true && elapsed_time < TIMEOUT
    while toc(t) < T; end
    t = tic;
    % Get system state
    [theta, theta_dot, ~, ~, ~, ~] = interface.sendPacket(interface.CMD_NULL, 0);
    % Calculate cart position
    pos = theta(1)*PULLEY_RAD;
%     cmpvel = (pos-lpos)/T;
%     lpos = pos;
    % Calculate cart velocity
    ctrvel = theta_dot(1)*PULLEY_RAD;
    % Cart velocity error
    err = V_SET - ctrvel;
    err_sum = err_sum + err;
    err_dot = err - err_delta;
    % calculate PD torque
    torque = P*err + D*err_delta + I*err_sum;
    % Cap max torque
    if torque > T_MAX
        torque = T_MAX;
    elseif torque < -T_MAX
        torque = -T_MAX;
    end
    
    % Save this error
    err_delta = err;
    % Send torque
    [theta, theta_dot, enabled, homed, estop, limit] = interface.sendPacket(interface.CMD_TORQUE, torque);
%     disp(['H: ' num2str(homed) ', L: ' num2str(limit) ', p: ' num2str(pos) ', v: ' num2str(ctrvel) 'mm/s, T: ' num2str(torque) 'Nm, theta: [' num2str(theta(1)) ' ' num2str(theta(2)) ' ' num2str(theta(3)) ' ']);
%     disp(['vel: ' num2str(ctrvel) ', err: ' num2str(err) ', t: ' num2str(torque)]);
    elapsed_time = elapsed_time + T;
end
% Turn off motor
[~, ~, ~, ~, ~, ~] = interface.sendPacket(interface.CMD_DISABLE, 0);
if elapsed_time >= TIMEOUT
    disp('Timed out while homing!');
    return;
end

disp('Limit switch found - waiting for pendula to stop swinging');
rates_hist = ones(2, 50);
zero_rates = false;
elapsed_time = 0;
i = 1;
t = tic;
while zero_rates ~= true && elapsed_time < TIMEOUT
    while toc(t) < T; end
    elapsed_time = elapsed_time + T;
    % Get system state
    [theta, theta_dot, enabled, homed, estop, limit] = interface.sendPacket(interface.CMD_NULL, 0);
%     disp(['2, 3: [' num2str(theta_dot(2)) ', ' num2str(theta_dot(3)) ']']);
    rates_hist(:, i) = abs(theta_dot(2:3).');
    i = i+1;
    if i > length(rates_hist) 
        i = 1;
    end
    avg_rates = mean(rates_hist, 2);
    if avg_rates < [0.000001; 0.000001]
        theta_zero = [0 theta(2:3)];
        zero_rates = true;
    end
end
disp('Homing complete');
if elapsed_time >= TIMEOUT
    disp('Timed out while homing!');
end
