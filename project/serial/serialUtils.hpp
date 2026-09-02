#include <algorithm>
#include <cmath>
#include <fstream>
#include <iostream>
#include <string>

#include "../utils.hpp"

using namespace std;

bool verify(std::vector<int> &V, int n) {
    // n is the number of elements in the list
    // n = 2**N
    std::vector<int> sortedV(n);
    populate_vector(sortedV, n, ".sorted");
    for (int i = 0; i < n; i++) {
        if (V[i] != sortedV[i]) {
            cout << V[i] << " != " << sortedV[i] << std::endl;
            return false;
        }
    }

    return true;
}
