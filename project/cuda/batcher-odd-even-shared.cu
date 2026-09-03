#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include <algorithm>
#include <cmath>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

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

__device__ void compex(int *V, int origin, int partner) {
    if (V[origin] > V[partner]) {
        int temp = V[origin];
        V[origin] = V[partner];
        V[partner] = temp;
    }
}

__global__ void sortKernel(int *Vnums, int N, int d, int p, int r) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx < (N - d)) {
        int ORIGIN_idx = idx;
        int PARTNER_idx = ORIGIN_idx + d;
        if ((ORIGIN_idx & p) == r) {
            compex(Vnums, ORIGIN_idx, PARTNER_idx);
        }
    }
}

__global__ void sortKernelWithSharedMemory(int *d_V, int N, int d, int p, int r, int q) {

    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx >= N)
        return;

    // set up shared memory
    __shared__ int sm[SHARED_MEM_MAX_ITEMS];
    // only copy over the first time this is called
    if (p == N / 2 && q == N / 2) {
        sm[idx] = d_V[idx];
    }

    __syncthreads();

    if (idx < (N - d)) {
        int ORIGIN_idx = idx;
        int PARTNER_idx = ORIGIN_idx + d;

        if ((ORIGIN_idx & p) == r) {
            compex(sm, ORIGIN_idx, PARTNER_idx);
        }
    }

    //  We are now done with being able to use shared memory
    if (threadIdx.x == 0 && p == 1 && q == 1) {
        __syncthreads();
        for (int i = 0; i < N; i++) {
            /* printf("Copying idx: %i - %i\n", i, sm[i]); */
            d_V[i] = sm[i];
        }
    } else if (p == 1 && q == 1) {
        __syncthreads();
    }
}

int main(int argc, char *argv[]) {
    struct timespec start_time, end_time, load_time, sort_time, copy_to_device_time,
        copy_to_host_time, start_time_verify, end_time_verify;
    clock_gettime(CLOCK_MONOTONIC, &start_time);

    //  These var names make sense when you look at the README
    int t = 4;
    if (argc == 2)
        t = stoi(argv[1]);
    int N = pow(2, t);

    std::vector<int> Vnums(N);
    populate_vector(Vnums, N);
    clock_gettime(CLOCK_MONOTONIC, &load_time);
    // Size in bytes for the ROWS x COLS matrix
    int size = N * sizeof(int);

    // Device memory allocation
    int mtc = getMaxThreads();
    int blocks = ceil((float)N / mtc);
    int *d_V;
    cudaMalloc((void **)&d_V, size);

    // Copy vector from host to device
    checkCuda(cudaMemcpy(d_V, &(Vnums[0]), size, cudaMemcpyHostToDevice));
    clock_gettime(CLOCK_MONOTONIC, &copy_to_device_time);

    // See Knuth - Art of Computing Volume 3, p. 112
    // Again, bad var names, but see README
    int r, d;
    for (int p = pow(2, t - 1); p > 0; p = p / 2) {
        r = 0;
        d = p;
        for (int q = pow(2, t - 1); p <= q; q = q / 2) {
            if (N <= mtc) {
                sortKernelWithSharedMemory<<<blocks, mtc>>>(d_V, N, d, p, r, q);
            } else {
                sortKernel<<<blocks, mtc>>>(d_V, N, d, p, r);
            }
            if (q != p) {
                d = q - p;
            }
            r = p;
        }
    }
    clock_gettime(CLOCK_MONOTONIC, &sort_time);

    // Copy vector from device to host
    checkCuda(cudaMemcpy(&(Vnums[0]), d_V, size, cudaMemcpyDeviceToHost));
    clock_gettime(CLOCK_MONOTONIC, &copy_to_host_time);

    clock_gettime(CLOCK_MONOTONIC, &start_time_verify);
    if (!verify(Vnums, N, false)) {
        printf("oopsy\n");
        return 1;
    }
    clock_gettime(CLOCK_MONOTONIC, &end_time_verify);

    clock_gettime(CLOCK_MONOTONIC, &end_time);

    printf("cuda, batcher-shared, %i, %i, %.6f\n", t, N, get_elapsed_time(copy_to_device_time, sort_time));
}
