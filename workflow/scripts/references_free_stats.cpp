#include <iostream>
#include <fstream>
#include <unordered_map>
#include <vector> 
#include <algorithm>

using namespace std;

// argv[1] : "../data/assemblies/metaflye_SRR8073713/assembly.fasta"
// argv[2] : 50000
// argv[3] "../data/stats_reports/metaflye_SRR8073714/contigs_stats.tsv"
// argv[4] "../data/stats_reports/metaflye_SRR8073714/contigs_stats_with_GC_content.tsv"


// Horribly unoptimised, but it's C++, so still fast. Can be optimised, but not a priority

int main(int argc, char *argv[]) {
    int threshold = stoi(argv[2]);
    fstream file;
    string line;
    
    ////////// Build a text-based-report //////////
    file.open (argv[1], std::fstream::in);

    int total_length = 0;
    int filtered_out = 0;
    vector<int> contig_lengths;
    contig_lengths.push_back(0);

    // Get the length of each contig
    while (getline(file, line)){
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

    file.close();

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

    std::cout << "After filtering contigs of " << threshold << "bp or less (" << filtered_out << " filtered out): \n";
    std::cout << "Total assembly length : " << total_length << "\n";
    std::cout << "Number of contigs : " << contig_lengths.size() << "\n";
    std::cout << "N50 : " << N50 << "\n";
    std::cout << "L50 : " << L50 << "\n";


    ////////// Build a File to give a graph-based-report //////////
    unordered_map<string, string> stats_report; // <contig name, stats_report>;
    // Retrieve stats from the contigs_stats file

    file.open (argv[3]);
    while (getline(file, line)){
        string key = line.substr(0, line.find('\t'));
        stats_report[key] = line;
    }
    file.close();

    // Add the GC content of each contig
    stats_report["#rname"] += "\tgccontent";
    file.open (argv[1]);

    getline(file, line);
    string key = line.substr(1);
    int nGC = 0;
    int nACTG = 0;

    while (getline(file, line)){
        if (line[0] == '>'){ 
            stats_report[key] = stats_report[key] + '\t' + to_string((float) nGC / nACTG);
            
            key = line.substr(1);
            nGC = 0;
            nACTG = 0;
        } else {
            for(int i = 0; i < line.size(); i++){
                if(line[i]=='G' || line[i] == 'C'){
                    nGC += 1;
                }
                nACTG += 1;
            }
        }
    }
    file.close();
    stats_report[key] = stats_report[key] + '\t' + to_string((float) nGC / nACTG);
    
    // Save the stats
    ofstream out;
    out.open(argv[4]);
    out << stats_report["#rname"] << endl;
    for (auto value : stats_report){
        if(value.first != "#rname"){
            out << value.second << endl;
        }   
    }
    out.close();

    return 0;
}

