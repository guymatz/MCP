#include <stdio.h>
#include "utils.cuh"
#include "math.h"

// The number of elements is reduced to avoid running out of memory 
#define M_ROWS 2000      // Number of rows in the matrix M
#define M_COLS 3000      // Number of cols in the matrix M
#define N_ROWS (M_COLS)  // Number of rows in the matrix N (matching the number of columns of matrix)
#define N_COLS 2500      // Number of cols in the matrix N

__global__ void matrixMultiplication(float* M, float* N, float* P, int rows_M, int cols_M, int rows_N, int cols_N) {

    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;

    // Each thread computes one element of the result matrix
	/*
	if ( (col % 1000 == 0) &&  (row % 1000 == 0) )
			printf("Rows: %i, Col: %i\n", row, col);
	*/
    if (row < rows_M && col < cols_N ) {
		float rxc = 0;
		for (int m = 0; m < cols_M; m++) {
				rxc += M[row * cols_M + m] * N[m * cols_N + col];
				//printf("M: %i, N: %i : %4.2f = %4.2f  * %4.2f\n", row * cols_M + m, m * rows_N + col, rxc, M[row * cols_M + m] , N[m * rows_N + col]);
		}
		P[row * cols_N + col] = rxc;
		//printf("x: %i, y: %i, sum = %4.2f\n", col, row, rxc);
		return;
	}
	//printf("OOB: col=%i, row=%i\n", col, row);

}

int main() {

	int i;
	cudaGetDevice(&i);
	struct cudaDeviceProp prop;
	cudaGetDeviceProperties(&prop, i);
	printf("Device Number: %d\n", i);
    printf("  Device name: %s\n", prop.name);
	for (auto p : prop.maxGridSize) {
		printf("  ------- Max Grid Size : %i\n", p);
	}
    //printf("  Max Blocks per SMP: %d\n", prop.maxBlocksPerMultiProcessor);
	for (auto p : prop.maxThreadsDim) {
		printf("  ------- Max Threads Dim : %i\n", p);
	}
    printf("  Max Threads Per Block: %d\n", prop.maxThreadsPerBlock);
    printf("  Max Threads Per MultiProcessor: %d\n", prop.maxThreadsPerMultiProcessor);
    printf("  Warp-size: %d\n", prop.warpSize);
    printf("  Concurrent kernels: %s\n", prop.concurrentKernels ? "yes" : "no");
    printf("  Concurrent computation/communication: %s\n\n",prop.deviceOverlap ? "yes" : "no");

    // Size in bytes for the ROWS x COLS matrix
    printf("Size in bytes for the ROWS x COLS matrix\n");
    int size_M = M_ROWS * M_COLS * sizeof(float);  
    int size_N = N_ROWS * N_COLS * sizeof(float);  
    int size_P = M_ROWS * N_COLS * sizeof(float);  

    // Host memory allocation
    printf("Host memory allocation\n");
    float *h_M = (float*)malloc(size_M);
    float *h_N = (float*)malloc(size_N);
    float *h_P = (float*)malloc(size_P);

    // Initialize matrix M
    printf("Initialize matrix M\n");
    for (int i = 0; i < M_ROWS * M_COLS; i++) {
        h_M[i] = 1.0 + (float)rand()/RAND_MAX;
    }
    // Initialize matrix N
    printf("Initialize matrix N\n");
    for (int i = 0; i < N_ROWS * N_COLS; i++) {
        h_N[i] = 1.0 + (float)rand()/RAND_MAX;
    }

	print_fmatrix(h_M, M_ROWS);
	print_fmatrix(h_N, N_COLS);

    // Device memory allocation
    printf("Device memory allocation\n");
	float *d_M;
	float *d_N;
	float *d_P;
	checkCuda( cudaMalloc((void **)&d_M, size_M) );
	checkCuda( cudaMalloc((void **)&d_N, size_N) );
	checkCuda( cudaMalloc((void **)&d_P, size_P) );

    // Copy matrices M and N from host to device
    printf("Copy matrices M and N from host to device\n");
    cudaMemcpy(d_M, h_M, size_M, cudaMemcpyHostToDevice);
    cudaMemcpy(d_N, h_N, size_N, cudaMemcpyHostToDevice);

    // Define block and grid sizes
    printf("Define block and grid sizes\n");
    int  maxThreadsPerBlock = prop.maxThreadsPerBlock;
    int  warpSize = prop.warpSize;
	dim3 N_threads(maxThreadsPerBlock / warpSize, maxThreadsPerBlock / warpSize);
	int N_blocks_x = ceil( (float)N_COLS / N_threads.x);
	int N_blocks_y = ceil( (float)M_ROWS / N_threads.y);
	printf("Dim of P: %i * %i = %i\n", M_ROWS, N_COLS, M_ROWS * N_COLS);
	printf("Blocks y: %i, Blocks x: %i = %i\n", N_blocks_y, N_blocks_x, N_blocks_y * N_blocks_x * 16 * 16);
	dim3 N_blocks( N_blocks_x, N_blocks_y );

    // Launch the kernel
    printf("Launch the kernel\n");
	matrixMultiplication<<<N_blocks, N_threads>>>(d_M, d_N, d_P, M_ROWS, M_COLS, N_ROWS, N_COLS);
	//matrixMultiplication<<<N_blocks_jp, N_threads>>>(d_M, d_N, d_P, M_ROWS, M_COLS, N_ROWS, N_COLS);

    // Copy the result matrix P from device to host
    printf("Copy the result matrix P from device to host\n");
	cudaMemcpy(h_P, d_P, size_P, cudaMemcpyDeviceToHost);
	
	
    // Print part of the result matrix P for verification
    printf("Print part of the result matrix P for verification\n");
	print_fmatrix(h_P, M_ROWS);

    // Free device memory
    printf("Free device memory\n");
	checkCuda( cudaFree(d_M) );
	checkCuda( cudaFree(d_N) );
	checkCuda( cudaFree(d_P) );

    // Free host memory
    printf("Free host memory\n");
	free(h_M);
	free(h_N);
	free(h_P);

    return 0;
}
