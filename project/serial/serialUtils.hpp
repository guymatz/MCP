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
#include "../utils.hpp"

using namespace std;

bool verify(std::vector<size_t>& V, size_t n) {
    // n is the number of elements in the list
    // n = 2**N
    std::vector<size_t> sortedV(n);
    populate_vector(sortedV, n, ".sorted");
    for (size_t i=0; i < n; i++) {
        if (V[i] != sortedV[i]) {
            //cout << "n: " << n << std::endl;
            //cout << "i: " << i << std::endl;
            cout << V[i] << " != " << sortedV[i] << std::endl;
            return false;
        }
    }
    cout << n << " elements are looking good!" << std::endl;
    return true;
}
