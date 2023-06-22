#include <iostream>
#include <fstream>
#include <unordered_map>
#include <map>
#include <unordered_set>
#include <vector> 
#include <algorithm>
#include <sstream> // Splits tsv
#include <string>

using namespace std;



vector<tuple<string, int, string, int, int>> import_alignements (string &path_to_paf){
    fstream file;
    string line;
    file.open (path_to_paf, fstream::in);
    
    // "read_name", "read_length", "contig_name", "contig_length", "aligned_bases"
    vector<tuple<string, int, string, int, int>> alignements;
    
    string read_name = "";
    int read_length = 0;
    string contig_name = "";
    int contig_length = 0;
    int aligned_bases = 0;

    while (getline(file, line)){
        istringstream iss(line);
        string word;
        int i = 0;
        while(iss >> word){
            // The switch case correspond to interesting columns in the original tsv
            switch (i){
                case 0 : read_name = word; break;
                case 1 : read_length = stoi(word); break;
                case 5 : contig_name = word; break;
                case 6 : contig_length = stoi(word); break;
                case 9 : aligned_bases= stoi(word); break;
                break;
            }

            i += 1;
            if(i > 9){break;}
        }
        alignements.emplace_back(read_name, read_length, contig_name, contig_length, aligned_bases);
    }
    file.close();
    return alignements;
}

unordered_map<string, int> import_reads(string &path_to_reads){
    fstream file;
    string line;
    file.open (path_to_reads, fstream::in);
    
    // "read_name", "read_length"
    unordered_map<string, int> reads;
    string read_name;
    int read_size;
    while (getline(file, line)){
        if(line[0] == '+' && (line.substr(1) == read_name) || line == "+"){ // '+' and '@' can be found in the quality score, I use both the @read_name and +read_name to ensure I don't pick out false positives
            reads[read_name] = read_size;
        } else if (line[0] == '@'){
            read_name = line.substr(1);
            read_size = 0;
        } else {
            read_size += line.size();
        }
    }
    file.close();

    return reads;
}

bool isGC(char c) { return (c=='G' || c == 'C'); }
bool contig_sorter (tuple<string, int, float, float> i,tuple<string, int, float, float> j) {return get<1>(i) > get<1>(j);}
vector<tuple<string, int, float, float>> import_contigs_data(string &path_to_contigs, vector<tuple<string, int, string, int, int>> &alignements){
    fstream file;
    string line;
    file.open (path_to_contigs, fstream::in);
    
    // "contig_name", "contig_length", "GC_content"
    vector<tuple<string, int, float, float>> contigs;
    string contig_name = "";
    int size;
    int GC;
    float depth;
    while (getline(file, line)){
        if(line[0] == '>'){
            if(contig_name != ""){
                contigs.emplace_back(contig_name, size,(float) GC/size, (float) depth/size);
            }
            contig_name = line.substr(1);
            size = 0;
            GC = 0;
            depth = 0.f;
            
            for (auto row : alignements){
                if(get<2>(row) == contig_name){
                    depth += get<4>(row);
                }
            }
            

        } else {
            size +=line.size();
            GC += count_if(line.begin(), line.end(), isGC);
        }
        
    }
    contigs.emplace_back(contig_name, size,(float) GC/size, (float) depth/size);

    sort(contigs.begin(), contigs.end(), contig_sorter);

    return contigs;
}

void produce_filtered_stats_csv(string path_to_filtered_stats_csv_output, vector<tuple<string, int, float, float>> contigs){
    int shortest_contig;
    int number_of_contigs = 0;
    long int assembly_length = 0;
    float GC_content = 0.0;
    float mean_depth = 0.0;
    int N50;
    int L50 = 0;
    int assembly_length_50 = 0;

    ofstream out;
    out.open(path_to_filtered_stats_csv_output);

    out << "shortest contig,assembly length,number of contigs,gc content,mean depth,N50,L50" << endl;
    while(number_of_contigs  < contigs.size()){
        shortest_contig = get<1>(contigs[number_of_contigs]);
        GC_content = (GC_content*number_of_contigs + get<2>(contigs[number_of_contigs]))/(number_of_contigs+1);
        mean_depth = (mean_depth*number_of_contigs + get<3>(contigs[number_of_contigs]))/(number_of_contigs+1);
        assembly_length += shortest_contig;
        number_of_contigs +=1;

        if(shortest_contig == get<1>(contigs[number_of_contigs])){
            continue; // Skip over if the next contig has the same length
        }

        while(assembly_length_50 < 0.5*assembly_length){
            N50 = get<1>(contigs[L50]);
            assembly_length_50 += N50;
            L50 +=1;
        }

        out << shortest_contig << ',' << assembly_length << ',' << number_of_contigs << ',' << GC_content << ',' << mean_depth << ',' << N50 << ',' << L50 << endl;
    }
    out.close();
}
int main(int argc, char *argv[]) {
    /*
    string path_to_paf = "../data/alignements/metaflye_SRR8073714/reads_on_contigs.paf";
    string path_to_reads = "../data/input_reads/SRR8073714.fastq";
    string path_to_contigs = "../data/assemblies/metaflye_SRR8073714/assembly.fasta";
    string path_to_contigs_info_csv_output = "contigs_info.csv";
    string path_to_filtered_stats_csv_output = "filtered_stats.csv";
    string path_to_txt_output = "output.txt";
    int threshold = 1000;
    */


    string path_to_paf = argv[1];
    string path_to_reads = argv[2];
    string path_to_contigs = argv[3];
    string path_to_contigs_info_csv_output = argv[4];
    string path_to_filtered_stats_csv_output = argv[5];
    string path_to_txt_output = argv[6];
    int threshold = stoi(argv[7]);

    
    // Alignements
    cout << "reading alignements..." << endl;
    // "read_name", "read_length", "contig_name", "contig_length", "aligned_bases"
    vector<tuple<string, int, string, int, int>> alignements = import_alignements (path_to_paf);
    
    
    // Reads
    cout << "reading reads..." << endl;
    // "read_name", "read_length"
    unordered_map<string, int> reads = import_reads(path_to_reads);

    // Contigs
    cout << "reading contigs..." << endl;
    // "contig_name", "contig_length", "GC_content", " mean_depth"
    vector<tuple<string, int, float, float>> contigs = import_contigs_data(path_to_contigs, alignements);
    
    

    // Loop over alignements;
    cout << "analizing alignements..." << endl;
    produce_filtered_stats_csv(path_to_filtered_stats_csv_output, contigs);

     unordered_set<string> unique_aligned_reads;
    long int total_alignement_length = 0;
    for (auto row : alignements){
        total_alignement_length += get<4>(row);
        unique_aligned_reads.insert(get<0>(row));
    }
    int number_of_aligned_reads = unique_aligned_reads.size();

    // Loop over reads
    cout << "analizing reads..." << endl;
    long int total_reads_length = 0;
    for (auto row : reads){
        total_reads_length += row.second;
    }
    int number_of_reads = reads.size();

    // First loop over contigs to get total length and number, as well as to write a file
    cout << "analizing contigs..." << endl;
    long int kept_contigs_length = 0;
    long int discarded_contigs_length = 0;
    int kept_contigs_number = 0;
    int discarded_contigs_number = 0;

    ofstream out;
    out.open(path_to_contigs_info_csv_output);
    out << "contig_name,contig_length,GC_content,mean_depth" << endl;
    for (auto row : contigs){
        int length = get<1>(row);
        out << get<0>(row) << "," << get<1>(row) << "," << get<2>(row) << "," << get<3>(row) << endl;
        if(length > threshold){
            kept_contigs_length += length;
            kept_contigs_number +=1;
        } else {
            discarded_contigs_length += length;
            discarded_contigs_number +=1;
        }  
    }
    out.close();

    // Second loop over contigs to get L50 and N50
    int N50 = 0;
    int L50 = 0;
    int running_length = 0;

     for (auto row : contigs){
        running_length += get<1>(row);
        L50 += 1;
        if (running_length > 0.5 * kept_contigs_length){
            N50 = get<1>(row);
            break;
        }
    }

    
    out.open(path_to_txt_output);
    out << "Number of mapped reads : " << number_of_aligned_reads << endl;
    out << "Total number of reads : " << number_of_reads << endl;
    out << "Ratio : " << (float) 100*number_of_aligned_reads / number_of_reads << " %" << endl;

    out << endl;
    out << "Total alignement length : " << total_alignement_length << endl;
    out << "Total reads length : " << total_reads_length << endl;
    out << "Ratio : " << (float) 100*total_alignement_length / total_reads_length << " %" << endl;

    out << endl;
    out << "After filtering out contigs of " << threshold << "bp or less : " << endl;
    out << discarded_contigs_number << " contigs were discarded (" << (float) 100*discarded_contigs_number / (kept_contigs_number + discarded_contigs_number)<< "%)" << endl;
    out << discarded_contigs_length<< " bases were discarded (" << (float) 100*discarded_contigs_length / (kept_contigs_length + discarded_contigs_length)<< "%)" << endl;
    out << "Assembly length : " << kept_contigs_length << endl;
    out << "Contigs : " << kept_contigs_number << endl;
    out << "N50 : " << N50 << endl;
    out << "L50 : " << L50 << endl;
    out.close();
    


    
}


