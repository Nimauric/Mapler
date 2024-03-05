#include <iostream>
#include <fstream>
#include <unordered_map>
#include <map>
#include <unordered_set>
#include <vector> 
#include <algorithm>
#include <sstream> // Splits tsv
#include <string>
#include <filesystem> 
#include <set>

using namespace std;



unordered_map<string, tuple<int, set<string>>> import_reads_to_contigs (string &path_to_paf){
    fstream file; string line;
    file.open (path_to_paf, fstream::in);
    
    // "contig_name",  <"aligned_bases", "aligned_reads">
    unordered_map<string, tuple<int, set<string>>> reads_to_contigs;

    while (getline(file, line)){
        istringstream iss(line);
        string word;
        string read_name, contig_name;
        int aligned_bases;

        int i = 0;
        while(iss >> word){
            // The switch case correspond to interesting columns in the original tsv
            switch (i){
                case 0 : read_name = word; break;
                case 5 : contig_name = word; break;
                case 9 : aligned_bases = stoi(word); break;
                break;
            }
            i += 1;
            if(i > 9){break;}
        }
        if (reads_to_contigs.count(contig_name) == 0){
            reads_to_contigs[contig_name] = {0, {}};
        }
        get<0>(reads_to_contigs[contig_name]) += aligned_bases;
        get<1>(reads_to_contigs[contig_name]).insert(read_name);

    }
    file.close();
    return reads_to_contigs;
}

unordered_map<string, tuple<int, set<string>>> import_reads_to_bins (string &path_to_bin_directory, unordered_map<string, tuple<int, set<string>>> &reads_to_contigs){
    
    // "bin_name",  <"aligned_bases", "aligned_reads">
    unordered_map<string, tuple<int, set<string>>> reads_to_bins;
    // Loop over all .fa files in the folder :
    for (const auto& entry : filesystem::directory_iterator(path_to_bin_directory)) {
        
        if (entry.path().extension() == ".fa") {
            // Loop ove lines
            string bin_name = entry.path().stem();

            ifstream file(entry.path());
            string line;


            while (getline(file, line)) {
                if (!line.empty() && line[0] == '>') {
                    line = line.substr(1);
                    
                    if (reads_to_bins.count(bin_name) == 0){
                        reads_to_bins[bin_name] = {0,{}};
                    }
                    get<0>(reads_to_bins[bin_name]) += get<0>(reads_to_contigs[line]);
                    get<1>(reads_to_bins[bin_name]).insert(get<1>(reads_to_contigs[line]).begin(), get<1>(reads_to_contigs[line]).end());
                }
            }

        }
        
    }
    return reads_to_bins;
}

int main(int argc, char *argv[]) {
    //g++ binning_and_evaluation/bin_alignement_stats_writer.cpp -std=c++17 -o binning_and_evaluation/bin_alignement_stats_writer.out && binning_and_evaluation/bin_alignement_stats_writer.out
    
    string path_to_paf = "outputs/salad-irg-pacbio-hifi/metaflye/reference_free/reads_on_contigs_mapping.paf";
    string path_to_bins = "outputs/salad-irg-pacbio-hifi/metaflye/bins/";
    string path_to_output = "outputs/salad-irg-pacbio-hifi/metaflye/bins/per_bin_mapping.csv";
    /*
    string path_to_paf = argv[1];
    string path_to_bins = argv[2];
    string path_to_output = argv[3];
    */
    

    // Contig : [alignement_length, [reads]]
    cout << "reading alignements..." << endl;
    unordered_map<string, tuple<int, set<string>>> read_to_contigs = import_reads_to_contigs(path_to_paf);
    
    // Bin : [alignement_length, [reads]]
    cout << "reading bins..." << endl;
    unordered_map<string, tuple<int, set<string>>> read_to_bins = import_reads_to_bins(path_to_bins, read_to_contigs);

    
    ofstream out;
    out.open(path_to_output);
    out << "bin,aligned_read_number,aligned_read_bases" << endl;
    for (const auto& entry : read_to_contigs) {
        if(get<0>(entry.second) == 0){
            out << entry.first << "," << get<1>(entry.second).size() << "," << get<0>(entry.second) << endl;
        }
        
    }

    unsigned long int ab = 0;
    for (const auto& entry : read_to_contigs) {
        ab += get<0>(entry.second);
    }
    cout << "Aligned bases (from read_to_contigs) : " << ab << endl;
    
    ab = 0;
    for (const auto& entry : read_to_bins) {
        ab += get<0>(entry.second);
    }
    cout << "Aligned bases (from read_to_bins) : " << ab << endl;

    ab = 0;
    for (const auto& entry : read_to_contigs) {
        ab += get<1>(entry.second).size();
    }
    cout << "Aligned reads (from read_to_contigs) : " << ab << endl;
    
    ab = 0;
    for (const auto& entry : read_to_bins) {
        ab += get<1>(entry.second).size();
    }
    cout << "Aligned reads (from read_to_bins) : " << ab << endl;

    cout << "Done" << endl;

}



