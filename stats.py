import sys
import pandas as pd

def import_and_merge_metric(table, metric_path, metric_name) :
    metric_table = pd.read_csv(metric_path, sep = "\t", na_values=['-'])
    metric_table["assembly"] = metric_table.iloc[:,1]
    metric_table = metric_table.rename(columns={"assembly" : metric_name})
    table = pd.merge(table, metric_table, on="Assemblies")
    return table

# Define the message to be returned
def message_generator(table,abundance) :
    genome_fraction = table[table["Abundance"] == abundance]["genome_fraction"].mean()
    mismatches = table[table["Abundance"] == abundance]["mismatches"].mean()
    misassemblies = table[table["Abundance"] == abundance]["misassemblies"].mean()
    duplication_ratio = table[table["Abundance"] == abundance]["duplication_ratio"].mean()
    NGA50 = table[table["Abundance"] == abundance]["NGA50"].mean()
    name_list = list(table[table["Abundance"] == abundance]["Assemblies"])
    
    print(abundance + " abundance : ")
    print("  - species : " + str(name_list))
    print("  - average genome fraction : " + str(genome_fraction) + "%")
    print("  - average number of mismatches per 100kb : " + str(mismatches))
    print("  - average number of misassemblies : " + str(misassemblies))
    print("  - average duplication ratio : " + str(duplication_ratio))
    print("  - average NGA50 : " + str(NGA50))


### Import data from csv
# Import metadata
table = pd.read_csv("./data/reference_genomes/genomes_information.csv")
table["Assemblies"] = table["Filename"].str.removesuffix(".fasta")

# Import and merge metrics
table = import_and_merge_metric(table, str(sys.argv[1]+"/Genome_fraction.tsv"), "genome_fraction")
table = import_and_merge_metric(table, str(sys.argv[1]+"/num_mismatches_per_100_kbp.tsv"), "mismatches")
table = import_and_merge_metric(table, str(sys.argv[1]+"/num_misassemblies.tsv"), "misassemblies")
table = import_and_merge_metric(table, str(sys.argv[1]+"/Duplication_ratio.tsv"), "duplication_ratio")
table = import_and_merge_metric(table, str(sys.argv[1]+"/NGA50.tsv"), "NGA50")


"""
# Import and merge genome fraction
genome_fraction = pd.read_csv(str(sys.argv[1]+"/Genome_fraction.tsv"), sep = "\t")
genome_fraction.rename(columns={"assembly" : "genome_fraction"})
table=pd.merge(table, genome_fraction, on="Assemblies")

# Import and merge mismatches per 100kb
mismatches = pd.read_csv(str(sys.argv[1]+"/num_mismatches_per_100_kbp.tsv"), sep = "\t")

"""


message_generator(table,"low")
message_generator(table,"mid")
message_generator(table,"high")


