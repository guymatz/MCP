#include <stdio.h>
#include <assert.h>
#include <math.h>

inline cudaError_t checkCuda(cudaError_t result) {
    if (result != cudaSuccess) {
        fprintf(stderr, "CUDA Runtime Error: %s\n", cudaGetErrorString(result));
        assert(result == cudaSuccess);
    }
    return result;
}

inline cudaError_t cudaCheck(cudaError_t result) {
    return checkCuda(result);
}

void getMaxThreadsDim(int i=0) {
    // Structure to hold properties of the device
    cudaDeviceProp prop;
    // Get the properties of the device
    cudaGetDeviceProperties(&prop, i);
    // return Max # of thread allowed
    for (int i = 0; i < 3; i++) {
        printf("Max / Dim %i: %i\n", i+1, prop.maxThreadsDim[i]);
        printf("Max / Block %i: %i\n", i+1, prop.maxThreadsPerBlock);
    }
}

int getMaxThreads(int i=0) {
    // Structure to hold properties of the device
    cudaDeviceProp prop;
    // Get the properties of the device
    cudaGetDeviceProperties(&prop, i);
    // return Max # of thread allowed
    return ceil(sqrt(prop.maxThreadsPerBlock));
}


void printGPUproperties() {
  // Variable to store the number of CUDA-capable devices
  int nDevices;

  // Get the number of CUDA-capable devices
  cudaGetDeviceCount(&nDevices);

  // Print the number of devices found
  printf("Number of devices: %d\n", nDevices);

  // Loop through each device
  for (int i = 0; i < nDevices; i++) {
    // Structure to hold properties of the device
    cudaDeviceProp prop;

    // Get the properties of the device
    cudaGetDeviceProperties(&prop, i);

    // Print the device properties
    printf("Device Number: %d\n", i);
    printf("  Device name: %s\n", prop.name);
    printf("  Max Threads / Block: %i, 1D: %i\n", prop.maxThreadsPerBlock, (int)ceil(sqrt(prop.maxThreadsPerBlock)));
    printf("  n SMPs: %d\n", prop.multiProcessorCount);
    printf("  n SPs: %d\n", prop.multiProcessorCount*128);
    printf("  Clock rate (MHz): %.1f\n", prop.clockRate/1024.);
    printf("  L2 Cache Size (KB): %.1f\n", prop.l2CacheSize*1e-3);
    printf("  Memory Clock Rate (MHz): %d\n",
           prop.memoryClockRate/1024);
    printf("  Memory Bus Width (bits): %d\n",
           prop.memoryBusWidth);
    printf("  Peak Memory Bandwidth (GB/s): %.1f\n",
           2.0*prop.memoryClockRate*(prop.memoryBusWidth/8)/1.0e6);
    printf("  Total global memory (GB) %.1f\n",(float)(prop.totalGlobalMem)/1024.0/1024.0/1024.0);
    printf("  Shared memory per block (KB) %.1f\n",(float)(prop.sharedMemPerBlock)/1024.0);
    printf("  minor-major: %d-%d\n", prop.minor, prop.major);
    printf("  Warp-size: %d\n", prop.warpSize);
    printf("  Concurrent kernels: %s\n", prop.concurrentKernels ? "yes" : "no");
    printf("  Concurrent computation/communication: %s\n\n",prop.deviceOverlap ? "yes" : "no");
  }
}

void print_fmatrix(float* M, int len, int lines=10) {
    if (len < 100) {
        for (int i = 0; i < len ; i++) {
                if (i % lines == 0) printf("\n");
                printf("%4.2f ", M[i]);
        }
        printf("\n");
        return;
    }

        for (int i = 0; i < lines * lines; i++) {
                if (i % lines == 0) printf("\n");
                printf("%4.2f ", M[i]);
        }
        printf("\n");

        for (int i = (len/2 - lines * lines/2); i < (len/2 + lines * lines/2); i++) {
                if (i % lines == 0) printf("\n\t\t\t\t");
                printf("%4.2f ", M[i]);
        }
        printf("\n");

        for (int i = (len - lines * lines); i < len; i++) {
                if (i % lines == 0) printf("\n\t\t\t\t\t\t\t\t");
                printf("%4.2f ", M[i]);
        }
        printf("\n");
}

void print_imatrix(int* M, int len, int lines=10) {
    if (len < 100) {
        for (int i = 0; i < len ; i++) {
                if ( (i % (int)ceil(sqrt(len))) == 0 ) printf("\n");
                printf("%i ", M[i]);
        }
        printf("\n");
        return;
    }
        for (int i = 0; i < lines * lines; i++) {
                if (i % lines == 0) printf("\n");
                printf("%i ", M[i]);
        }
        printf("\n");

        for (int i = (len/2 - lines * lines/2); i < (len/2 + lines * lines/2); i++) {
                if (i % lines == 0) printf("\n\t\t\t\t");
                printf("%i ", M[i]);
        }
        printf("\n");

        for (int i = (len - lines * lines); i < len; i++) {
                if (i % lines == 0) printf("\n\t\t\t\t\t\t\t\t");
                printf("%i ", M[i]);
        }
        printf("\n");
}
