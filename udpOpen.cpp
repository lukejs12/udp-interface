/*
 *  Open persistent UDP socket.
 *
 *  Versions:
 *      05/15/2015, Initial version
 */

#include <sys/types.h>  /* for type definitions */
#include <winsock2.h>   /* for win socket API calls */
#include <ws2tcpip.h>   /* for win socket structs */
#include <stdio.h>      /* for printf() and fprintf() */
#include <signal.h>
#include <stdlib.h>     /* for atoi() */
#include <string.h>     /* for strlen() */

#include "mex.h"
#include "matrix.h"
#include "UdpClient.h"

#include "ObjectHandle.h"

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    //char* mc_addr_str;          /* multicast IP address */
    char mc_addr_str[20];
    unsigned short mc_port;       /* multicast port */
    DWORD recvTimeout = 500;      /* timeout delay in ms */
    
    /* validate number of arguments */
    if (nrhs < 2) {
        mexErrMsgTxt("Usage: mexReceiver('<Multicast IP>',<Multicast Port>,[Timeout Delay in ms])\n");
    }
    
    if (nrhs >= 3) {
        recvTimeout = (DWORD)(*mxGetPr(prhs[2]));
    }
    
    /* validate output arguments */
    if (nlhs == 0) {
        mexErrMsgTxt("Need at least one output parameter to return received data\n");
    }
    
    mxGetString(prhs[0],mc_addr_str,20);
    mc_port = (unsigned short)*mxGetPr(prhs[1]);
    
    /* validate the port range */
    if (0) { //((mc_port < MIN_PORT) || (mc_port > MAX_PORT)) {
        printf("Invalid port number argument %d.\nValid range is between %d and %d.\n",
                mc_port,MIN_PORT, MAX_PORT);
        mexErrMsgTxt("");
    }

    /* */
    plhs[0] = create_handle(new UdpClient(mc_addr_str,mc_port,recvTimeout));
    
}

