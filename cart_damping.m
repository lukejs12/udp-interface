TORQUE = -0.075;      % Nm
TIMEON = 0.3;        % s
TIMEOFF = 2;       % s
FREQUENCY = 200;    % Hz
T = 1/FREQUENCY;    % s

disp('WARNING: This will apply a constant torque to the motor. WEAR GOGGLES!');
disp('');
yn = input('Are you sure you wish to proceed Y/[N]', 's');
if yn ~= 'y' && yn ~= 'Y'
    return;
end
input('Hit return to proceed with test - MOTOR WILL SPIN');
[~, ~, ~, ~, ~, ~] = interface.sendPacket(interface.CMD_ENABLE, 0);

x_traj = zeros(7, ceil((TIMEON+TIMEOFF)/T));
% Send fixed on torque
[theta, theta_dot, enabled, homed, estop, limit] = interface.sendPacket(interface.CMD_TORQUE, TORQUE);

i=1;
t = 0;
t_nom = 0;
t_start = tic;
while t < TIMEON
    t_nom = t_nom + T;
    while toc(t_start) < t_nom; end
    t = toc(t_start);
    % Get state
%     [theta, theta_dot, enabled, homed, estop, limit] = interface.sendPacket(interface.CMD_NULL, 0);
    [theta, theta_dot, enabled, homed, estop, limit, t_limit] = interface.sendPacket(interface.CMD_TORQUE_OVERRIDE, TORQUE);
    x_traj(:, i) = [t theta theta_dot].';
    i = i + 1;
%     disp(num2str(t));
%     disp(num2str(theta_dot(1)));
end
% Zero torque
[~, ~, ~, ~, ~, ~, ~] = interface.sendPacket(interface.CMD_TORQUE, 0);

% elapsed_time = 0;
while t < (TIMEOFF+TIMEON)
    t_nom = t_nom + T;
    while toc(t_start) < t_nom; end
    t = toc(t_start);
    % Get state
    [theta, theta_dot, enabled, homed, estop, limit, t_limit] = interface.sendPacket(interface.CMD_NULL, 0);
    x_traj(:, i) = [t theta theta_dot].';
    i = i + 1;
%     disp(num2str(t));
%     disp(num2str(theta_dot(1)));
end
% Disable motor
[~, ~, ~, ~, ~, ~, ~] = interface.sendPacket(interface.CMD_DISABLE, 0);
% Plot data
figure;
t = x_traj(1, :);
x = -x_traj(2, :)*interface.PULLEY_RAD;
plot(t, x);
ylabel('Cart position (mm)');
xlabel('Time (s)');
title(['Torque = ' num2str(-TORQUE) ' Nm for ' num2str(TIMEON) ' s']);
grid on;
hold on;
torque_off_idx = TIMEON/T+1;
plot(linspace(t(torque_off_idx), t(torque_off_idx), 50), linspace(0, max(x), 50), 'c.');

% Now just look at the unpowered period
% Reset to t=0 as torque turned off
t = x_traj(1, TIMEON/T+1:end)-x_traj(1, TIMEON/T+1);
x = -x_traj(2, TIMEON/T+1:end)*interface.PULLEY_RAD;
figure;
title(['Torque = ' num2str(-TORQUE) ' Nm for ' num2str(TIMEON) ' s']);
hold on;
grid on;
plot(t, x);
C1 = max(x);
C2 = x(1) - C1;
idx = round(length(t)/2);
c_m = -log((x(idx)-C1)/C2)/t(idx);
% plot(t, C1 + C2*exp(-c_m.*t), 'c');

% Now a different approach - fit the best exponential curve using
% optimisation
[~, span] = max(x);
f = @(p, t) p(1) + p(2).*exp(-p(3).*t);
P = fminsearch(@(b) norm(x - f(b, t)), [max(x) -1 1]);

% Motor/pulley inertia
I_m = 5.7e-5;
% Equivalent mass of motor/pulley
m_m = I_m/interface.PULLEY_RAD^2;

% % Mass of cart-double pendulum assembly
% m_c = 0.43502;
% disp('Assuming cart and double pendulum system');

% Mass of cart-single pendulum assembly
m_c = 0.40507;  % Updated 9/1/20
disp('Assuming cart and single pendulum system (with 1-2 axle)');

% % Mass of cart only system
% m_c = 0.24463;
% disp('Assuming cart-only system');

% Total mass
m_t = m_m + m_c;

plot(t, f(P, t), '-r');
c = P(3)*m_t;
str = ['Total cart/belt damping c = ' num2str(c) ' kg/s'];
disp(str);

% % Idiot check
% ft = @(t) P(1) + P(2)*exp(-P(3).*t);
% plot(t, ft(t), ':k');

legend('Recorded trajectory', 'Best fit');
text(max(t)/3, max(f(P, t))*2/3, str);



% 
% % Try and calculate inertia automatically (ignoring damping)
% x = x_traj(5, :);
% t = x_traj(1, :);
% [pks, locs] = findpeaks(x);
% plot(t(locs(1)), pks(1), 'xr');
% span = round(2*locs(1)/3);
% p = polyfit([t(1) t(span)], [x(1) x(span)], 1);
% plot(t(1:span), polyval(p, t(1:span)), 'c.');
% % Gradient of straight line during acceleration is angular acceleration.
% % Ignoring damping, inertia is torque / acceleration
% I = TORQUE/p(1);
% str = ['Motor / pulley inertia estimate: ' num2str(I) ' kg m^2']; 
% text(0.5*max(t), 0.7*max(x), str);
% disp(str);