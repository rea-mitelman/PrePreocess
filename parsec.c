//////////////////////////////// PARSEC.C /////////////////
//
// 12-feb-03 ES

#include "mex.h"
#include <stdlib.h>

// parse a sorted array in O(len)
// ex
// 1 2 3 5 6 7		-> 1:3, 5:7
// 2 2 2 3 3 3		-> 2:3 ( and not 2:2, 2:2, 2:2, 3:3, 3:3, 3:3 )
//
// if array is not sorted, will result in local parsing
// ex
// 1 2 3 5 6 3 4	-> 1:3, 5:6, 3:4

void parse(const double *vec, const int len, double *start, double *e, int *pairs) {

    int i,j = 0;

	start[j] = vec[j];

    for (i = 1; i<len; i++) {
        if (vec[i-1]+1 != vec[i] & vec[i-1] != vec[i]) {
            e[j] = vec[i-1];
            j++;
            start[j] = vec[i];
        }
    }
	e[j++] = vec[i-1];
    *pairs = j;
}

// trim parsed output

void trim(const double *s, double *t, const int len) {
    
    int i;
    for (i=0; i<len; i++) {
        t[i] = s[i];
    }
}

// gateway

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

    double *x, *buf1, *buf2, *st, *et;
    int n, m, p;

    // check io
    if (nrhs != 1) mexErrMsgTxt("1 input required (vector array)");
    if (nlhs != 2) mexErrMsgTxt("2 outputs required (start,end)");

    // input
    x = mxGetPr(prhs[0]);
    m = mxGetM(prhs[0]);
    n = mxGetN(prhs[0]);
    if (!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) || m>1)
        mexErrMsgTxt("input must be a non complex row vector");

    // allocate space and call parse
    buf1 = (double*)malloc((n+1)*sizeof(double));
    buf2 = (double*)malloc((n+1)*sizeof(double));
    if (buf1==NULL | buf2==NULL) 
        mexErrMsgTxt("check memory allocation");
    parse(x,n,buf1,buf2,&p);

    // allocate space for parsec output
    plhs[0] = mxCreateDoubleMatrix(p, 1, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(p, 1, mxREAL);

    // assign pointers to output
    st = mxGetPr(plhs[0]);
    et = mxGetPr(plhs[1]);
    trim(buf1,st,p);
    trim(buf2,et,p);
    free(buf2);
    free(buf1);
    
}

