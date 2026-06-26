#include <cmath>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

#include "cudaUtils.cuh"

using namespace std;

__global__ void printList(int *d_V) {
    for (int i = 0; i < 32; i++) {
        if (d_V[i] != 0)
            printf("\t%i\n", d_V[i]);
    }
  __syncthreads();
}

__global__ void sortKernelWithSharedMemory() {
  int idx = blockIdx.x * blockDim.x + threadIdx.x;
  if (threadIdx.x == 0)
      printf("%i: %i %i\n", idx, blockIdx.x , threadIdx.x);
  __shared__ int sharedMem[1024];
  if (sharedMem[threadIdx.x] == 0) {
      printf("inserting %i -> %i\n", idx * 2 + 5, threadIdx.x);
      sharedMem[threadIdx.x] = idx * 2 + 5;
  }
  else if (sharedMem[threadIdx.x] == idx * 2 + 5)  {
      printf("in else %i %i\n", threadIdx.x, sharedMem[threadIdx.x]);
  }
  else {
      printf("%i %i\n", threadIdx.x, sharedMem[threadIdx.x]);
  }
  __syncthreads();
  /* printf("%i: %i %i\n", threadIdx.x, idx, sharedMem[threadIdx.x]); */

  if (idx == 0) {
      for (int i = 0; i < 10; i++) {
          printf("%i: %i\n", i, sharedMem[i]);
      }
      for (int i = 1014; i < 1024; i++) {
          printf("%i: %i\n", i, sharedMem[i]);
      }
   }
}

int main(int argc, char *argv[]) {

    int size = sizeof(int);
    int *d_V;
    int Vnum = 1;
    cudaMalloc((void **)&d_V, size);
    checkCuda(cudaMemcpy(d_V, &Vnum, size, cudaMemcpyHostToDevice));
    std::cout << "Before . . ." << std::endl;
    std::cout << "threadIdx.x\tidx\tsharedMem" << std::endl;
    sortKernelWithSharedMemory<<<1, 64>>>();
    std::cout << "After 1!" << std::endl;
    checkCuda(cudaMemcpy(&Vnum, d_V, size, cudaMemcpyDeviceToHost));

}
