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

#include "serialUtils.hpp"

using namespace std;

void compex(vector<int> &Vnums, int origin, int partner) {
    if (Vnums[origin] > Vnums[partner]) {
        std::swap(Vnums[origin], Vnums[partner]);
    }
}

int main(int argc, char *argv[]) {
    //  These var names make sense when you look at the wikipedia page below
    //  Number of elements to sort is 2^t == N
    int t = 4;
    if (argc == 2)
        t = stoi(argv[1]);
    int N = pow(2, t);

    std::vector<int> Vnums(N);
    populate_vector(Vnums, N);

    struct timespec start_time, end_time;
    clock_gettime(CLOCK_MONOTONIC, &start_time);

    int r, d;
    int origin, partner;
    // See https://en.wikipedia.org/wiki/Batcher_odd%E2%80%93even_mergesort
    for (int p = pow(2, t - 1); p > 0; p = p / 2) {
        r = 0;
        d = p;
        for (int q = pow(2, t - 1); p <= q; q = q / 2) {
            for (int i = 0; i < N - d; i++) {
                origin = i;
                partner = i + d;
                if ((i & p) == r) {
                    compex(Vnums, origin, partner);
                }
            }
            if (q != p) {
                d = q - p;
            }
            r = p;
        }
    }
    clock_gettime(CLOCK_MONOTONIC, &end_time);

    struct timespec start_time_verify, end_time_verify;
    clock_gettime(CLOCK_MONOTONIC, &start_time_verify);
    if (!verify(Vnums, N)) {
        printf("oopsy\n");
        return 1;
    }
    clock_gettime(CLOCK_MONOTONIC, &end_time_verify);

    printf("serial, batcher-odd-even, %i, %i, %.6f\n", t, N, get_elapsed_time(start_time, end_time));
}
