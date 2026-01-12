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

__global__ void sortKernel(double* A, int rows, int cols) {

        int row = blockIdx.y * blockDim.y + threadIdx.y;
        int col = blockIdx.x * blockDim.x + threadIdx.x;

        if ( row < rows && col < cols) {
            int idx = row * cols + col;
            idx++;
            //C[idx] = A[idx] + B[idx];
        }


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
        cout << pp(h_V[i]) << std::endl;
    }

    struct timespec start_time, end_time;
    clock_gettime(CLOCK_MONOTONIC, &start_time);

    // Device memory allocation
    double* d_V;
    cudaMalloc((void **)&d_V, size);

    // Copy matrices A and B from host to device
    cudaMemcpy(d_V, &(h_V[0]), size, cudaMemcpyHostToDevice);

    int startIdx, distance, subArraySize, swapPartner;

    // We loop through "sub arrays" of the original vector, 2 elements, then
    // 4 , then 8 . . .
    for (subArraySize=2; subArraySize<=n; subArraySize=subArraySize*2 ) {
        // we break the problem into "sub array" halves
        for (distance=subArraySize/2; distance>0; distance=distance/2) {
            for (startIdx=0; startIdx<n; startIdx++) {
                // we loop through elements of the sub array and sort
                // "distant" neighbors
                swapPartner=startIdx^distance;
                if ((swapPartner)>startIdx) {
                    if ((startIdx&subArraySize)==0 && h_V[startIdx] > h_V[swapPartner]) 
                        swap(h_V[startIdx], h_V[swapPartner]);
                    if ((startIdx&subArraySize)!=0 && h_V[startIdx] < h_V[swapPartner])
                        swap(h_V[swapPartner], h_V[startIdx]);
                }
            }
        }
    }

    cudaMemcpy(&(h_V[0]), d_V, size, cudaMemcpyDeviceToHost);

    clock_gettime(CLOCK_MONOTONIC, &end_time);

    cout << "***** AFTER sort . . .\n";
    for (int i = 0; i < n; i++) {
        cout << pp(h_V[i]) << std::endl;
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
    free(&(h_V[0]));
}
