//#include <stdio.h>
//#include <stdlib.h>
//#include <time.h>
//#include <algorithm>
//#include <vector>
//#include <assert.h>
#include <iostream>
#include <fstream>
#include <string>
#include <cmath>
//#include <benchmark/benchmark.h>

using namespace std;

// function to get time diff
double get_elapsed_time(struct timespec start, struct timespec end) {
    //return (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1e9;
    return (end.tv_sec - start.tv_sec) +
            (end.tv_nsec - start.tv_nsec) / 1e9;
}

// Function to generate a random number
void populate_vector(vector<size_t>& V, size_t n, string suffix="") {
    //cout << "In pop vec: " << n << std::endl;;
    string s; // will store ints read from the file
    string fname = "dat/randos-" + std::to_string(n) + ".dat" + suffix;
    ifstream f(fname);
    //cout << "Checking file: " << f << std::endl;
    if (f.is_open()) {
        //cout << "Using file - " << fname << " - since it already exists . . ." << std::endl;
        for (size_t i = 0; i < n; i++) {
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
        for (size_t i = 0; i < n; i++) {
            rando = std::rand();
            V[i] = rando;
            f << rando << std::endl;
        }
        //cout << "DONE Creating File . . .\n";
    }
    f.close();
    //cout << "DONE in pop_vec . . .\n";
}

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

bool verify(std::vector<size_t>& V, size_t N) {
    // n is the number of elements in the list
    // n = 2**N
    size_t n = pow(2, N);
    std::vector<size_t> sortedV(n);
    populate_vector(sortedV, N, "sorted");
    for (size_t i=0; i < pow(2, n); i++) {
        if (V[i] != sortedV[i]) {
            cout << "N: " << N << std::endl;
            cout << "i: " << i << std::endl;
            cout << V[i] << " != " << sortedV[i] << std::endl;
            return false;
        }
    }
    return true;
}
