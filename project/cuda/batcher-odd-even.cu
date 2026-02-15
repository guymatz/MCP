#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <algorithm>
#include <vector>
#include <assert.h>
#include <iostream>
#include <fstream>
#include <string>
#include <cmath>
#include "cudaUtils.cuh"

using namespace std;

__global__ void sortKernel(int *V, int i, int j, int pk, int pp) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx >= j ) {
        return;
    }

    //printf("After: %i\n", idx);
    //printf("%i: %i\t%i\t\t\t%i\t%i\n",  idx, i , j , pk , pp);

    if (floor((double)(idx+j) / (pp*2)) == floor(((double)idx+j+pk) / (pp*2))) {
        if ( V[idx+j] > V[idx+j+pk] ) {
            //cout << Vnums[i+j] << " <-> " << Vnums[i+j+pk] << std::endl;
            //  YES, I KNOW!
            int ij = V[idx+j];
            int ijpk = V[idx+j+pk];
            V[idx+j] = ijpk;
            V[idx+j+pk] = ij;
        }
        else {
            //cout << V[i+j] << " >-< " << V[i+j+pk] << std::endl;
        }
    }
}


int main(int argc, char *argv[]) {

    struct timespec start_time, end_time, load_time, sort_time, 
                    copy_to_device_time, copy_to_host_time,
                    start_time_verify, end_time_verify;
    clock_gettime(CLOCK_MONOTONIC, &start_time);

    //  These var names make sense when you look at the wikipedia page below
    int N = 4;
    if (argc == 2)
        N = stoi(argv[1]);
    int n = pow(2, N);
    //printf("Working with a list of 2^%i (%i)\n", N, n);
    //int ij, ijrk;
    // for ranges of loops
    int pp, pk;
    std::vector<int> Vnums(n);
    populate_vector(Vnums, n);
    clock_gettime(CLOCK_MONOTONIC, &load_time);
    // Size in bytes for the ROWS x COLS matrix
    int size = n * sizeof(int);

    for (int i = 0; i < n; i++) {
       // cout << i << " " << pprint(Vnums[i]) << std::endl;
    }

    cout << "Copying data to GPU . . ." << std::endl;
    // Device memory allocation
    int mt = getMaxThreads();
    int blocks = ceil( (float)n / mt);
    int* d_V;
    cudaMalloc((void **)&d_V, size);

    // Copy vector from host to device
    checkCuda( cudaMemcpy(d_V, &(Vnums[0]), size, cudaMemcpyHostToDevice) );
    clock_gettime(CLOCK_MONOTONIC, &copy_to_device_time);
    cout << "Copy Out Time: " << get_elapsed_time(load_time, copy_to_device_time) << std::endl;

    // See https://en.wikipedia.org/wiki/Batcher_odd%E2%80%93even_mergesort
    // Again, bad var names, but see link
    //cout << "i\tfmin(rk-1, n-j-rk-1)\trk\trp" << std::endl;
    for (int p = 0; p < N; p++) {
        pp = pow(2, p);
        for (int k = 0; k < N; k++) {
            pk = (int)(pp / pow(2, k));
            if (pk < 1)
                continue;
            for (int j = (pk % pp); j <= n-1-pk; j=j+2*pk) {
                sortKernel<<<blocks, mt>>>(d_V, fmin(pk-1, n-j-pk-1), j, pk, pp);
                //cout << std::endl;
            }
        }
    }
    clock_gettime(CLOCK_MONOTONIC, &sort_time);

    // Copy vector from device to host
    checkCuda( cudaMemcpy(&(Vnums[0]), d_V, size, cudaMemcpyDeviceToHost) );
    clock_gettime(CLOCK_MONOTONIC, &copy_to_host_time);
    cout << "Copy In Time: " << get_elapsed_time(sort_time, copy_to_host_time) << std::endl;


    //cout << "AFTER sort . . .\n";
    for (int i = 0; i < n; i++) {
        //cout << pprint(Vnums[i]) << std::endl;
    }

    clock_gettime(CLOCK_MONOTONIC, &start_time_verify);
    if (! verify(Vnums, n)) {
        printf("oopsy\n");
        return 1;
    }
    clock_gettime(CLOCK_MONOTONIC, &end_time_verify);
    printf("Batcher O/E Verification time: %.6f seconds\n", get_elapsed_time(start_time_verify, end_time_verify));

    clock_gettime(CLOCK_MONOTONIC, &end_time);

    printf("Batcher O/E Execution time: %.6f seconds\n", get_elapsed_time(start_time, end_time));

}
