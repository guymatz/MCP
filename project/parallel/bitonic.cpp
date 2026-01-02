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
#include "omp.h"

using namespace std;

int main(int argc, char *argv[]) {

    // See https://en.wikipedia.org/wiki/Bitonic_sorter
    int N = 4;
    if (argc == 2)
        N = stoi(argv[1]);
    size_t n = pow(2, N);
    std::vector<size_t> Vnums(n);
    populate_vector(Vnums, n);

    /*
    for (int i = 0; i < n; i++) {
        cout << pp(Vnums[i]) << std::endl;
    }
    */

    struct timespec start_time, end_time;
    clock_gettime(CLOCK_MONOTONIC, &start_time);

    size_t startIdx, distance, subArraySize, swapPartner;

    // We loop through "sub arrays" of the original vector, 2 elements, then
    // 4 , then 8 . . .
    for (subArraySize=2; subArraySize<=n; subArraySize=subArraySize*2 ) {
        // we break the problem into "sub array" halves
        for (distance=subArraySize/2; distance>0; distance=distance/2) {
            #pragma omp for
            for (startIdx=0; startIdx<n; startIdx++) {
                // we loop through elements of the sub array and sort
                // "distant" neighbors
                swapPartner=startIdx^distance;
                if ( swapPartner >startIdx ) {
                    if ((startIdx & subArraySize)==0 && Vnums[startIdx] > Vnums[swapPartner])  {
                        //cout << "0 : " << startIdx << " " << subArraySize << " " << (startIdx&subArraySize) << std::endl;
                        swap(Vnums[startIdx], Vnums[swapPartner]);
                    }
                    if (((startIdx & subArraySize) !=0) && Vnums[startIdx] < Vnums[swapPartner]) {
                        //cout << "!=0 : " << startIdx << " " << subArraySize << " " << (startIdx&subArraySize) << std::endl;
                        swap(Vnums[swapPartner], Vnums[startIdx]);
                    }
                }
            }
        }
    }

    clock_gettime(CLOCK_MONOTONIC, &end_time);

    struct timespec start_time_verify, end_time_verify;
    clock_gettime(CLOCK_MONOTONIC, &start_time_verify);
    if (! verify(Vnums, n)) {
        printf("oopsy\n");
        return 1;
    }
    clock_gettime(CLOCK_MONOTONIC, &end_time_verify);
    printf("Bitonic Verification time: %.6f seconds\n", get_elapsed_time(start_time_verify, end_time_verify));


    //cout << "AFTER sort . . .\n";

    /*
    for (int i = 0; i < n; i++) {
        cout << pp(Vnums[i]) << std::endl;
    }
    */

    printf("Bitonic Execution time: %.6f seconds\n", get_elapsed_time(start_time, end_time));
}
