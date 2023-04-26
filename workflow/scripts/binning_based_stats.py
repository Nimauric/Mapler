import sys
import pandas as pd

path_to_checm_tsv = str(sys.argv[1])
path_to_bins = str(sys.argv[2])

#path_to_checm_tsv = "../data/stats_reports/metamdbg_SRR13128014/bins_report.tsv"
#path_to_bins = "../data/bins/metamdbg_SRR13128014/"

############### FUNCTIONS ###############
def contig_counter(path) :
    file = open(path, "r")
    text = file.read()
    return text.count (">")

def contig_stats(path) :
    file = open(path, "r")
    text = file.readlines()

    contigs_size=[]

    for line in text : 
        if(line[0] == ">") :
            contigs_size.append(0)
        else :
            contigs_size[-1] +=len(line)

    contigs_size.sort(reverse = True)

    total_length = sum (contigs_size)
    N50 = None
    
    sum_length = 0
    for l in contigs_size : 
        sum_length += l 
        if(sum_length >= 0.5*total_length) : 
            N50 = l
            break

    return pd.Series([total_length, N50, N50/total_length], index=["Size", "N50", "N50/Size"])



############### MAIN ###############
# Import data
table = pd.read_csv(path_to_checm_tsv,
    delim_whitespace=True,
    names=["Bin ID","Marker","lineage","genomes","markers","marker set","0","1","2","3","4","5+","Completeness","Contamination","Strain heterogeneity"],
    skiprows=1
    )

# Count contigs per bin
table["Contigs"] = table.apply(lambda row : contig_counter(path_to_bins+row["Bin ID"] + ".fa"), axis=1)
table[["Size", "N50", "N50/Size"]] = table.apply(lambda row : contig_stats(path_to_bins+row["Bin ID"] + ".fa"), axis=1)



# Asses quality of each bin
NC=0
HQ=0
MQ=0
LQ=0
for index, row in table.iterrows() : #Theorically slow, but small enough dataframes it doesn't really matter
    if(row["Completeness"] >=99 and row["Contamination"] <= 1 and row["N50/Size"] >= 0.9) :
        NC +=1
    elif(row["Completeness"] >=90 and row["Contamination"] <= 5 and row["N50/Size"] >= 0.2) :
        HQ +=1
    elif(row["Completeness"] >=50 and row["Contamination"] <= 10 and row["N50/Size"] >= 0.1) :
        MQ +=1
    else :
        LQ +=1


print(table)
print()
print("Near complete MAGs (>=99 Completness, <=1 Contamination, >= 0.9 N50/Size) : " + str(NC))
print("High quality MAGs (>=90 Completness, <=5 Contamination, >= 0.2 N50/Size) : " + str(HQ))
print("Medium quality MAGs (>=50 Completness, <=10 Contamination, >= 0.1 N50/Size) : " + str(MQ))
print("Low quality MAGs : " + str(LQ))
