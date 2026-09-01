#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include <algorithm>
#include <cmath>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

#include "omp.h"
#include "parallelUtils.hpp"

using namespace std;

int main(int argc, char *argv[]) {
    //  These var names make sense when you look at the wikipedia page below
    int N = 4;
    if (argc == 2)
        N = stoi(argv[1]);
    int n = pow(2, N);
    // printf("Working with a list of 2^%i (%i)\n", N, n);
    //  for ranges of loops
    int rp, rk;
    std::vector<int> Vnums(n);
    populate_vector(Vnums, n);

    struct timespec start_time, end_time;
    clock_gettime(CLOCK_MONOTONIC, &start_time);

    // See https://en.wikipedia.org/wiki/Batcher_odd%E2%80%93even_mergesort
    for (int p = 0; p < N; p++) {
        rp = pow(2, p);
        for (int k = 0; k < N; k++) {
            rk = (int)(rp / pow(2, k));
            if (rk < 1)
                continue;
            int n_1_rk = n - 1 - rk;
            #pragma omp parallel for
            for (int j = (rk % rp); j <= n_1_rk; j = j + 2 * rk) { //  is this right?!
                for (int i = 0; i <= fmin(rk - 1, n - j - rk - 1); i++) {
                    if (floor((i + j) / (rp * 2)) == floor((i + j + rk) / (rp * 2))) {
                        if (Vnums[i + j] > Vnums[i + j + rk]) {
                            swap(Vnums[i + j], Vnums[i + j + rk]);
                        } else {
                            // cout << Vnums[i+j] << " >-< " << Vnums[i+j+rk] << std::endl;
                        }
                    }
                }
            }
        }
    }
    clock_gettime(CLOCK_MONOTONIC, &end_time);

    struct timespec start_time_verify, end_time_verify;
    clock_gettime(CLOCK_MONOTONIC, &start_time_verify);
    if (!verify(Vnums, n)) {
        printf("oopsy\n");
        return 1;
    }
    clock_gettime(CLOCK_MONOTONIC, &end_time_verify);

    printf("batcher, %i, %i, %.6f\n", N, n, get_elapsed_time(start_time, end_time));
}
