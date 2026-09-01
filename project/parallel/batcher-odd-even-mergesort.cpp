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

void compex(vector<int> &Vnums, int origin, int partner) {
  if (Vnums[origin] > Vnums[partner]) {
    // cout << "Swapping " << Vnums[origin] << "\t" <<  Vnums[partner] <<
    // std::endl;
    std::swap(Vnums[origin], Vnums[partner]);
  }
}

/** lo is the starting position and
 *  n is the length of the piece to be merged,
 *  r is the distance of the elements to be compared
 */
void oddEvenMerge(vector<int> &Vnums, int lo, int n, int r) {
    int m=r*2;
    /* std::cout << "oddEvenMerge - lo: " << lo << ", n: " << n << ", r: " << r << ", m:" << m << std::endl; */
    if (m<n)
    {
        oddEvenMerge(Vnums, lo, n, m);      // even subsequence
        oddEvenMerge(Vnums, lo+r, n, m);    // odd subsequence
        int ORIGIN = lo+r;
        int UPPER_BOUND = lo + n;
        int LOWER_BOUND = ORIGIN + r;
        //for (int i=lo+r; i+r<lo+n; i+=m) // Original loop
        #pragma omp parallel for
        for (int i=ORIGIN; LOWER_BOUND < UPPER_BOUND; i+=m) {
            std::cout << "start: " << i << ", i+r: " << i+r << ", UPPER_BOUND: " << UPPER_BOUND  << std::endl;
            compex(Vnums, i, i+r);
            LOWER_BOUND = i + r;
        }
    }
    else {
        /* std::cout << "Comparing: " << Vnums[lo] << " at pos " << lo << " - to - " << Vnums[lo+r] << " at pos " << lo+r << std::endl; */
        compex(Vnums, lo, lo+r);
    }
}

/** sorts a piece of length n of the array
 *  starting at position lo
 */
void oddEvenMergeSort(vector<int> &Vnums, int lo, int n) {
    /* std::cout << "***** oddEvenMergeSort - lo: " << lo << ", n: " << n << std::endl; */
    if (n>1) {
        int m=n/2;
        oddEvenMergeSort(Vnums, lo, m);
        oddEvenMergeSort(Vnums, lo+m, m);
        /* std::cout << "Calling oddEvenMerge - lo: " << lo << ", n: " << n << std::endl; */
        oddEvenMerge(Vnums, lo, n, 1);
    }
}

void sort(vector<int> &Vnums)
{
    oddEvenMergeSort(Vnums, 0, Vnums.size());
}

int main(int argc, char *argv[]) {
  //  These var names make sense when you look at the wikipedia page below
  int t = 4;
  if (argc == 2)
    t = stoi(argv[1]);
  int N = pow(2, t);
  // printf("Working with a list of 2^%i (%i)\n", N, n);
  // int ij, ijrk;
  //  for ranges of loops
  std::vector<int> Vnums(N);
  populate_vector(Vnums, N);

  for (int i = 0; i < N; i++) {
    // cout << "BEFORE: " << Vnums[i] << std::endl;
    // cout << i << " " << Vnums[i] << std::endl;
  }

  struct timespec start_time, end_time;
  clock_gettime(CLOCK_MONOTONIC, &start_time);
  sort(Vnums);
  clock_gettime(CLOCK_MONOTONIC, &end_time);

  struct timespec start_time_verify, end_time_verify;
  clock_gettime(CLOCK_MONOTONIC, &start_time_verify);
  if (!verify(Vnums, N)) {
    printf("oopsy\n");
    return 1;
  }
  clock_gettime(CLOCK_MONOTONIC, &end_time_verify);
  /* printf("Batcher O/E Verification time: %.6f seconds\n",
   * get_elapsed_time(start_time_verify, end_time_verify)); */

  cout << "AFTER sort . . .\n";
  for (int i = 0; i < N; i++) {
      /* cout << pprint(Vnums[i]) << std::endl; */
  }
  printf("batcher-odd-even-merge-sort, %i, %i, %.6f\n", t, N, get_elapsed_time(start_time, end_time));
}
