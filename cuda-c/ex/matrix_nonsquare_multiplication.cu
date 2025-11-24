#include <stdio.h>
#include "utils.cuh"

// The number of elements is reduced to avoid running out of memory 
#define M_ROWS 2000      // Number of rows in the matrix M
#define M_COLS 3000      // Number of cols in the matrix M
#define N_ROWS (M_COLS)  // Number of rows in the matrix N (matching the number of columns of matrix)
#define N_COLS 2500      // Number of cols in the matrix N

__global__ void matrixMultiplication(float* M, float* N, float* P, int rows_M, int cols_M, int rows_N, int cols_N) {

    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;

    if (( row >= rows_M ) || (col >= cols_N))
        return;

    //printf("R: %i, C: %i\n", row, col);
    float sum = 0;
    for (int m = 0; m < cols_M; m++) {
        sum += M[row * cols_M + m] * N[cols_N * m + col];
    }
    if ((row % 100 == 0) && (col % 100 == 0))
        printf("R: %i, C: %i, sum: %2.4f\n", row, col, sum);
    P[row * cols_N + col] = sum;
}

int main() {
    // Size in bytes for the ROWS x COLS matrix
    int size_M = M_ROWS * M_COLS * sizeof(float);  
    int size_N = N_ROWS * N_COLS * sizeof(float);  
    int size_P = M_ROWS * N_COLS * sizeof(float);  

    // Host memory allocation
    float *h_M = (float*)malloc(size_M);
    float *h_N = (float*)malloc(size_N);
    float *h_P = (float*)malloc(size_P);

    // Initialize matrix M
    for (int i = 0; i < M_ROWS * M_COLS; i++) {
        h_M[i] = 1.0 + (float)rand()/RAND_MAX;
    }
    // Initialize matrix N
    for (int i = 0; i < N_ROWS * N_COLS; i++) {
        h_N[i] = 1.0 + (float)rand()/RAND_MAX;
    }

    // Device memory allocation
    float *d_M, *d_N, *d_P;
    checkCuda( cudaMalloc((void **)&d_M, size_M) );
    checkCuda( cudaMalloc((void **)&d_N, size_N) );
    checkCuda( cudaMalloc((void **)&d_P, size_P) );


    // Copy matrices M and N from host to device
    checkCuda( cudaMemcpy(d_M, h_M, size_M, cudaMemcpyHostToDevice) );
    checkCuda( cudaMemcpy(d_N, h_N, size_N, cudaMemcpyHostToDevice) );
    checkCuda( cudaMemcpy(d_P, h_P, size_P, cudaMemcpyHostToDevice) );

    int mt = getMaxThreads();
    dim3 N_threads(mt, mt);
    dim3 N_blocks(ceil( (M_ROWS * N_COLS) / (float)mt ), ceil( (M_ROWS * N_COLS) / (float)mt ) );

    // Launch the kernel
    printf("Launching Kernel with %i x %i block of %i:%i threads each. . .\n", N_blocks.x, N_blocks.y, N_threads.x, N_threads.y);
    printf("M\n");
    //print_fmatrix(h_M, M_ROWS*M_COLS);
    printf("N\n");
    //print_fmatrix(h_N, N_ROWS*N_COLS);
    matrixMultiplication<<<N_blocks, N_threads>>>(d_M, d_N, d_P, M_ROWS, M_COLS, N_ROWS, N_COLS);
    if (! cudaCheck( cudaPeekAtLastError() ) )
            return 1;

    // Copy the result matrix P from device to host
    cudaMemcpy(h_P, d_P, size_P, cudaMemcpyDeviceToHost);
    printf("Copied back to host. . .\n");

    // Print part of the result matrix P for verification
    print_fmatrix(h_P, M_ROWS*N_COLS);

    // Free device memory
    cudaFree(d_M);
    cudaFree(d_N);
    cudaFree(d_P);

    // Free host memory
    free(h_M);
    free(h_N);
    free(h_P);

    return 0;
}
