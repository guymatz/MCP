#include <stdio.h>
#include <math.h>
#include <assert.h>

#define ROWS 4000  // Number of rows in the matrices
#define COLS 6000  // Number of columns in the matrices

__global__ void matrixAdd(float* A, float* B, float* C, int rows, int cols) {

	int row = blockIdx.y * blockDim.y + threadIdx.y;
	int col = blockIdx.x * blockDim.x + threadIdx.x;
	int idx = row * cols + col;
	if (row < rows && col < cols) {
		C[idx] = A[idx] + B[idx];
		//if (idx > ((rows * cols) - 5))
		/*
		if (idx < 5 || idx > ((rows * cols) - 5))
				printf("idx: %i - %4.2f + %4.2f = %4.2f\n", idx, A[idx], B[idx], C[idx]);
		*/
	}
	/*
	else {
		printf("idx: %i - row: %i, col: %i\n", idx, row, col);
	}
	*/
}

void print_matrix(float* M, int M_length, int lines=5) {
	for (int i = 0; i < lines * lines; i++) {
		if (i % lines == 0) {
			printf("\n");
		}
		printf("%8.4f", M[i]);
	}
	printf("\n");
	for (int i = M_length-(lines * lines); i < M_length ; i++) {
		if (i % lines == 0) {
			printf("\n\t\t\t\t\t");
		}
		printf("%8.4f", M[i]);
	}
	printf("\n");
}

int main() {
	// Size in bytes for the ROWS x COLS matrix
	int matrix_length = ROWS * COLS;  
	int matrix_size = matrix_length * sizeof(float);  

	// Host memory allocation
	float *h_A = (float*)malloc(matrix_size);
	float *h_B = (float*)malloc(matrix_size);
	float *h_C = (float*)malloc(matrix_size);

	// Initialize matrices A and B
	for (int i = 0; i < ROWS * COLS; i++) {
		h_A[i] = 1.0 + (float)rand()/RAND_MAX;
		h_B[i] = 2.0 + (float)rand()/RAND_MAX;
	}
	print_matrix(h_A, matrix_length);
	print_matrix(h_B, matrix_length);

	// Device memory allocation
	float* d_A;
	float* d_B;
	float* d_C;
	cudaMalloc((void **)&d_A, matrix_size);
	cudaMalloc((void **)&d_B, matrix_size);
	cudaMalloc((void **)&d_C, matrix_size);
	

	// Copy matrices A and B from host to device
	cudaMemcpy(d_A, h_A, matrix_size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_B, h_B, matrix_size, cudaMemcpyHostToDevice);

	// Define block and grid sizes
	dim3 N_threads(32, 32);
	dim3 N_blocks( (COLS + N_threads.x - 1) / N_threads.x, (ROWS + N_threads.y - 1) / N_threads.y );
	printf("M size: %i, N_blocks.x: %i, N_threads.x: %i, tot: %i\n", matrix_length,
							N_blocks.x * N_threads.x,
							N_blocks.y * N_threads.y,
							N_blocks.x * N_threads.x * N_blocks.y * N_threads.y
							);
	// Launch the kernel
	matrixAdd<<<N_blocks, N_threads>>>(d_A, d_B, d_C, ROWS, COLS);

	// Copy the result matrix C from device to host
	cudaMemcpy(h_C, d_C, matrix_size, cudaMemcpyDeviceToHost);
	
	// Print part of the result matrix C for verification
	print_matrix(h_C, matrix_length);

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
