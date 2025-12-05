# Parallel sorting
## Introduction
Sorting algorithms are a fundamental step for many other algorithms. Therefore, optimizing them is
crucial for many applications. For this assignment, you will explore two parallel sorting algorithms,
Bitonic Sorter and Batcher oddeven mergesort.

### Bitonic sorter
The Bitonic sorter is based on the concept of bitonic sequences, i.e. sequences that consist of a
non-decreasing sequence followed by a non-increasing one. If the sequence has n items, where n is
a power of 2, $n = 2^k$:

$$\exists m : x_0 \leq x_1 \leq \dots \leq x_{m−1} \leq x_m \geq x_{m+1} \geq \dots \geq x_{n−1}$$

1. To sort an unsorted sequence, it has to be transformed into a bitonic sequence first. This is
achieved by sorting pairs of elements in increasing/decreasing order and merging them, thus
obtaining length-4 bitonic sequences. The step is repeated until only one bitonic sequence
remains (Bitonic merge sort).

2. If a compare-exchange operation is applied to items $x_i , x_{i+n/2}$, the result is two
bitonic sequences, where all the elements in the first one are smaller than the elements in the second
one. Therefore, by recursively applying this operation to a bitonic sequence, a sorted sequence
is obtained.

### Batcher odd-even mergesort

This algorithm is based on the odd-even merge algorithm. Given two sorted lists, they can be merged
by:
1. recursively merging the entries in even(odd) positions of the two lists
2. interleaving the two resulting lists
3. rearranging unordered neighbours by compare-and-exchange operations
Therefore, after a first step of sorting pairs of neighbouring elements, the odd-even merge algorithm
can be recursively applied to pairs of lists to obtain a sorted list.

## Task
The goal is to implement and analyze a parallel version of the sorting algorithms sketched above, and
evaluate the time complexity across different computational paradigms (targeting CPU and GPU). The
project can be addressed in three parts:

### Dataset generation
Generate large sequences of random integers, of size up to $\mathcal{O}(106)$ to $\mathcal{O}(108)$;
choose a suitable range to avoid many repeated entries. The dataset can be
generated using rand() on the CPU. Fix the
random seed for reproducibility and for testing the consistency of the different sorting implementations
(or save the dataset to file).

### Sorting algorithms
Implement the two sorting algorithms using:
- **CPU (sequential)**
Baseline to check the correctness of the results.
- **CPU (parallel)**
Use pragmas for directive-based CPU implementation. Use reductions or atomic operations
where necessary. Avoid race conditions when accessing the data.
- **CUDA**
Develop a parallel version for GPU, implementing custom CUDA kernels:
    1. Start by using the global memory
    2. Improve performance by exploiting shared memory
Synchronize threads whenever needed.
### Benchmarking
- Compare the execution times of the different sorting algorithms across the different implementations at different levels of optimization.
- Retrieve execution times for datasets of increasing size: extract the scaling of the algorithms
and compare with the theoretical ones.
## Extra
### Bonus features
- Develop a directive-based implementation of the parallel sorting algorithm for GPU and compare its performance with your custom implementations.
- Use a GPU-based library for parallel sorting and compare it with custom implementations.
