#include <stdio.h>

void print_matrix(float* M, int len, int lines=10) {
		for (int i = 0; i < lines * lines; i++) {
				if (i % lines == 0) printf("\n");
				printf("%4.2f ", M[i]);
		}

		for (int i = (len - lines * lines); i < len; i++) {
				if (i % lines == 0) printf("\n\t\t\t\t\t\t\t\t");
				printf("%4.2f ", M[i]);
		}
		printf("\n");
}
