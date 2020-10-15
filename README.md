Code to create a UDP interface to my double pendulum controller, which is based on an mbed STM32f746 board with ethernet. 

The PendulumController class provides a bunch of functionality specific to controlling my single/double pendulum - cart, including homing, parameter estimation and a bit of safety code to prevent driving into the end stops at full speed.

Matlab's built-in TCP/IP functionality seems to open and close a socket for each packet sent, which results in very slow throughput. To solve this, I use a compiled MEX library, based on https://github.com/stefslon/mexMulticastRX, which keeps the socket open, allowing packets to sent/received at up to 2kHz. 

I don't intend to document this any further because it's so specific to my project, but if you're looking for a way to do fast UDP from Matlab, I suggest beginning with that library.