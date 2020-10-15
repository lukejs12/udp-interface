function rxPacket = udpReceive(udpHandle) %#ok<INUSD,STOUT>
%
%   Receive one UDP packet through persistent UDP socket opnned with
%   udpOpen command.
%
%   Inputs:
%       Handle      handle to openned UDP connection
%
%   Outputs:
%       packet      received UDP packet, made up of an array of uint8
%                   values. If nothing was received after timeout time, 
%                   function will return null set
%
%   Note udpReceive will block until either a packet is received or a
%   timeout value reached.
%
%   Example:
%       % Receive a single packet
%       rxPkt   = udpReceive(udpH);

%% Auto-compile
try
    mex udpReceive.cpp UdpClient.cpp
catch
    error('Could not automatiacally compile udpReceive MEX file.');
end