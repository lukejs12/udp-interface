#include "mex.h"
#include "matrix.h"
#include "UdpClient.h"

#include "ObjectHandle.h"

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    
    // Validation
    if (nlhs == 0) {
        mexErrMsgTxt("Need at least one output parameter to return success/error code\n");
    }
    if (nrhs < 2) {
        mexErrMsgTxt("Insufficient input arguments. Should be: UdpSend(handle, packetBytes)\n");
    }
   
    // Grab a pointer to the buffer  
    char *buffer = (char *)mxGetData(prhs[1]); 
    unsigned int length = mxGetNumberOfElements(prhs[1]);
    if (length > BUFLEN) {
        char temp[100];
        sprintf(temp, "Packet too long. Max length %d bytes\n", BUFLEN);
        mexErrMsgTxt(temp);
    }
    UdpClient& mine = get_object<UdpClient>(prhs[0]);
    mine.sendPacket(buffer, length, &plhs[0]);
}
