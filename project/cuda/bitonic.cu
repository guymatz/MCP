#include <vector>
#include <iostream>
#include <fstream>
#include <string>
#include <cmath>
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
        // swap does not exist in CUDA :-(
        //swap(d_V[idx], d_V[swapPartner]);
        int tmp = d_V[idx];
        d_V[idx] = d_V[swapPartner];
        d_V[swapPartner] = tmp;
    }
    if ((idx & subArraySize)!=0 && d_V[idx] < d_V[swapPartner]) {
        // swap does not exist in CUDA :-(
        //swap(d_V[swapPartner], d_V[idx]);
        int tmp = d_V[idx];
        d_V[idx] = d_V[swapPartner];
        d_V[swapPartner] = tmp;
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

    /*  Why can't I do this?!
    bool verbose = argv->std::find("-v") != argv.end();
    //bool verbose = (std::find(argv.begin(), argv.end(), "-v") != argv.end());
    cout << "verbose: " << verbose << std::endl;
    */

    // Size in bytes for the ROWS x COLS matrix
    int size = n * sizeof(double);

    // Vector before
    for (int i = 0; i < n; i++) {
//        cout << pp(h_V[i]) << std::endl;
    }

    struct timespec start_time, end_time;
    clock_gettime(CLOCK_MONOTONIC, &start_time);

    // Device memory allocation
    int mt = getMaxThreads();
    int blocks = ceil( (float)n / mt);
    int* d_V;
    cudaMalloc((void **)&d_V, size);

    // Copy vector from host to device
    cudaMemcpy(d_V, &(h_V[0]), size, cudaMemcpyHostToDevice);

    int distance, subArraySize;
    // We loop through "sub arrays" of the original vector, 2 elements, then
    // 4 , then 8 . . .
    printf("subArraySize\tdistance\tidx\tswapPartner\n");
    for (subArraySize=2; subArraySize<=n; subArraySize=subArraySize*2 ) {
        // we break the problem into "sub array" halves
        for (distance=subArraySize/2; distance>0; distance=distance/2) {
            //cout << "Before: " << subArraySize << " " << distance << std::endl;
            sortKernel<<<blocks, mt>>>(d_V, subArraySize, distance, n);
            //cout << "After: " << subArraySize << " " << distance << std::endl;
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
    //  No need to free a vector - https://stackoverflow.com/a/3054584/2623252
    h_V.clear();
}
