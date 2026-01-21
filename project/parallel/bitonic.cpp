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
    bool verbose = false;
    if (argc >= 2)
        N = stoi(argv[1]);
    if (argc >= 3) {
        verbose = true;
    }
    int n = pow(2, N);
    std::vector<int> Vnums(n);
    populate_vector(Vnums, n);

    /*
    for (int i = 0; i < n; i++) {
        cout << pp(Vnums[i]) << std::endl;
    }
    */

    struct timespec start_time, end_time;
    clock_gettime(CLOCK_MONOTONIC, &start_time);

    int startIdx, distance, subArraySize, swapPartner;

    // We loop through "sub arrays" of the original vector, 2 elements, then
    // 4 , then 8 . . .
    for (subArraySize=2; subArraySize<=n; subArraySize=subArraySize*2 ) {
        //cout << "SUBaRRAYsIZE" << "\t" << "distance" << "\t" << "startIdx" << "\t" << "swapPartner" << std::endl;
        // we break the problem into "sub array" halves
        for (distance=subArraySize/2; distance>0; distance=distance/2) {
        //cout << "Thread ID" << "\t" << "subArraySize" << "\t" << "DISTANCE" << "\t" << "startIdx" << "\t" << "swapPartner" << std::endl;
            // we loop through elements of the sub array and sort "distant" neighbors
            #pragma omp parallel for private(swapPartner)
            for (startIdx=0; startIdx<n; startIdx++) {
                swapPartner=startIdx^distance;
                if ( swapPartner > startIdx ) {
                    //cout << omp_get_thread_num() << "\t\t" << subArraySize << "\t\t" << distance << "\t\t" << startIdx << "\t\t" << swapPartner << std::endl << std::endl;
                    // Check "direction" of sort, and values in array
                    // First ascending . . .
                    if ( ( ((int)floor(startIdx / subArraySize) % 2) == 0) && Vnums[startIdx] > Vnums[swapPartner])  {
                        swap(Vnums[startIdx], Vnums[swapPartner]);
                    }
                    // then descending
                    if ( ( ((int)floor(startIdx / subArraySize) % 2) !=0) && Vnums[startIdx] < Vnums[swapPartner]) {
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
    //cout << verbose << std::endl;
    if (! verify(Vnums, n, verbose)) {
        printf("oopsy\n");
        return 1;
    }
    clock_gettime(CLOCK_MONOTONIC, &end_time_verify);
    printf("Bitonic Verification time: %.6f seconds\n", get_elapsed_time(start_time_verify, end_time_verify));

    printf("Bitonic Execution time: %.6f seconds\n", get_elapsed_time(start_time, end_time));
}
