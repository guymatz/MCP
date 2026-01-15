//#include <stdio.h>
//#include <stdlib.h>
//#include <time.h>
//#include <algorithm>
#include <vector>
//#include <assert.h>
#include <iostream>
#include <fstream>
#include <string>
#include <cmath>
//#include <benchmark/benchmark.h>
#include "cudaUtils.cuh"

using namespace std;

__global__ void sortKernel(int* d_V, int subArraySize, int distance, int N) {

    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int swapPartner = idx^distance;
    if (idx >= N)
        return;
    if (swapPartner < idx)
        return;
    if (swapPartner >= N)
        return;
    if ((subArraySize % distance) != 0)
        return;

    if ((idx & subArraySize)==0 && d_V[idx] > d_V[swapPartner]) {
        //swap(d_V[idx], d_V[swapPartner]);
        int tmp = d_V[idx];
        d_V[idx] = d_V[swapPartner];
        d_V[swapPartner] = tmp;
    }
    if ((idx & subArraySize)!=0 && d_V[idx] < d_V[swapPartner]) {
        //swap(d_V[swapPartner], d_V[idx]);
        int tmp = d_V[idx];
        d_V[idx] = d_V[swapPartner];
        d_V[swapPartner] = tmp;
    }
    //printf("%i\t\t%i\t\t%i\t%i\n", subArraySize, distance,  idx, swapPartner);
}

int main(int argc, char *argv[]) {

    // See https://en.wikipedia.org/wiki/Bitonic_sorter
    int N = 4;
    if (argc == 2)
        N = stoi(argv[1]);
    size_t n = pow(2, N);
    std::vector<int> h_V(n);
    populate_vector(h_V, n);

    // Size in bytes for the ROWS x COLS matrix
    int size = n * sizeof(double);

    for (int i = 0; i < n; i++) {
//        cout << pp(h_V[i]) << std::endl;
    }

    struct timespec start_time, end_time;
    clock_gettime(CLOCK_MONOTONIC, &start_time);

    // Device memory allocation
    int mt = getMaxThreads();
    int blocks = ceil( (float)n / mt);
    //cout << "n: " << n << ", threads: " << mt << ", blocks: " << blocks << std::endl;
    int* d_V;
    cudaMalloc((void **)&d_V, size);

    // Copy matrices A and B from host to device
    cudaMemcpy(d_V, &(h_V[0]), size, cudaMemcpyHostToDevice);

    int distance, subArraySize;

    // Define block and grid sizes
    //dim3 blockSize(16, 16);
    //dim3 gridSize((WIDTH + blockSize.x - 1) / blockSize.x, (WIDTH + blockSize.y - 1) / blockSize.y);

    // We loop through "sub arrays" of the original vector, 2 elements, then
    // 4 , then 8 . . .
    printf("subArraySize\tdistance\tidx\tswapPartner\n");
    for (subArraySize=2; subArraySize<=n; subArraySize=subArraySize*2 ) {
        // we break the problem into "sub array" halves
        for (distance=subArraySize/2; distance>0; distance=distance/2) {
            // Launch the matrixTransposition kernel (do NOT copy back the resulting M_T from Device to Host)
            sortKernel<<<blocks, mt>>>(d_V, subArraySize, distance, n);
        }
    }

    cudaMemcpy(&(h_V[0]), d_V, size, cudaMemcpyDeviceToHost);

    clock_gettime(CLOCK_MONOTONIC, &end_time);

    if (N <= 3) {
        cout << "***** AFTER sort . . .\n";
        for (int i = 0; i < n; i++) {
            cout << pp(h_V[i]) << std::endl;
        }
    }

    struct timespec start_time_verify, end_time_verify;
    clock_gettime(CLOCK_MONOTONIC, &start_time_verify);
    if (! verify(h_V, n)) {
        printf("oopsy\n");
        return 1;
    }
    clock_gettime(CLOCK_MONOTONIC, &end_time_verify);
    printf("Bitonic Verification time: %.6f seconds\n", get_elapsed_time(start_time_verify, end_time_verify));


    printf("Bitonic Execution time: %.6f seconds\n", get_elapsed_time(start_time, end_time));

    cudaFree(d_V);
    h_V.clear();
}
