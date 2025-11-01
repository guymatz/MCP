#include <stdio.h>

#define ROWS 4000  // Number of rows in the matrices
#define COLS 6000  // Number of columns in the matrices

__global__ void matrixAdd(float* A, float* B, float* C, int rows, int cols) {

	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	if (idx > rows * cols) {
		return;
	}
	C[idx] = A[idx] + B[idx];
	if (idx < 10)
		printf("%i: %4.2f + %4.2f = %4.2f\n", idx, A[idx], B[idx], C[idx]);
}

void print_matrix(float* C) {
	for (int i = 0; i < 100; i++) {
		printf("%4.2f ", C[i]);
		if ((i > 0) && ((i+1) % 10) == 0)
			printf("\n");
	}
	printf("\n");
}

int main() {
    // Size in bytes for the ROWS x COLS matrix
    int matrix_size = ROWS * COLS;
    int size = matrix_size * sizeof(float);  

    // Host memory allocation
    float *h_A = (float*)malloc(size);
    float *h_B = (float*)malloc(size);
    float *h_C = (float*)malloc(size);

    // Initialize matrices A and B
    for (int i = 0; i < ROWS * COLS; i++) {
        h_A[i] = 1.0 + (float)rand()/RAND_MAX;
        h_B[i] = 2.0 + (float)rand()/RAND_MAX;
    }
    print_matrix(h_A);
    print_matrix(h_B);

    // Device memory allocation
    float* d_A;
    float* d_B;
    float* d_C;
    cudaMalloc((void **)&d_A, size);
    cudaMalloc((void **)&d_B, size);
    cudaMalloc((void **)&d_C, size);

    // Copy matrices A and B from host to device
    cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);
    

    // Define block and grid sizes
    int N_threads = 256;
    int N_blocks = ceil(float(matrix_size)/N_threads);

    // Launch the kernel
    matrixAdd<<<N_blocks, N_threads>>>(d_A, d_B, d_C, ROWS, COLS);

    // Copy the result matrix C from device to host
    cudaMemcpy(h_C, d_C, matrix_size, cudaMemcpyDeviceToHost);
    
    // Print part of the result matrix C for verification
    print_matrix(h_C);

    // Free device memory
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    // Free host memory
    free(h_A);
    free(h_B);
    free(h_C);

    return 0;
}
