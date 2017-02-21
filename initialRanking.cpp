#include "mex.h"
#include "string.h"
#include "math.h"
#include <ctime>
#include <fstream>
#include <iostream>
#include <sstream>
#include <ctime>
#include <stdio.h>


#define IS_REAL_2D_FULL_SINGLE(P) (!mxIsComplex(P) && mxGetNumberOfDimensions(P) == 2 && !mxIsSparse(P) && mxIsSingle(P))

void mexFunction(int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[])
{
#define OUTPUT plhs[0]
        
    unsigned int cw, wt, *npts, trhist, st, en, len_f;
    int start_s, stop_s;
    unsigned int *tsthist, *idfs, *cwt, *allwords, *allhist;
    double *cumsum;
    float *scores;
    
    if(nlhs!=1) {
        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nlhs",
                "One output required.");
    }    
    
    /* input params */
    cwt = (unsigned int *) mxGetData(prhs[0]);
    tsthist = (unsigned int *) mxGetData(prhs[1]);
    npts = (unsigned int *) mxGetData(prhs[2]);
    len_f =  mxGetScalar(prhs[3]);
    st =  mxGetScalar(prhs[4]);
    en =  mxGetScalar(prhs[5]);     
    allwords = (unsigned int *) mxGetData(prhs[6]); 
    allhist = (unsigned int *) mxGetData(prhs[7]); 
    cumsum = (double *) mxGetData(prhs[8]); 
    int noimgs = en-st+1;

    /*create output */
    const mwSize os[] = {1, noimgs};
    OUTPUT = mxCreateNumericArray(2, os, mxSINGLE_CLASS, mxREAL);
    scores  = (float *) mxGetData(OUTPUT);    
    
    for(int trno=st; trno<=en; trno++)
    {            
        float summ=0;        
        for(int j=0;j<npts[trno-1];j=j+1)
          {  
              unsigned long int k = cumsum[trno-1]+j;
              cw = allwords[k];
              trhist = allhist[k];
              wt = cwt[k];
              if(tsthist[cw]==0)
                continue;              
              summ+=(float)(wt)/(float)(trhist*tsthist[cw]);               
          }
        scores[trno-st] = (float)(summ);        
    }
    
    return;
}
