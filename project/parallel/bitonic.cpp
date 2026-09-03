// #include <stdio.h>
// #include <stdlib.h>
// #include <time.h>
// #include <algorithm>
#include <vector>
// #include <assert.h>
#include <cmath>
#include <fstream>
#include <iostream>
#include <string>
// #include <benchmark/benchmark.h>
#include "omp.h"
#include "parallelUtils.hpp"

using namespace std;

int main(int argc, char *argv[]) {
    // See https://en.wikipedia.org/wiki/Bitonic_sorter
    int N = 4;
    bool verbose = false;
    struct timespec start_time_verify, end_time_verify;
    struct timespec start_time, end_time;
    int startIdx, distance, subArraySize, swapPartner;

    if (argc >= 2)
        N = stoi(argv[1]);
    if (argc >= 3) {
        verbose = true;
    }
    int n = pow(2, N);
    std::vector<int> Vnums(n);
    populate_vector(Vnums, n);

    clock_gettime(CLOCK_MONOTONIC, &start_time);

    // We loop through "sub arrays" of the original vector, 2 elements, then
    // 4 , then 8 . . .
    for (subArraySize = 2; subArraySize <= n; subArraySize = subArraySize * 2) {
        for (distance = subArraySize / 2; distance > 0; distance = distance / 2) {
            #pragma omp parallel for private(swapPartner)
            for (startIdx = 0; startIdx < n; startIdx++) {
                swapPartner = startIdx ^ distance;
                if (swapPartner > startIdx) {
                    //  Check "direction" of sort, and values in array
                    //  First ascending . . .
                    if ((((int)floor(startIdx / subArraySize) % 2) == 0) &&
                        Vnums[startIdx] > Vnums[swapPartner]) {
                        swap(Vnums[startIdx], Vnums[swapPartner]);
                    }
                    // then descending
                    if ((((int)floor(startIdx / subArraySize) % 2) != 0) &&
                        Vnums[startIdx] < Vnums[swapPartner]) {
                        swap(Vnums[swapPartner], Vnums[startIdx]);
                    }
                }
            }
        }
    }

    clock_gettime(CLOCK_MONOTONIC, &end_time);

    clock_gettime(CLOCK_MONOTONIC, &start_time_verify);
    if (!verify(Vnums, n, verbose)) {
        printf("oopsy\n");
        return 1;
    }
    clock_gettime(CLOCK_MONOTONIC, &end_time_verify);

    printf("parallel, bitonic, %i, %i,  %.6f\n", N, n, get_elapsed_time(start_time, end_time));
}
