% udp packet testing with stm32f746zg mbed
clear variables

% Commands
CMD_HOME    = 1;
CMD_ENABLE  = 2;
CMD_DISABLE = 3;
CMD_TORQUE  = 4;
CMD_NULL    = 5;
COMMAND_LENGTH = 9; 
% Number of bytes in a command
% 1   Command
% 2-9 Double
STATE_ENABLED = 1;
STATE_ESTOP = 2;
STATE_LIMIT = 4;
STATE_HOMED = 8;


% These two parameters are ignored - need to address/fix
MC_IP   = '224.0.0.0';
MC_PORT = 1024;
h = udpOpen(MC_IP, MC_PORT, 20)
% % Port client is expecting to receive on
% remotePort = 57185;
% % Local port we'll listen on
% localPort = 59000;
% % Create UDP socket on broadcast IP
% socket = udp('255.255.255.255', remotePort, 'LocalPort', localPort);
% % Create callback function to receive packets
% socket.DatagramReceivedFcn = @readDatagram;
% % Open socket
% fopen(socket);
% % Send ID packet to client
% fwrite(socket, [uint8(1) uint8(23) typecast(uint16(localPort), 'uint8')])
% % Wait for reply with correct signature
% while(~strcmp(data, 'ping'))
% end

% % Change socket remoteIP
% socket.RemoteHost = remoteIP
% socket.DatagramReceivedFcn = @readDatagram;

% % Close socket and reopen with client IP (not broadcast IP)
% fclose(socket);
% socket = udp(remoteIP, remotePort, 'LocalPort', localPort);
% socket.DatagramReceivedFcn = @readDatagram;
% fopen(socket);

% NumPackets = 1000;
NumPackets = 2000;
timings = zeros(1, NumPackets);
disp('Waiting 1s');
pause(1);
disp('Starting');
command = [CMD_ENABLE, typecast(0, 'uint8')];
% command = [CMD_HOME, typecast(0, 'uint8')];
val = UdpSend(h, command);
uint8(udpReceive(h)');  % Throw away reply
for i = 1:NumPackets
    startTime = tic;
    torque = 0;%i*.01;
    command = [CMD_HOME, typecast(0, 'uint8')];
    val = UdpSend(h, command);
    val = uint8(udpReceive(h)');
    timings(i) = toc(startTime);
    
%     for i=1:3
%         theta(i) = typecast(val((i-1)*8+1:(i-1)*8+8), 'double');
%         theta_dot(i) = typecast(val((i-1)*8+1+24:(i-1)*8+8+24), 'double');
%         bits = val(25);
%     end
%     
%     theta*180/pi
%     theta_dot*180/pi
%     pause(.2);
end

% for torque = -0.1:.01:0.1
%     command = [CMD_TORQUE, typecast(torque, 'uint8')];
%     val = UdpSend(h, command);
%     val = uint8(udpReceive(h)');
%     for i=1:3
%         theta(i) = typecast(val((i-1)*8+1:(i-1)*8+8), 'double');
%         theta_dot(i) = typecast(val((i-1)*8+1+24:(i-1)*8+8+24), 'double');
%         bits = val(25)
%     end
%     disp(['theta: '  num2str(theta*180/pi)]);
%     disp(['theta_dot: '  num2str(theta_dot*180/pi)]);
% %     theta*180/pi
% %     theta_dot*180/pi
%     pause(0.2);
% end


command = [CMD_DISABLE, typecast(0, 'uint8')];
val2 = UdpSend(h, command);

disp(['Mean freq: ' num2str(1/mean(timings)) ' Hz'])
disp(['Mean latency: ' num2str(mean(timings)*1000) ' ms'])
udpClose(h)

