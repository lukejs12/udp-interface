% Bit of debugging code to check we don't lose encoder ticks during fast
% cart moves.
while true
    [theta, theta_dot, enabled, homed, estop, limit, t_limit] = interface.sendPacket(interface.CMD_NULL, 0);
    t = tic;
    while toc(t) < 0.5; end
    disp([num2str(theta(1)) ' ' num2str(theta(1)/(2*pi)) ' ' num2str(interface.PULLEY_RAD*theta(1))]);
end