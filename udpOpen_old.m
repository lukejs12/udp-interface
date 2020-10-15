function udpHandle = udpOpen(udpIP,udpPort,connTimeout) %#ok<INUSD,STOUT>
%
%   Opens persistent UDP socket.
%
%   Inputs:
%       IP Address  string in the format XX.XX.XX.XX
%       UDP Port    integer port number to connect to
%       Timout      [optional] timeout delay in ms. Default value is 500 ms.
%
%   Outputs:
%       Handle      handle to openned UDP connection
%
%   If connection fails, udpOpen will return a MatLab error, so best
%   practice is to encapsulate the code in try...catch block.
%
%   Note that clearing udpHandle variable automatically calls udpClose
%   function, which closes given UDP connection.
%
%   Example:
%       % Open connection to 224.0.0.0:2014 with timeout of 10 ms
%       udpH = udpOpen('224.0.0.0',2014,10);

%% Auto-compile
try
    mex udpOpen.cpp UdpClient.cpp
catch
    error('Could not automatiacally compile udpOpen MEX file.');
end
