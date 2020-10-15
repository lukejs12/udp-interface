DURATION = 30;      % s
FREQUENCY = 200;    % Hz
T = 1/FREQUENCY;    % s

disp('Record pendulum trajectories (zero torque)');
input('Hit return to proceed');
disp(['Recording (' num2str(DURATION) 's)']);
% [~, ~, ~, ~, ~, ~] = interface.sendPacket(interface.CMD_DISABLE, 0);

x_traj = zeros(7, (DURATION)/T);
% Motor off
[theta, theta_dot, enabled, homed, estop, limit, t_limit] = interface.sendPacket(interface.CMD_DISABLE, 0);

i=1;
t = 0;
t_nom = 0;
t_start = tic;
while t < DURATION
    t_nom = t_nom + T;
    while toc(t_start) < t_nom; end
    t = toc(t_start);
    % Get state
    [theta, theta_dot, enabled, homed, estop, limit, t_limit] = interface.sendPacket(interface.CMD_NULL, 0);
    x_traj(:, i) = [t, theta-interface.ThetaZero', theta_dot].';
    i = i + 1;
%     disp(num2str(t));
%     disp(num2str(theta_dot(1)));
end

% Plot data
figure;
plot(x_traj(1, :), x_traj(3, :), x_traj(1, :), x_traj(4, :));
ylabel('Angle (rad)');
xlabel('Time (s)');
title('Pendulum angle vs time');
legend('Theta1', 'Theta2');
grid on;

g = 9.81;
inp = input('Which pendulum configuration - [l]ong, pendulum [1] or pendulum [2]? ', 's');
switch inp
    case lower('L')
        disp('Single long pendulum');
        x = x_traj(3, :);
        t = x_traj(1, :);
        % Work out damping
        % Long pendulum formed by clamping two pendulums at 2nd joint
        m_r = 0.17722;      % Mass of pendulum
        l_r = 0.26446;      % axis to com distance
        I = 0.01968578867;  % Moment of inertia about axis
    case lower('1') 
        disp('Pendulum 1 (with 1-2 axle!)');
        x = x_traj(3, :);
        xtraj = x_traj([3 6], :);
        t = x_traj(1, :);
        % Work out damping
        % Long pendulum formed by clamping two pendulums at 2nd joint
        m_r = 0.12206;      % Mass of pendulum
        l_r = 0.16677;      % axis to com distance
        I = 0.00590790108;  % Moment of inertia about axis
    case lower('2')
        disp('Pendulum 2 (only)');
        x = x_traj(4, :);
        xtraj = x_traj([4 7], :);
        t = x_traj(1, :);
        % Work out damping
%         m_r = 0.05643;      % Mass of pendulum
%         l_r = 0.14906;      % axis to com distance
%         I = 0.00218414160;  % Moment of inertia about axis
        m_r = 0.05902;      % Mass of pendulum
        l_r = 0.15287;      % axis to com distance
        I = 0.00236717303;  % Moment of inertia about axis
    otherwise
        disp('No damping calculation');
        return;
end
% Get these parameters in to canonical damped simple harmonic oscillator form
% 'Spring stiffness'
k_c = m_r*g*l_r;
% 'mass' (inertia)
m_c = I;
% Natural frequency
omega_n_c = sqrt(k_c/m_c);

% Now, try and find the damping from the data!
[pks, locs] = findpeaks(x);
maxPeaks = 8;
if length(pks) > maxPeaks
    pks = pks(1:maxPeaks);
    locs = locs(1:maxPeaks);
end
hold on;
plot(t(locs), pks, 'r*');
tau_n = t(locs(end)) - t(locs(1));
% omega_d_r = 2*pi*tau_n/length(locs)
c = (2*sqrt(k_c*m_c)*log(pks(1)/pks(end)))/(sqrt(k_c/m_c)*tau_n);
disp(['Damping = ' num2str(c) ' kg m2 / s']);

% Now plot pendulum motion using this damping value to see match
x0 = x(:, locs(1));
zeta_c = c/(2*sqrt(k_c*m_c));
phi = 0;

x_ode = pks(1)*exp(-zeta_c*omega_n_c*t).*cos(omega_n_c*t*sqrt(1-zeta_c^2) + phi);
t_ode = t + t(locs(1));
plot(t_ode, x_ode, 'c.');
text(max(t_ode)*2/3, max(x_ode)*2/3, [' c=' num2str(c) ' kg m2 / s'])

% Now try ode fitting - viscous damping
ode = @(t, x, p_fit) [x(2); -(1/I)*(p_fit*x(2)+m_r*g*l_r*sin(x(1)))];
optFit(ode, 0, t, xtraj, {'b2'});

% Fit friction model
mu = @(qd, gamma) gamma(1)*(tanh(gamma(2)*qd - tanh(gamma(3)*qd))) + ...
    gamma(4)*tanh(gamma(5)*qd) + gamma(6)*qd;
ode = @(t, x, gamma) [x(2); -(1/I)*(1*mu(x(2), gamma)+m_r*g*l_r*sin(x(1)))];
gamma = optFit(ode, [.1 .1 .1 .1 .1 .1], t, xtraj, {'g1', 'g2', 'g3', 'g4', 'g5', 'g6'});
v_max = 2*max(abs(xtraj(2,:)));
v = -v_max:0.01:v_max;
mu_v = mu(v, gamma);
figure;
plot(v, mu_v);
grid on;
xlabel('Velocity (rad/s)');
ylabel('Friction coefficient');
title('Modelled friction coefficient (friction only)');

% Fit friction model and moment of inertia
mu = @(qd, gamma) gamma(1)*(tanh(gamma(2)*qd - tanh(gamma(3)*qd))) + ...
    gamma(4)*tanh(gamma(5)*qd) + gamma(6)*qd;
ode = @(t, x, gamma) [x(2); -(1/gamma(7))*(1*mu(x(2), gamma(1:6))+m_r*g*l_r*sin(x(1)))];
param = optFit(ode, [.1 .1 .1 .1 .1 .1 0.00590790108], t, xtraj, {'g1', 'g2', 'g3', 'g4', 'g5', 'g6', 'I'});
gamma = param(1:6);
v_max = 4*max(abs(xtraj(2,:)));
v = -v_max:0.01:v_max;
mu_v = mu(v, gamma);
figure;
plot(v, mu_v);
grid on;
xlabel('Velocity (rad/s)');
ylabel('Friction coefficient');
title('Modelled friction coefficient (friction and inertia)');

