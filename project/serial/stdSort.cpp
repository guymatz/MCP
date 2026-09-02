#include <algorithm>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

#include "serialUtils.hpp"

using namespace std;

int main(int argc, char *argv[]) {
    // See https://en.wikipedia.org/wiki/Bitonic_sorter
    int N = 4;
    if (argc == 2)
        N = stoi(argv[1]);
    int n = pow(2, N);
    std::vector<int> Vnums(n);
    populate_vector(Vnums, n);

    struct timespec start_time, end_time;
    clock_gettime(CLOCK_MONOTONIC, &start_time);
    sort(Vnums.begin(), Vnums.end());
    clock_gettime(CLOCK_MONOTONIC, &end_time);

    struct timespec start_time_verify, end_time_verify;
    clock_gettime(CLOCK_MONOTONIC, &start_time_verify);
    if (!verify(Vnums, n)) {
        printf("oopsy\n");
        return 1;
    }
    clock_gettime(CLOCK_MONOTONIC, &end_time_verify);

    printf("std-sort, %i, %i, %.6f\n", N, n, get_elapsed_time(start_time, end_time));
}
