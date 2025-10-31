#include <stdio.h>

// The number of elements is reduced to avoid running out of memory
#define M_ROWS 2000	  // Number of rows in the matrix M
#define M_COLS 3000	  // Number of cols in the matrix M
#define N_ROWS (M_COLS)  // Number of rows in the matrix N (matching the number of columns of matrix)
#define N_COLS 2500	  // Number of cols in the matrix N

__global__ void matrixAdd(float* M, float* N, float* P, int rows_M, int cols_M, int rows_N, int cols_N) {
			// d_M,	  d_N,	 d_P,	   M_ROWS,	 M_COLS,	 N_ROWS,	 N_COLS);

	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	if (idx >= M_ROWS * M_COLS ) {
		//printf("%i: returning . . .\n", idx);
		return;
	}
	float s = M[idx] + N[idx];
	if (idx < 10) {
		printf("%i: %4.2f + %4.2f = %4.2f\n", idx, M[idx], N[idx], s);
	}
	P[idx] = s;
	return;
}

void print_matrix(const char name[1], float* M) {
	// Print part of the result matrix P for verification
	printf("%s:\n", name);
	for (int i = 0; i < 100; i++) {
		printf("%8.2f", M[i]);
		if ((i+1) % 10 == 0)
			printf("\n");
	}
	printf("\n");
}

int main() {
	// Size in bytes for the ROWS x COLS matrix
	int matrix_size = M_ROWS * M_COLS;
	int size_M = matrix_size * sizeof(float);
	int size_N = matrix_size * sizeof(float);
	int size_P = matrix_size * sizeof(float);

	// Host memory allocation
	float *h_M = (float*)malloc(size_M);
	float *h_N = (float*)malloc(size_N);
	float *h_P = (float*)malloc(size_P);

	// Initialize matrix M
	for (int i = 0; i < M_ROWS * M_COLS; i++) {
		h_M[i] = 1.0 + (float)rand()/RAND_MAX;
	}
	print_matrix("M", h_M);

	// Initialize matrix N
	for (int i = 0; i < N_ROWS * N_COLS; i++) {
		h_N[i] = 1.0 + (float)rand()/RAND_MAX;
	}
	print_matrix("N", h_N);

	// Device memory allocation
	float* d_M;
	float* d_N;
	float* d_P;
	cudaMalloc((void **)&d_M, size_M);
	cudaMalloc((void **)&d_N, size_N);
	cudaMalloc((void **)&d_P, size_P);
	printf("M_rows: %i, M_cols: %i, prod: %i\n", M_ROWS, M_COLS, M_ROWS * M_COLS);

	// Copy matrices M and N from host to device
	cudaMemcpy(d_M, h_M, size_M, cudaMemcpyHostToDevice);
	cudaMemcpy(d_N, h_N, size_M, cudaMemcpyHostToDevice);
	cudaMemcpy(d_P, h_P, size_M, cudaMemcpyHostToDevice);
	
	// Define block and grid sizes
	int NUM_THREADS = 256;
	int N_b = ceil(float(M_ROWS) * M_COLS / NUM_THREADS);
	printf("N_b: %i, NUM_THREADS: %i, prod: %i\n", N_b, NUM_THREADS, N_b * NUM_THREADS);

	// Launch the kernel
	printf("Launch matrixAdd: blocks=%i, threads=%i\n", N_b, NUM_THREADS);
	matrixAdd<<<N_b, NUM_THREADS>>>(d_M, d_N, d_P, M_ROWS, M_COLS, N_ROWS, N_COLS);

	// Copy the result matrix P from device to host
	cudaMemcpy(h_P, d_P, size_M, cudaMemcpyDeviceToHost);

	// Print part of the result matrix P for verification
	print_matrix("P", h_P);

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
