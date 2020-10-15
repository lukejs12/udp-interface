#include "mex.h"
#include "matrix.h"
#include "UdpClient.h"

#include "ObjectHandle.h"

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // TODO: add input error checking
    
    destroy_object<UdpClient>(prhs[0]);
}

