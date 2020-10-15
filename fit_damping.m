DURATION = 3;
FREQUENCY = 100;    % Hz
T = 1/FREQUENCY;    % s

disp('Fit damping and cart effective mass');
input('Hit return to proceed (system will move)');
% [~, ~, ~, ~, ~, ~] = interface.sendPacket(interface.CMD_DISABLE, 0);

% Create controller
u = @(t) 4*sin(1*2*pi*t);

traj = zeros(7, (DURATION)/T);
disp('Seeking cart position 0');
interface.seek(0);
% Motor on - seek() disables it after move complete
[theta, theta_dot, enabled, homed, estop, limit, t_limit] = interface.sendPacket(interface.CMD_ENABLE, 0);

disp('Poking cart');


i=1;
t = 0;
t_nom = 0;
t_start = tic;
while t < DURATION
    t_nom = t_nom + T;
    while toc(t_start) < t_nom; end
    t = toc(t_start);
    % Send force
    torque = u(t) * (interface.PULLEY_RAD*.001);
    [theta, theta_dot, ~, ~, ~, ~, ~] = interface.sendPacket(interface.CMD_TORQUE, torque);
    x = interface.convertRawState([theta theta_dot]');
    % Get state
%     [theta, theta_dot, enabled, homed, estop, limit, t_limit] = interface.sendPacket(interface.CMD_NULL, 0);
    traj(:, i) = [t; x];
    i = i + 1;
end

% Now try and fit unknown variables
m1 = 0.24463;
b1 = 4.5539;      % fmincon parameter fitting estimate
c2 = 0.16951;
l2 = 0.3;
m2 = 0.12038 ;
b2 = 0.021574;    % fmincon parameter fitting estimate
I2 = 0.0024633516;
g = 9.81;




% Repackage trajectory, removing pendulum 2
xtraj = [traj(2:3, :); traj(5:6, :)];
ttraj = traj(1, :);

% SinglePendulumCart_auto(I2,b1,b2,c2,g,m1,m2,q1_dot,q2,q2_dot,u)
% Fit damping and cart/belt/pulley/motor mass
ode = @(t, x, p_fit) [x(3:4); SinglePendulumCart_auto(I2,p_fit(1),p_fit(2),c2,g,p_fit(3),m2,x(3),x(2),x(4),u(t))];
optFit(ode, [0 0 0], ttraj, xtraj, {'b1', 'b2', 'm1'});

% Fit damping only
ode = @(t, x, p_fit) [x(3:4); SinglePendulumCart_auto(I2,p_fit(1),p_fit(2),c2,g,m1,m2,x(3),x(2),x(4),u(t))];
optFit(ode, [0 0], ttraj, xtraj, {'b1', 'b2'});

% Fit everything!
ode = @(t, x, p_fit) [x(3:4); SinglePendulumCart_auto(p_fit(1),p_fit(2),p_fit(3),p_fit(4),g,p_fit(5),p_fit(6),x(3),x(2),x(4),u(t))];
optFit(ode, [0 0 0 0 0 0], ttraj, xtraj, {'I2', 'b1', 'b2', 'c2', 'm1', 'm2'});


% % Plot data
% figure;
% plot(x_traj(1, :), x_traj(3, :), x_traj(1, :), x_traj(4, :));
% ylabel('Angle (rad)');
% xlabel('Time (s)');
% title('Pendulum angle vs time');
% legend('Theta1', 'Theta2');
% grid on;
% 
% 
% 
% 
