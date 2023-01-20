import sys
import pandas as pd

def message_generator(table,abundance) :
    mean_fraction = table[table["Abundance"] == abundance]["assembly"].mean()
    name_list = list(table[table["Abundance"] == abundance]["Filename"])
    
    print(abundance + " abundance species, " + str(name_list) + " have an average genome fraction of " + str(mean_fraction) + "%")





# Import data from csv
table = pd.read_csv("./data/reference_genomes/genomes_information.csv")
assembly = pd.read_csv(str(sys.argv[1]), sep = "\t")
assembly["Filename"] = assembly["Assemblies"] + ".fasta"
assembly = assembly.drop(columns="Assemblies")
table=pd.merge(table, assembly, on="Filename")


message_generator(table,"low")
message_generator(table,"mid")
message_generator(table,"high")

