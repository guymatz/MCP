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
#include "cudaUtils.cuh"

using namespace std;

int main(int argc, char *argv[]) {

    //  These var names make sense when you look at the wikipedia page below
    int N = 4;
    if (argc == 2)
        N = stoi(argv[1]);
    size_t n = pow(2, N);
    //printf("Working with a list of 2^%i (%i)\n", N, n);
    //int ij, ijrk;
    // for ranges of loops
    size_t rp, rk;
    std::vector<int> Vnums(n);
    populate_vector(Vnums, n);
/*
    for (size_t i = 0; i < n; i++) {
        cout << i << " " << Vnums[i] << std::endl;
    }
*/

    struct timespec start_time, end_time;
    clock_gettime(CLOCK_MONOTONIC, &start_time);

    // See https://en.wikipedia.org/wiki/Batcher_odd%E2%80%93even_mergesort
    for (size_t p = 0; p < N; p++) {
        rp = pow(2, p);
        for (size_t k = 0; k < N; k++) {
            rk = (int)(rp / pow(2, k));
            if (rk < 1)
                continue;
            //cout << rk << " " << k << " " << p << std::endl;
            //continue; 
            for (size_t j = (rk % rp); j <= n-1-rk; j=j+2*rk) {   //  is this right?!
                for (size_t i = 0; i <= fmin(rk-1, n-j-rk-1); i++) {
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
    printf("Batcher O/E Verification time: %.6f seconds\n", get_elapsed_time(start_time_verify, end_time_verify));

/*
    cout << "AFTER sort . . .\n";
    for (int i = 0; i < n; i++) {
        cout << pp(Vnums[i]) << std::endl;
    }
*/

    printf("Batcher O/E Execution time: %.6f seconds\n", get_elapsed_time(start_time, end_time));

}
