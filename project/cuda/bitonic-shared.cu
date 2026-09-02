#include <cmath>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

#include "cudaUtils.cuh"

using namespace std;

__global__ void sortKernelWithSharedMemory(int *d_V, int subArraySize, int distance, int N) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    /* printf("Block with Shared Memory: %i\n", blockIdx.x); */
    if (idx >= N)
        return;
    // set up shared memory
    __shared__ int sm[SHARED_MEM_MAX_ITEMS];
    // only copy over the first time this is called, when subArraySize = 2, and distance = 1
    if (subArraySize == 2 && distance == 1) {
        /* printf("Copying idx: %i\n", idx); */
        sm[idx] = d_V[idx];
    }

    __syncthreads();

    if ((subArraySize % distance) != 0)
        return;
    int swapPartner = idx ^ distance;
    if (swapPartner < idx || swapPartner >= N)
        return;

    // printf("%i\n", idx);
    /* printf("Comparing: %i <> %i : at %i - %i\n", d_V[idx], d_V[swapPartner], idx, swapPartner);
     */
    if ((idx & subArraySize) == 0 && sm[idx] > sm[swapPartner]) {
        // swap does not exist in CUDA :-(
        // swap(d_V[idx], d_V[swapPartner]);
        int tmp = sm[idx];
        sm[idx] = sm[swapPartner];
        sm[swapPartner] = tmp;
    }
    if ((idx & subArraySize) != 0 && sm[idx] < sm[swapPartner]) {
        // swap does not exist in CUDA :-(
        // swap(d_V[swapPartner], d_V[idx]);
        int tmp = sm[idx];
        sm[idx] = sm[swapPartner];
        sm[swapPartner] = tmp;
    }
    //  We are now done with being able to use shared memory
    /* printf("HERE idx: %i, sAS: %i, dist: %i\n", idx, subArraySize, distance); */
    if (threadIdx.x == 0 && subArraySize == N && distance == 1) {
        __syncthreads();
        for (int i = 0; i < N; i++) {
            /* printf("Copying idx: %i - %i\n", i, sm[i]); */
            d_V[i] = sm[i];
        }
    } else if (subArraySize == 1) {
        __syncthreads();
    }
}

__global__ void sortKernel(int *d_V, int subArraySize, int distance, int N) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    /* printf("Block: %i\n", blockIdx.x); */
    if (idx >= N)
        return;
    if ((subArraySize % distance) != 0)
        return;
    int swapPartner = idx ^ distance;
    if (swapPartner < idx || swapPartner >= N)
        return;

    // printf("%i\n", idx);

    if ((idx & subArraySize) == 0 && d_V[idx] > d_V[swapPartner]) {
        // swap does not exist in CUDA :-(
        // swap(d_V[idx], d_V[swapPartner]);
        int tmp = d_V[idx];
        d_V[idx] = d_V[swapPartner];
        d_V[swapPartner] = tmp;
    }
    if ((idx & subArraySize) != 0 && d_V[idx] < d_V[swapPartner]) {
        // swap does not exist in CUDA :-(
        // swap(d_V[swapPartner], d_V[idx]);
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
    // cout << "verbose: " << n << " " << N << " @ " << currentTime() <<
    // std::endl;
    std::vector<int> h_V(n);

    struct timespec start_time, end_time, load_time, sort_time, copy_to_device_time,
        copy_to_host_time;
    struct timespec start_kernel_time, end_kernel_time;
    /* cout << "Populating Vector . . . " << std::endl; */
    clock_gettime(CLOCK_MONOTONIC, &start_time);
    populate_vector(h_V, n);
    clock_gettime(CLOCK_MONOTONIC, &load_time);
    /* cout << "Populating Vector time: " << get_elapsed_time(start_time,
     * load_time) << std::endl; */

    /*  Why can't I do this?!
    bool verbose = argv->std::find("-v") != argv.end();
    //bool verbose = (std::find(argv.begin(), argv.end(), "-v") != argv.end());
    cout << "verbose: " << verbose << std::endl;
    */

    // Size in bytes for the ROWS x COLS matrix
    int size = n * sizeof(int);

    // Device memory allocation
    int mtc = getMaxThreads();
    int blocks = ceil((float)n / mtc);
    int *d_V;
    cudaMalloc((void **)&d_V, size);

    // Copy vector from host to device
    checkCuda(cudaMemcpy(d_V, &(h_V[0]), size, cudaMemcpyHostToDevice));
    clock_gettime(CLOCK_MONOTONIC, &copy_to_device_time);

    int distance, subArraySize;
    // We loop through "sub arrays" of the original vector, 2 elements, then 4 , then 8 . . .
    for (subArraySize = 2; subArraySize <= n; subArraySize = subArraySize * 2) {
        // we break the problem into "sub array" halves
        for (distance = subArraySize / 2; distance > 0; distance = distance / 2) {
            clock_gettime(CLOCK_MONOTONIC, &start_kernel_time);
            if (n <= mtc) {
                sortKernelWithSharedMemory<<<blocks, mtc>>>(d_V, subArraySize, distance, n);
            } else {
                sortKernel<<<blocks, mtc>>>(d_V, subArraySize, distance, n);
            }
            clock_gettime(CLOCK_MONOTONIC, &end_kernel_time);
        }
    }
    cudaDeviceSynchronize();
    clock_gettime(CLOCK_MONOTONIC, &sort_time);

    checkCuda(cudaMemcpy(&(h_V[0]), d_V, size, cudaMemcpyDeviceToHost));
    clock_gettime(CLOCK_MONOTONIC, &copy_to_host_time);

    clock_gettime(CLOCK_MONOTONIC, &end_time);

    if (N <= 3) {
        cout << "***** AFTER sort . . .\n";
        for (int i = 0; i < n; i++) {
            cout << pprint(h_V[i]) << std::endl;
        }
    }

    struct timespec start_time_verify, end_time_verify;
    clock_gettime(CLOCK_MONOTONIC, &start_time_verify);
    if (!verify(h_V, n)) {
        printf("oopsy\n");
        return 1;
    }
    clock_gettime(CLOCK_MONOTONIC, &end_time_verify);

    printf("bitonic-shared, %i, %zu, %.6f\n", N, n, get_elapsed_time(copy_to_host_time, sort_time));

    cudaFree(d_V);
    //  No need to free a vector - https://stackoverflow.com/a/3054584/2623252
    h_V.clear();
}
