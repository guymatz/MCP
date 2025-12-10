//#include <stdio.h>
//#include <stdlib.h>
//#include <time.h>
//#include <algorithm>
#include <vector>
//#include <assert.h>
#include <iostream>
#include <fstream>
#include <string>
#include <cmath>
//#include <benchmark/benchmark.h>
#include "parallelUtils.hpp"

using namespace std;

void bitonicMerge(vector<size_t>& V, size_t low, size_t count, int direction) {
    size_t k;
    if (count <= 1)
        return;
    k = count / 2;
    #pragma omp parallel for
    for (size_t i = low; i <= low + k - 1; i++) {
        if ((direction == 1 && V[i] > V[i + k]) || (direction == 0 && V[i] < V[i + k]) ) {
            //cout << "Swapping " << V[i] << " " << V[i+k] << std::endl;
            swap(V[i], V[i+k]);
        }
    }
    bitonicMerge(V, low, k, direction);
    bitonicMerge(V, low+k, k, direction);
}

void bitonicSort(vector<size_t>& V, size_t low, size_t count, int direction) {

    size_t k;
    if (count <= 1)
        return;
    k = count / 2;
    bitonicSort(V, low, k, 1);
    bitonicSort(V, low+k, k, 0);

    bitonicMerge(V, low, count, direction);
}

int main(int argc, char *argv[]) {

    // See https://en.wikipedia.org/wiki/Bitonic_sorter
    int N = 4;
    if (argc == 2)
        N = stoi(argv[1]);
    size_t n = pow(2, N);
    std::vector<size_t> Vnums(n);
    populate_vector(Vnums, n);

    //cout << "n: " << n << ", N: " << N << std::endl;
    /*
    for (size_t i = 0; i < n; i++) {
        cout << "before: " << Vnums[i] << std::endl;
    }
    */

    // sort
    struct timespec start_time, end_time;
    clock_gettime(CLOCK_MONOTONIC, &start_time);
    bitonicSort(Vnums, 0, n, 1);
    clock_gettime(CLOCK_MONOTONIC, &end_time);

    // and verify
    struct timespec start_time_verify, end_time_verify;
    clock_gettime(CLOCK_MONOTONIC, &start_time_verify);
    if (! verify(Vnums, n)) {
        printf("oopsy\n");
        return 1;
    }
    clock_gettime(CLOCK_MONOTONIC, &end_time_verify);
    printf("Bitonic Execution time: %.6f seconds\n", get_elapsed_time(start_time_verify, end_time_verify));

    //cout << "AFTER sort . . .\n";
    /*
    for (int i = 0; i < n; i++) {
        cout << pp(Vnums[i]) << std::endl;
    }
    */
    printf("Bitonic Execution time: %.6f seconds\n", get_elapsed_time(start_time, end_time));
}
