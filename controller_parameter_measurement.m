clear variables;
clc;

MODEQUIT = 'Q';
MODEWAIT = 'W';
MODEHOME = 'H';
MODEINERTIA = 'I';
MODEANGDAMPING = 'A';
MODECART = 'C';
MODEFIT1 = 'F';

% [theta, theta_dot, enabled, homed, estop, limit] = interface.sendPacket(interface.CMD_NULL, 0);
% theta
% theta_dot
% disp(['Enabled: ' num2str(enabled) ', homed: ' num2str(homed) ', estop: ' num2str(estop) ', limit: ' num2str(limit)]);
% pause(0.1)
% interface.delete();

disp('Opening connection to controller');
interface = PendulumController();
% [theta, theta_dot, enabled, homed, estop, limit, torque_limit] = interface.sendPacket(interface.CMD_ENABLE, 0);

mode = lower(MODEWAIT);
while mode ~= lower(MODEQUIT)
    [theta, theta_dot, enabled, homed, estop, limit, torque_limit] = interface.sendPacket(interface.CMD_NULL, 0);
    disp(' ');
    disp('Current state');
    disp(['Homed: ' num2str(homed) '. Theta: [' num2str(theta(1)) ' ' num2str(theta(2)) ' ' num2str(theta(3)) ']']);
    disp(' ');
    disp('[H]ome - home all three encoders');
    disp('[I]nertia - accelerate motor to measure inertia');
    disp('[A]ngular damping - measure damping in rotating joints (zero torque applied)');
    disp('[C]art damping - measure the total damping in the cart / motor system');
    disp('[F]it cart and pendulum 1 damping');
    disp('[Q]uit');
    
    mode = lower(input('Choose: ', 's'));
    switch mode
        case lower(MODEHOME)
            disp('Homing');
%             mode = lower(MODEHOME);
%             home_pendulums;
            interface.home();
        case lower(MODEINERTIA) 
            disp('Motor/pulley inertia measurement');
            motor_pulley_inertia;
        case lower(MODEANGDAMPING)
            disp('Angular damping measurement');
            measure_ang_damping;
        case lower(MODECART) 
            disp('Cart damping measurement');
            cart_damping;
        case lower(MODEFIT1) 
            disp('Cart damping fitting');
            fit_damping;
        case lower(MODEQUIT)
            disp('Goodbye');
            mode = lower(MODEQUIT);
%         case lower('S')
%             disp('Sinusoidal torque - CAREFUL!!!');
%             
%             FREQUENCY = 50;        % Hz
%             T = 1/FREQUENCY;        % s
%             [theta, theta_dot, enabled, homed, estop, limit, t_limit] = interface.sendPacket(interface.CMD_ENABLE, 0);
%             t = 0;
%             t_nom = 0;
%             t_start = tic;
%             for x = 0:1/1000:5*(2*pi)
%                 t_nom = t_nom + T;
%                 while toc(t_start) < t_nom; end
%                 t = toc(t_start);
%                 [theta, theta_dot, enabled, homed, estop, limit, t_limit] = interface.sendPacket(interface.CMD_TORQUE, 0.15);
%                 disp(num2str(t_limit));
%             end
        otherwise 
            disp('Unknown input');
            mode = lower(MODEWAIT);
    end
end
% 
% 
% theta*180/pi
% theta_dot
% pause(0.1)
% for i = 1:100
%     [theta, theta_dot, enabled, homed, estop, limit] = interface.sendPacket(interface.CMD_NULL, 0);
%     theta
%     theta_dot
%     pause(0.1)
% end
interface.delete()
