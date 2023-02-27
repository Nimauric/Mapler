#include <iostream>
#include <fstream>
#include <vector> 
#include <algorithm>

using namespace std;

// argv[1] : "../data/assemblies/metaflye_SRR8073713/assembly.fasta"
// argv[2] : 50000

int main(int argc, char *argv[]) {
    fstream assembly;
    string line;

    int threshold = stoi(argv[2]);
    assembly.open (argv[1], std::fstream::in);

    // Store the contigs length in a vector
    vector<int> contig_lengths;
    while (getline(assembly, line)){
        if (line[0] == '>'){ 
            contig_lengths.push_back(0);
        } else {
            contig_lengths.back() += line.size();
        }
    }

    // Sort the contigs
    sort(contig_lengths.begin(), contig_lengths.end(), greater<int>());

    // Save the results as a CSV
    // TO DO

    // calculate total length and filter small contigs
    int total_length = 0;
    int total_number = 0;

    int filtered_length = 0;
    int filtered_number = 0;

    for (int length : contig_lengths){
        if(length > threshold){
            filtered_length += length;
            filtered_number += 1;
        }
        total_length += length;
        total_number += 1;
        
    }


    // Calculate N50 and L50
    int N50 = 0;
    int L50 = 0;
    int running_length = 0;

    for (int length : contig_lengths){
        running_length += length;
        L50 += 1;
        if (running_length > 0.5 * filtered_length){
            N50 = length;
            break;
        }
    }

    cout << '\n';


    cout << "After filtering contigs of " << threshold << "bp or less : \n";
    cout << total_number - filtered_number << " contigs were filtered (" << 100 - 100 * (float) filtered_number / (float) total_number <<"%) \n";
    cout << total_length- filtered_length << " bases were filtered (" << 100 - 100 * (float) filtered_length / (float) total_length <<"%) \n";
    cout << '\n';
    cout << "Total assembly length : " << filtered_length << "\n";
    cout << "Number of contigs : " << filtered_number << "\n";
    cout << "N50 : " << N50 << "\n";
    cout << "L50 : " << L50 << "\n";

    return 0;
}
