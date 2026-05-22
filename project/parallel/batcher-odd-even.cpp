#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <algorithm>
#include <vector>
#include <assert.h>
#include <iostream>
#include <fstream>
#include <string>
#include <cmath>
#include "omp.h"
#include "parallelUtils.hpp"

using namespace std;

int main(int argc, char *argv[]) {

    //  These var names make sense when you look at the wikipedia page below
    int N = 4;
    if (argc == 2)
        N = stoi(argv[1]);
    int n = pow(2, N);
    //printf("Working with a list of 2^%i (%i)\n", N, n);
    //int ij, ijrk;
    // for ranges of loops
    int rp, rk;
    std::vector<int> Vnums(n);
    populate_vector(Vnums, n);

    struct timespec start_time, end_time;
    clock_gettime(CLOCK_MONOTONIC, &start_time);

    // See https://en.wikipedia.org/wiki/Batcher_odd%E2%80%93even_mergesort
    for (int p = 0; p < N; p++) {
        rp = pow(2, p);
        //cout << 1 << std::endl;
        //#pragma omp parallel for
        for (int k = 0; k < N; k++) {
            //cout << 2 << std::endl;
            rk = (int)(rp / pow(2, k));
            if (rk < 1)
                continue;
            //cout << rk << " " << k << " " << p << std::endl;
            //continue; 
            int n_1_rk = n-1-rk;
            #pragma omp parallel for
            for (int j = (rk % rp); j <= n_1_rk; j=j+2*rk) {   //  is this right?!
                //cout << omp_get_thread_num()  << std::endl;
                for (int i = 0; i <= fmin(rk-1, n-j-rk-1); i++) {
                    //cout << " " << rp << " " << rk << " " << i << " " << j << " " << std::endl;
                    if (floor((i+j) / (rp*2)) == floor((i+j+rk) / (rp*2))) {
                        if ( Vnums[i+j] > Vnums[i+j+rk] ) {
                            //cout << Vnums[i+j] << " <-> " << Vnums[i+j+rk] << std::endl;
                            swap(Vnums[i+j], Vnums[i+j+rk]);
                        }
                        else {
                            //cout << Vnums[i+j] << " >-< " << Vnums[i+j+rk] << std::endl;
                        }
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
    /* printf("Batcher O/E *Verification* time: %.6f seconds\n", get_elapsed_time(start_time_verify, end_time_verify)); */

    //cout << "AFTER sort . . .\n";
    /*
    for (int i = 0; i < n; i++) {
        cout << pprint(Vnums[i]) << std::endl;
    }
    */
    //printf("Batcher O/E Execution time: %.6f seconds\n", get_elapsed_time(start_time, end_time));
    printf("batcher, %i, %i, %.6f\n", N, n, get_elapsed_time(start_time, end_time));

}
