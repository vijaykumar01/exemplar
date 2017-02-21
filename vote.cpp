#include "mex.h"
#include "string.h"
#include "math.h"
#include <ctime>
#include <fstream>
#include <iostream>
#include <sstream>
#include <ctime>
#include <vector>

#define IS_REAL_2D_FULL_SINGLE(P) (!mxIsComplex(P) && mxGetNumberOfDimensions(P) == 2 && !mxIsSparse(P) && mxIsSingle(P))
#define IS_REAL_SINGLE(P) (!mxIsComplex(P) && mxIsSingle(P))

bool convolve2DSeparable(float*, float*, int, int, 
                         float*, int, float*, int);

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    
    #define OUTPUT plhs[0]

    mxArray *locptr;
    unsigned long int id;
    const mxArray *invIndexTest;  
    const mwSize *nolocs, *no_scales, *noEx, *kernel_sz ;
    int os1=0;
    int os2=0;
    int noWrds=0;
    int len_f, trno, trkpt1, trkpt2, nmat_pairs, no_iters; 
    int trhist, start_s, stop_s, a, b, w, z, u, v, *tsthist;
    unsigned int *words, *npts, trw, *trids, *cwt, *thresh, * trkpts1;
    unsigned int *tr_words_all,*tr_hist_all, *trkpts2, numm;
    float *maps, *kpts, *wt, *feawt ;
    double scM, *scales, *locids, *trRowDist, *trColDist, *cumsum;    
  
     if(nlhs!=1) {
        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nlhs",
                "One output required.");
    }

    if(!IS_REAL_2D_FULL_SINGLE(prhs[2])) /*Check if keypoints are single*/
        mexErrMsgTxt("key points must be a 2D full single array.");
    
    if(!IS_REAL_SINGLE(prhs[9])) 
        mexErrMsgTxt("Weight must be a 1D full single array.");
    
    /* input */
    words = (unsigned int *) mxGetData(prhs[0]); 
    len_f =  mxGetScalar(prhs[1]);        
    kpts = (float *) mxGetData(prhs[2]);
    int kptDim = mxGetM(prhs[2]);      
    invIndexTest = prhs[3];    
    cwt = (unsigned int *) mxGetData(prhs[4]);   
    tsthist = (int *) mxGetData(prhs[5]);    
    os1 = mxGetScalar(prhs[6]);   
    os2 = mxGetScalar(prhs[7]);    
    float gs = mxGetScalar(prhs[8]);  
    float gsM = (float) 1/gs;        
    wt = (float *) mxGetData(prhs[9]);
    kernel_sz = mxGetDimensions(prhs[9]);    
    npts = (unsigned int *) mxGetData(prhs[10]);
    scales = (double *) mxGetData(prhs[11]);
    no_scales = mxGetDimensions(prhs[11]);
    trRowDist = (double *) mxGetData(prhs[12]);
    trColDist = (double *) mxGetData(prhs[13]);
    trids = (unsigned int *) mxGetData(prhs[14]);  
    noEx = mxGetDimensions(prhs[14]);    
    thresh = (unsigned int *) mxGetData(prhs[15]);
    trkpts1 = (unsigned int *) mxGetData(prhs[16]); 
    trkpts2 = (unsigned int *) mxGetData(prhs[17]);    
    feawt = (float *) mxGetData(prhs[18]);
    int feawtDim = mxGetM(prhs[18]);    
    int fddb = mxGetScalar(prhs[19]);    
    float alpha = mxGetScalar(prhs[20]);
    tr_words_all = (unsigned int *) mxGetData(prhs[21]);
    tr_hist_all = (unsigned int *) mxGetData(prhs[22]);
    cumsum = (double *) mxGetData(prhs[23]);
    noWrds = mxGetScalar(prhs[24]);   
              
    if(noEx==0) 
        mexErrMsgTxt("trids cannot be empty");

    /*  create output */
    const mwSize os[] = {os1, os2, no_scales[1]};
    OUTPUT = mxCreateNumericArray(3, os, mxSINGLE_CLASS, mxREAL);
    maps  = (float *) mxGetData(OUTPUT);        
        
    no_iters = noEx[1]; 
    
    // create a vector datatype of invIndex since cell array is slower.
    std::vector<std::vector <int> > invIndex2;
    for(int i=0; i<noWrds; i++){            
            std::vector<int> vecs;
            if(tsthist[i]==0){
                invIndex2.push_back(vecs);
                continue;
            }                
            locptr = mxGetCell(invIndexTest, i);            
            locids = mxGetPr(locptr);            
            nolocs = mxGetDimensions(locptr);
            for(int k=0; k<nolocs[1]; k++)
               vecs.push_back(locids[k]);
            invIndex2.push_back(vecs);
    }   
        
    /* For each exemplar */
    for(int i=0; i<no_iters; i++)
    {
         //mexPrintf("training no: %d\n",trids[i]);        
         trno = trids[i];                 
 
        float *score_ex = new float[os1*os2*no_scales[1]]();
        float *score_conv = new float[os1*os2*no_scales[1]]();
                
        for(int j=0;j<npts[trno-1];j++)
        {            
            unsigned long int idx = cumsum[trno-1] + j;
            trw = tr_words_all[idx];
            trkpt1 = trkpts1[idx];
            trkpt2 = trkpts2[idx];
            trhist = tr_hist_all[idx];
            numm = cwt[idx];
            
            if(tsthist[trw]==0 || numm == 0)
                continue;
            
            nmat_pairs = trhist*tsthist[trw];
            if(nmat_pairs>11)
                continue;
                       
            std::vector <int>vecs=invIndex2[trw];            
            
            for(int k=0; k<vecs.size(); k++)
             {
                for(int sc=0; sc<no_scales[1]; sc++)
                {

                  scM = scales[sc]/trColDist[trno-1];
                  // a = (int) round(gsM*kpts[vecs[k]*kptDim] - gsM*trkpt1*scM);
                  a = (int) (gsM*kpts[vecs[k]*kptDim] - gsM*trkpt1*scM + 0.5);
                   
                  scM = scales[sc]/trRowDist[trno-1];                   
                  b = (int) (gsM*kpts[(vecs[k]*kptDim)+1] - gsM*(trkpt2+fddb)*scM + 0.5);
                  // b = (int) round(gsM*kpts[(vecs[k]*kptDim)+1] - gsM*(trkpt2+fddb)*scM);
          
                 if(a >= 0 && b >= 0 && a<os2 && b<os1)
                   {
                        id = (unsigned long int) (os1*os2*sc + os1*a + b);
                        score_ex[id] += (float) ((numm*feawt[(trkpt1*feawtDim)+trkpt1])/nmat_pairs);                                                               
                  }                 
                }
             }                          
         }
        
        /* smooth the vote */
        for(int sc=0;sc<no_scales[1];sc++){
            int ptr = os1*os2*sc;
            bool aa=convolve2DSeparable(score_ex+ptr,score_conv+ptr,os1,os2,wt,kernel_sz[1], wt, kernel_sz[1]);
        }        
        
        /* maximum peak */        
        int max_score = 0;
        int peak_scale = 0;
        for(int sc=0; sc<no_scales[1]; sc++){
                for(int ii=0;ii<os1;ii++){
                    for(int jj=0;jj<os2;jj++){
                        id = (unsigned long int) (os1*os2*sc + os1*jj + ii);
                        if(max_score < score_conv[id]){
                            max_score = score_conv[id];
                            peak_scale = sc;
                        }
                    }
                }
        }        
        
        /* apply threshold */
        int sc = peak_scale;
        for(int ii=0;ii<os1;ii++){
            for(int jj=0;jj<os2;jj++){
                 id = (unsigned long int) (os1*os2*sc + os1*jj + ii);                        
                 if(score_conv[id]>alpha*thresh[trno-1])    
                      maps[id] = maps[id] + score_conv[id];

            }
        }                       
        delete[] score_ex;
        delete[] score_conv;
    }     
    return;   
}
    
    
