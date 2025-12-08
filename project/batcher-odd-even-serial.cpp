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

using namespace std;

// Function to generate a random number
void populate_vector(int V[], int n) {
    //  if file exists, populate array with the file,
    //  otherwise create file and array at the same file
    string s; // will store ints read from the file
    string fname = "randos-" + std::to_string(n) + ".dat";
    ifstream f(fname);
    if (f.is_open()) {
        cout << "File is open . . .\n";
        for (int i = 0; i < n; i++) {
            getline(f, s);
            V[i] = stoi(s);
        }
    }
    else {
        srand(2);
        size_t rando;
        ofstream f(fname);
        //cout << "Creating File . . .\n";
        for (int i = 0; i < n; i++) {
            rando = std::rand();
            V[i] = rando;
            f << rando << std::endl;
        }
    }
    f.close();
}

int main(int argc, char *argv[]) {

    int N = 4;
    if (argc == 2)
        N = stoi(argv[1]);
    int n = pow(2, N);
    printf("Working with a list of 2^%i (%i)\n", N, n);
    int p, k, j, i, ij, ijrk;
    // for ranges of loops
    int rp, rk, rj, ri;
    int Vnums[n];
    populate_vector(Vnums, n);

    //for p in [ 2**r for r in range(0, math.floor(math.log2(N))) ]:
    for (int p = 0; p < floor(log2(n)); p++) {
        rp = pow(2, p);
        //printf("p: %i\n", rp);
        //for k in [ int(p/(2**r)) for r in range(0, math.floor(math.log2(N))) ]:
        for (int k = 0; k < floor(log2(N)); k++) {
            rk = (int)(rp / pow(2, k));
            //printf("k: %i\n", rk);
            if (rk < 1)
                continue;
            //printf("k: %i\n", rk);
            //for j in range(int(k % p), N-1-k+1, 2*k):
            for (int j = (rk % rp); j < n-1-rk+1; j=j+2*rk) {   //  is this right?!
                //printf("j: %i %i %i\n", rp, rk, j);
                //for i in range(0, min(k-1, N-j-k-1)+1, 1):
                for (int i = 0; i < fmin(rk-1, n-j-rk-1)+1; i++) {
                    //printf("all: %i %i %i %i %i\n", i, j, rk, rp, N);
                    if (floor((i+j) / (rp*2)) == floor((i+j+rk) / (rp*2))) {
                        if ( Vnums[i+j] > Vnums[i+j+rk] ) {
                            //printf("Swapping %i (%i) <-> %i (%i)\n", Vnums[i+j], i+j, Vnums[i+j+rk], i+j+rk);
                            swap(Vnums[i+j], Vnums[i+j+rk]);
                            /*
                            ij = Vnums[i+j];
                            ijrk = Vnums[i+j+rk];
                            Vnums[i+j] = ijrk;
                            Vnums[i+j+rk] = ij;
                            for (int i = 0; i < n; i++) {
                                cout << Vnums[i] << std::endl;
                            }
                            cout << std::endl;
                            */
                        }
                    }
                }
            }
        }
    }

    //cout << "AFTER sort . . .\n";
    for (int i = 0; i < n; i++) {
        cout << i << " " << Vnums[i] << std::endl;
    }
}
