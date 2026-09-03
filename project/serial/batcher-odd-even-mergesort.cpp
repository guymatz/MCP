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

/** lo is the starting position and
 *  n is the length of the piece to be merged,
 *  r is the distance of the elements to be compared
 */
void oddEvenMerge(vector<int> &Vnums, int lo, int n, int r) {
    int m = r * 2;
    std::cout << "lo: " << lo << " + r: " << r << " = lo+r: " << lo + r << std::endl;
    std::cout << std::endl;
    if (m < n) {
        oddEvenMerge(Vnums, lo, n, m);     // even subsequence
        oddEvenMerge(Vnums, lo + r, n, m); // odd subsequence
        for (int i = lo + r; i + r < lo + n; i += m) {
            compex(Vnums, i, i + r);
        }
    } else {
        compex(Vnums, lo, lo + r);
    }
}

/** sorts a piece of length n of the array
 *  starting at position lo
 */
void oddEvenMergeSort(vector<int> &Vnums, int lo, int n) {
    if (n > 1) {
        int m = n / 2;
        oddEvenMergeSort(Vnums, lo, m);
        oddEvenMergeSort(Vnums, lo + m, m);
        oddEvenMerge(Vnums, lo, n, 1);
    }
}

void sort(vector<int> &Vnums) { oddEvenMergeSort(Vnums, 0, Vnums.size()); }

int main(int argc, char *argv[]) {
    //  These var names make sense when you look at the wikipedia page below
    //  Number of elements to sort is 2^t == N
    int t = 4;
    if (argc == 2)
        t = stoi(argv[1]);
    int N = pow(2, t);

    struct timespec start_time_verify, end_time_verify;
    struct timespec start_time, end_time;

    std::vector<int> Vnums(N);
    populate_vector(Vnums, N);

    clock_gettime(CLOCK_MONOTONIC, &start_time);
    sort(Vnums);
    clock_gettime(CLOCK_MONOTONIC, &end_time);

    clock_gettime(CLOCK_MONOTONIC, &start_time_verify);
    if (!verify(Vnums, N)) {
        printf("oopsy\n");
        return 1;
    }
    clock_gettime(CLOCK_MONOTONIC, &end_time_verify);

    printf("serial, batcher-odd-even-merge-sort, %i, %i, %.6f\n", t, N,
           get_elapsed_time(start_time, end_time));
}
