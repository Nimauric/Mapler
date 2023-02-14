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

    int total_length = 0;
    int filtered out = 0;
    vector<int> contig_lengths;
    contig_lengths.push_back(0);

    // Get the length of each contig
    while (getline(assembly, line)){
        if (line[0] == '>'){ 
            if (contig_lengths.back() > threshold ) {
                total_length += contig_lengths.back();
                contig_lengths.push_back(0);         
            } else {
                filtered_out += 1;
            }
            contig_lengths.back() = 0;
        } else {
            contig_lengths.back() += line.size();
        }
    }
    if (contig_lengths.back() <= threshold ) {
        contig_lengths.back() = 0;        
    }

    assembly.close();

    // Sort the contigs
    sort(contig_lengths.begin(), contig_lengths.end(), greater<int>());

    // Calculate N50 and L50
    int N50 = 0;
    int L50 = 0;
    int running_length = 0;

    for (int length : contig_lengths){
        running_length += length;
        L50 += 1;
        if (running_length > 0.5 * total_length){
            N50 = length;
            break;
        }
    }
    std::cout << '\n';

    std::cout << "After filtering contigs of " << threshold << "bp or less (" << filtered_out << " were filtered out): \n";
    std::cout << "Total assembly length : " << total_length << "\n";
    std::cout << "Numbers of contigs : " << contig_lengths.size() << "\n";
    std::cout << "N50 : " << N50 << "\n";
    std::cout << "L50 : " << L50 << "\n";

    return 0;
}
