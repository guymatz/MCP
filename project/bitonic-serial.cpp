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

// Function to generate a random number
void populate_vector(int V[], int n) {
    //cout << "In pop vec: " << n << std::endl;;
    string s; // will store ints read from the file
    string fname = "dat/randos-" + std::to_string(n) + ".dat";
    ifstream f(fname);
    //cout << "Checking file: " << f << std::endl;
    if (f.is_open()) {
        //cout << "Using file - " << fname << " - since it already exists . . ." << std::endl;
        for (int i = 0; i < n; i++) {
            //cout << i << " ";
            getline(f, s);
            V[i] = stoi(s);
        }
    }
    else {
        srand(1);
        //cout << "Using new file " << fname << std::endl;
        size_t rando;
        ofstream f(fname);
        //cout << "Creating File . . .\n";
        for (int i = 0; i < n; i++) {
            rando = std::rand();
            V[i] = rando;
            f << rando << std::endl;
        }
        //cout << "DONE Creating File . . .\n";
    }
    f.close();
    //cout << "DONE in pop_vec . . .\n";
}

void bitonicMerge(int V[], int low, int count, int direction) {
    int k;
    if (count <= 1)
        return;
    k = count / 2;
    for (int i = low; i <= low + k - 1; i++) {
        if ((direction == 1 && V[i] > V[i + k]) || (direction == 0 && V[i] < V[i + k]) ) {
            //cout << "Swapping " << V[i] << " " << V[i+k] << std::endl;
            swap(V[i], V[i+k]);
        }
    }
    bitonicMerge(V, low, k, direction);
    bitonicMerge(V, low+k, k, direction);
}

void bitonicSort(int V[], int low, int count, int direction) {
    
    int k;
    if (count <= 1)
        return;
    k = count / 2;
    bitonicSort(V, low, k, 1);
    bitonicSort(V, low+k, k, 0);

    bitonicMerge(V, low, count, direction);
}

int main(int argc, char *argv[]) {

    // See https://en.wikipedia.org/wiki/Bitonic_sorter
    int N = 4;
    if (argc == 2)
        N = stoi(argv[1]);
    int n = pow(2, N);
    int Vnums[n];
    populate_vector(Vnums, n);

    //cout << "n: " << n << ", N: " << N << std::endl;
    for (int i = 0; i < n; i++) {
        //cout << "before: " << Vnums[i] << std::endl;
    }

    bitonicSort(Vnums, 0, n, 1);

    //cout << "AFTER sort . . .\n";
    for (int i = 0; i < n; i++) {
        cout << Vnums[i] << std::endl;
    }
}
