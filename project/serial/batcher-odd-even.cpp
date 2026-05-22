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
    // cout << "Swapping " << Vnums[origin] << "\t" <<  Vnums[partner] <<
    // std::endl;
    std::swap(Vnums[origin], Vnums[partner]);
  }
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

  int r, d;
  int origin, partner;
  // See https://en.wikipedia.org/wiki/Batcher_odd%E2%80%93even_mergesort
  // cout << pow(2, N-1) << "\t" << n << "\t" << N << "\t"  << std::endl;
  for (int p = pow(2, t - 1); p > 0; p = p / 2) {
    // cout << p << "\t" << N << "\t" << t << "\t"  << std::endl;
    r = 0;
    d = p;
    for (int q = pow(2, t - 1); p <= q; q = q / 2) {
      // cout << p << "\t" << q << "\t" << r << "\t"  << d << std::endl;
      for (int i = 0; i < N - d; i++) {
        origin = i;
        partner = i + d;
        if ((i & p) == r) {
          // cout << "***\t" << origin  << "\t"  << partner << "\t" << (i & p)
          // << "\t" << r << std::endl;
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
  /* printf("Batcher O/E Verification time: %.6f seconds\n",
   * get_elapsed_time(start_time_verify, end_time_verify)); */

  // cout << "AFTER sort . . .\n";
  /*
  for (int i = 0; i < n; i++) {
      cout << pprint(Vnums[i]) << std::endl;
  }
  */
  printf("batcher-odd-even, %i, %i, %.6f\n", t, N, get_elapsed_time(start_time, end_time));
}
