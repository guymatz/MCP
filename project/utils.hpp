#include <algorithm>
#include <cmath>
#include <fstream>
#include <iostream>
#include <string>
#include <filesystem>
#include <iomanip>

using namespace std;

// function to get time diff
double get_elapsed_time(struct timespec start, struct timespec end) {
  // return (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1e9;
  return (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1e9;
}

// Function to generate a random number
void populate_vector(vector<int> &V, int n, string suffix = "") {
  // cout << "In pop vec: " << n << std::endl;;
  string s; // will store ints read from the file
  string fname = "../dat/randos-" + std::to_string(n) + ".dat" + suffix;
  ifstream f(fname.c_str());
  // cout << "Checking file: " << fname << std::endl;
  if (f.is_open()) {
    // cout << "Using file - " << fname << " - since it already exists . . ." <<
    // std::endl;
    for (int i = 0; i < n; i++) {
      // cout << i << " ";
      getline(f, s);
      V[i] = stod(s);
    }
  } else {
    srand(1);
    cout << "Using new file " << fname << std::endl;
    int rando;
    ofstream f(fname);
    // cout << "Creating File . . .\n";
    for (int i = 0; i < n; i++) {
      rando = std::rand();
      V[i] = rando;
      f << rando << std::endl;
    }
    // cout << "DONE Creating File . . .\n";

    // Now we create sorted file
    fname = fname + ".sorted";
    ofstream sortedf(fname.c_str());
    vector<int> sortedV = V;
    std::sort(sortedV.begin(), sortedV.end());
    for (auto i : sortedV)
      sortedf << i << std::endl;
    sortedf.close();
  }
  f.close();
  // cout << "DONE in pop_vec . . .\n";
}

string pprint(int i, string delim = "_") {
  string news = "";
  string s = std::to_string(i);
  int lens = 0;
  while (s.length() > 3) {
    lens = s.length();
    news = delim + s.substr(lens - 3, lens - 1) + news;
    s = s.substr(0, lens - 3);
  }
  if (s.length() > 0)
    news = s + news;
  return news;
}

std::string prog_name(const char* argv0) {
    // 1. Guard against a null pointer or an empty string
    if (argv0 == nullptr || argv0[0] == '\0') {
        return "";
    }
    std::string path(argv0);

    // 2. Find the last slash to isolate the filename (handles Windows '\' and Linux '/')
    size_t last_slash = path.find_last_of("\\/");
    std::string filename = (last_slash == std::string::npos) ? path : path.substr(last_slash + 1);

    // 3. Find the last extension dot in the isolated filename
    size_t last_dot = filename.find_last_of('.');
    return (last_dot == std::string::npos) ? filename : filename.substr(0, last_dot);
}
