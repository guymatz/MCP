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

string pp(int i, string delim="_") {
    string news = "";
    string s = std::to_string(i);
    int lens = 0;
    while (s.length() > 3) {
        lens = s.length();
        news = delim + s.substr(lens-3, lens-1) + news;
        s = s.substr(0, lens-3);
    }
    if (s.length() > 0)
        news = s + news;
    return news;
}

// Function to generate a random number
void populate_vector(int V[], int n) {
    //  if file exists, populate array with the file,
    //  otherwise create file and array at the same file
    string s; // will store ints read from the file
    string fname = "dat/randos-" + std::to_string(n) + ".dat";
    ifstream f(fname);
    if (f.is_open()) {
        //cout << "Using " << fname << " since it already exists . . ." << std::endl;
        for (int i = 0; i < n; i++) {
            getline(f, s);
            V[i] = stoi(s);
        }
    }
    else {
        srand(1);
        cout << "Using new file " << fname << std::endl;
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

    //  These var names make sense when you look at the wikipedia page below
    int N = 4;
    if (argc == 2)
        N = stoi(argv[1]);
    int n = pow(2, N);
    //printf("Working with a list of 2^%i (%i)\n", N, n);
    //int ij, ijrk;
    // for ranges of loops
    int rp, rk;
    int Vnums[n];
    populate_vector(Vnums, n);

    for (int i = 0; i < n; i++) {
        //cout << "BEFORE: " << Vnums[i] << std::endl;
        //cout << i << " " << Vnums[i] << std::endl;
    }

    // See https://en.wikipedia.org/wiki/Batcher_odd%E2%80%93even_mergesort
    for (int p = 0; p < floor(log2(n)); p++) {
        rp = pow(2, p);
        for (int k = 0; k < floor(log2(n)); k++) {
            rk = (int)(rp / pow(2, k));
            if (rk < 1)
                continue;
            //cout << rk << " " << k << " " << p << std::endl;
            //continue; 
            for (int j = (rk % rp); j <= n-1-rk; j=j+2*rk) {   //  is this right?!
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

    //cout << "AFTER sort . . .\n";
    for (int i = 0; i < n; i++) {
        cout << pp(Vnums[i]) << std::endl;
        //cout << i << " " << Vnums[i] << std::endl;
    }
}
