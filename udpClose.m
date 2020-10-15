function udpClose(udpHandle) %#ok<INUSD>
%
%   Closes persistent UDP socket.
%
%   Inputs:
%       Handle      handle to UDP connection to be closed
%
%   Outputs:
%       There are not outputs in this function.
%       
%   Note that clearing udpHandle variable automatically calls udpClose
%   function, which closes given UDP connection.
%
%   Example:
%       udpClose(udpHandle);

%% Auto-compile
try
    mex udpClose.cpp UdpClient.cpp
catch
    error('Could not automatiacally compile udpClose MEX file.');
end
