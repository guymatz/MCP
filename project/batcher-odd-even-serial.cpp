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
//  Number of elements in our list
//const int N = 1e7
const int N = 1e1;

// Function to generate a random number
void populate_vector(int V[]) {
    cout << "In pop vec\n";
    string s; // will store ints read from the file
    string fname = "randos.dat";
    ifstream f(fname);
    cout << "Checking file . . .\n";
    if (f.is_open()) {
        cout << "File is open . . .\n";
        for (int i = 0; i < N; i++) {
            getline(f, s);
            V[i] = stoi(s);
        }
    }
    else {
        cout << "File does not exist . . .\n";
        srand(1);
        size_t rando;
        ofstream f(fname);
        cout << "Creating File . . .\n";
        for (int i = 0; i < N; i++) {
            rando = std::rand();
            V[i] = rando;
            f << rando << std::endl;
        }
        cout << "DONE Creating File . . .\n";
    }
    f.close();
    cout << "DONE in pop_vec . . .\n";
}

int main(int argc, char *argv[]) {

    cout << "In main\n";
    //  for loops
    int p, k, j, i;
    // for ranges of loops
    int rp, rk, rj, ri;
    int Vnums[N];
    Vnums[0] = 15;
    populate_vector(Vnums);
    cout << "DONE In main\n";
    cout << "BEFORE sort . . .\n";
    for (int i = 0; i < N; i++) {
        cout << Vnums[i] << std::endl;
    }

    //for p in [ 2**r for r in range(0, math.floor(math.log2(N))) ]:
    for (int p = 0; p < floor(log2(N)); pow(p, 2)) {
        //for k in [ int(p/(2**r)) for r in range(0, math.floor(math.log2(N))) ]:
        for (int k = 0; k < floor(log2(N)); (int)(p / (pow(k, 2)))) {
            if (k < 1)
                continue;
            //for j in range(int(k % p), N-1-k+1, 2*k):
            for (int j = (int)(k % p); j < N-1-k+1; j++) {   //  is this right?!
                //for i in range(0, min(k-1, N-j-k-1)+1, 1):
                for (int i = 0; i < fmin(k-1, N-j-k-1); i++) {
                    //print(math.floor((i+j) / (p*2)), math.floor((i+j+k) / (p*2)))
                    printf("%i, %i, %i, %i\n", p, k, j, i);
                    if (floor((i+j) / (p*2)) == floor((i+j+k) / (p*2))) {
                        //print(nums, i+j, i+ j+k)
                        //print(Vnums)
                        swap(Vnums[i+j], Vnums[i+j+k]);
                        //print(Vnums)
                    }
                }
            }
        }
    }

    cout << "AFTER sort . . .\n";
    for (int i = 0; i < N; i++) {
        cout << Vnums[i] << std::endl;
    }
}
