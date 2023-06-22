import sys
import pandas as pd

############### FUNCTIONS ###############
# Import a tsv and merge it with table
def import_and_merge_metric(table, metric_path, metric_name) :
    metric_table = pd.read_csv(metric_path, sep = "\t", na_values=['-'])
    metric_table = metric_table.rename(columns={"assembly" : metric_name, "Assemblies" : "genome"})
    table = pd.merge(table, metric_table, on = "genome")
    return table

# Define the message to be returned
def message_generator(table,category) :
    genome_fraction = table[table["category"] == category]["genome_fraction"].mean()
    mismatches = table[table["category"] == category]["mismatches"].mean()
    misassemblies = table[table["category"] == category]["misassemblies"].mean()
    duplication_ratio = table[table["category"] == category]["duplication_ratio"].mean()
    NGA50 = table[table["category"] == category]["NGA50"].mean()
    name_list = list(table[table["category"] == category]["genome"])
    
    print(category + " category : ")
    print("  - species : " + str(name_list))
    print("  - average genome fraction : " + str(genome_fraction) + "%")
    print("  - average number of mismatches per 100kb : " + str(mismatches))
    print("  - average number of misassemblies : " + str(misassemblies))
    print("  - average duplication ratio : " + str(duplication_ratio))
    print("  - average NGA50 : " + str(NGA50))
    print()

############### MAIN ###############

metaquast_output = str(sys.argv[1])
coverage_information = str(sys.argv[2])

# import coverage information
table = pd.read_csv(coverage_information, sep = ",", names=["genome", "category"])

# Import and merge metrics
table = import_and_merge_metric(table, metaquast_output + "/Genome_fraction.tsv", "genome_fraction")
table = import_and_merge_metric(table, metaquast_output + "/num_mismatches_per_100_kbp.tsv", "mismatches")
table = import_and_merge_metric(table, metaquast_output + "/num_misassemblies.tsv", "misassemblies")
table = import_and_merge_metric(table, metaquast_output + "/Duplication_ratio.tsv", "duplication_ratio")
table = import_and_merge_metric(table, metaquast_output + "/NGA50.tsv", "NGA50")

# Produce output
for category in table["category"].unique() : 
    message_generator(table,category)

print("Full table : ")
print(table)

