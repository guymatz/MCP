// #include <stdio.h>
// #include <stdlib.h>
// #include <time.h>
// #include <algorithm>
// #include <vector>
// #include <assert.h>
#include <cmath>
#include <fstream>
#include <iostream>
#include <string>

#include "../utils.hpp"
#include "omp.h"

using namespace std;

bool verify(std::vector<int> &V, int n, bool verbose = false) {
  // n is the number of elements in the list
  // n = 2**N
  bool verifySucceeded = true;
  std::vector<int> sortedV(n);

  struct timespec start_time, end_time;
  clock_gettime(CLOCK_MONOTONIC, &start_time);
  populate_vector(sortedV, n, ".sorted");
  clock_gettime(CLOCK_MONOTONIC, &end_time);
  /* printf("Sorted File Load time: %.6f seconds\n",
   * get_elapsed_time(start_time, end_time)); */

  // cout << "Verbose? " << verbose << std::endl;
  clock_gettime(CLOCK_MONOTONIC, &start_time);
#pragma omp parallel for
  for (int i = 0; i < n; i++) {
    // cout << omp_get_thread_num() << std::endl;
    if (V[i] != sortedV[i]) {
      if (verbose) {
        cout << "n: " << n << std::endl;
        cout << "i: " << i << std::endl;
        cout << V[i] << " != " << sortedV[i] << std::endl;
      }
      verifySucceeded = false;
    }
  }
  clock_gettime(CLOCK_MONOTONIC, &end_time);
  /* printf("Array Comparison time: %.6f seconds\n",
   * get_elapsed_time(start_time, end_time)); */
  /*
  if (verifySucceeded)
      cout << n << " elements are looking good!" << std::endl;
  */

  return verifySucceeded;
}
