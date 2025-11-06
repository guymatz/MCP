#include <stdio.h>
#include <assert.h>

inline cudaError_t checkCuda(cudaError_t result) {
	if (result != cudaSuccess) {
		fprintf(stderr, "CUDA Runtime Error: %s\n", cudaGetErrorString(result));
		assert(result == cudaSuccess);
	}
	return result;
}

void print_matrix(float* M, int len, int lines=10) {
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
