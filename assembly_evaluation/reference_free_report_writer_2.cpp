#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <map>
#include <algorithm> // for std::sort

using namespace std;

int main() {
    map<string, vector<int>> contigs;

    vector<string> assemblers = {"metaflye","metaMDBG", "hifiasm-meta"};
    string path_prefix = "outputs/salad-irg-pacbio-hifi/";
    string path_suffix = "/assembly.fasta";

    for (const auto& a : assemblers) {
        contigs[a] = {};
        ifstream assembly(path_prefix + a + path_suffix);

        if (assembly.is_open()) {
            string line;
            while (getline(assembly, line)) {
                if (line[0] == '>') {
                    contigs[a].push_back(0);
                } else {
                    contigs[a].back() += line.length();
                }
            }
            assembly.close();
        } else {
            cerr << "Unable to open file: " << path_prefix + a + path_suffix << endl;
        }

        // Sort the contigs vector in descending order
        sort(contigs[a].begin(), contigs[a].end(), greater<int>());
    }

    // Printing the results in parallel
    for (const auto& assembler : assemblers) {
        cout << assembler << " ";
    }
    cout << endl; 
    for (size_t i = 0; i < 1000; ++i) {
        for (const auto& assembler : assemblers) {
            cout << contigs[assembler][i] << " ";
        }
        cout << endl;
    }

    /*
    for (size_t i = 0; i < contigs[assemblers[0]].size(); ++i) {
        for (const auto& assembler : assemblers) {
            if (i < contigs[assembler].size()) {
                cout << "Assembler: " << assembler << ", Contig length: " << contigs[assembler][i] << endl;
            }
        }
    }
    */
    return 0;
}