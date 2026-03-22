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

__global__ void printKernel(int *V, int n) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx == 0) {
        for (int i = 0; i < n; i++) {
            printf("%i - %i\n", i, V[i]);
        }
    }
}

__global__ void sortKernel(int *V, int n, int ODD) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if ( (idx < n-1) && (idx % 2 == ODD) ) {
        //char oe_flag = 'E';
        //if (ODD) oe_flag='O';
        int ORIGIN_idx = idx;
        int PARTNER_idx = idx + 1;
        printf("ORIGIN_IDX = %i, PARTNER_idx = %i\n", ORIGIN_idx, PARTNER_idx);
        //printf("OE FLAG: %c, idx = %i, ORIGIN_IDX = %i, PARTNER_idx = %i\n", oe_flag, idx, ORIGIN_idx, PARTNER_idx);
        int origin_val = V[ORIGIN_idx];
        int partner_val = V[PARTNER_idx];
        if ( origin_val > partner_val ) {
        //printf("COMPARING %c +++ %i (%i) >? %i (%i)\n",  oe_flag, V[ORIGIN_idx], ORIGIN_idx, V[PARTNER_idx], PARTNER_idx);

            /* printf("B %c +++ %i (%i) > %i (%i)\n",  oe_flag, V[ORIGIN_idx], ORIGIN_idx, V[PARTNER_idx], PARTNER_idx); */
            V[ORIGIN_idx] = partner_val;
            V[PARTNER_idx] = origin_val;
            /* printf("A %c +++ %i (%i) > %i (%i)\n",  oe_flag, V[ORIGIN_idx], ORIGIN_idx, V[PARTNER_idx], PARTNER_idx); */
        }
        else {
            //printf("%c --- %i (%i) < %i (%i)\n",  oe_flag, origin_val, ORIGIN_idx, partner_val, PARTNER_idx);
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
    /* int pp, pk; */
    std::vector<int> Vnums(n);
    populate_vector(Vnums, n);
    clock_gettime(CLOCK_MONOTONIC, &load_time);
    // Size in bytes for the ROWS x COLS matrix
    int size = n * sizeof(int);

    for (int i = 0; i < n; i++) {
       //cout << i << " " << pprint(Vnums[i]) << std::endl;
    }

    cout << "Copying data to GPU . . ." << std::endl;
    // Device memory allocation
    int threads = getMaxThreads();
    int blocks = ceil( (float)n / threads);
    int* d_V;
    int EVEN, ODD;
    EVEN = 0;
    ODD = 1;
    cudaMalloc((void **)&d_V, size);

    // Copy vector from host to device
    checkCuda( cudaMemcpy(d_V, &(Vnums[0]), size, cudaMemcpyHostToDevice) );
    clock_gettime(CLOCK_MONOTONIC, &copy_to_device_time);
    cout << "Copy Out Time: " << get_elapsed_time(load_time, copy_to_device_time) << std::endl;

    // See https://en.wikipedia.org/wiki/Batcher_odd%E2%80%93even_mergesort
    // Again, bad var names, but see link
    //cout << "i\tfmin(rk-1, n-j-rk-1)\trk\trp" << std::endl;
    for (int p = 0; p < n/2 ; p++) {
        //printf("EVEN %i of %i\n", p, n/2);
        sortKernel<<<blocks, threads>>>(d_V, n, EVEN);
        //cudaDeviceSynchronize(); printf("EVEN after\n");
        //printKernel<<<blocks, threads>>>(d_V, n);
        //cudaDeviceSynchronize(); printf("ODD\n");
        //printf("ODD\n");
        sortKernel<<<blocks, threads>>>(d_V, n, ODD);
        //cudaDeviceSynchronize(); printf("ODD after\n");
        //printKernel<<<blocks, threads>>>(d_V, n);
        //cudaDeviceSynchronize(); cout << "Waiting . . ."; cin >> poop;
    }
    //printf("ODD\n");
    sortKernel<<<blocks, threads>>>(d_V, n, ODD);
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
    printf("Batcher-O/E Verification time: %.6f seconds\n", get_elapsed_time(start_time_verify, end_time_verify));

    clock_gettime(CLOCK_MONOTONIC, &end_time);

    printf("Batcher-O/E Execution time: %.6f seconds\n", get_elapsed_time(start_time, end_time));

}
