### Imports ###
import pandas as pd
import matplotlib.pyplot as plt
import sys

### Arguments ###
checkm_report = sys.argv[1] #"../outputs/salad-irg/metaMDBG/metabat2_bins_additional_reads_cobinning_alignement/checkm_report.txt"
output_path = sys.argv[2]

### Data processing ###
def GSCS_quality(contamination, completeness, contigs) : 
    if ((contamination <=1) and (completeness >=99) and (contigs <=1)) : 
        return "near complete"   
    if ((contamination <=5) and (completeness >=90)) :
        return "high quality"     
    if ((contamination <=10) and (completeness >=50)) :
        return "medium quality"   
    return "low quality"


bins = pd.read_csv(checkm_report, sep='\t', skiprows=1,
    names=["Bin ID","Completeness","Contamination","Completeness_Model_Used","Translation_Table_Used","Coding_Density","Contig_N50",
    "Average_Gene_Length","Genome_Size","GC_Content","Total_Coding_Sequences","Contigs","Max_Contig_Length","Additional_Notes"],)
print(bins)
bins = bins[["Bin ID", "Completeness", "Contamination", "Contigs"]]
print(bins)
bins["Quality"] = bins.apply(lambda x: GSCS_quality(x['Contamination'], x['Completeness'], x['Contigs']), axis=1)
print(bins)

### Plotting ###
scatter_plot = bins[bins["Quality"] == "near complete"].plot(x='Completeness', y='Contamination', kind='scatter',color="blue")
scatter_plot = bins[bins["Quality"] == "high quality"].plot(x='Completeness', y='Contamination', kind='scatter',color="green", ax=scatter_plot)
scatter_plot = bins[bins["Quality"] == "medium quality"].plot(x='Completeness', y='Contamination', kind='scatter',color="orange", ax=scatter_plot)
scatter_plot = bins[bins["Quality"] == "low quality"].plot(x='Completeness', y='Contamination', kind='scatter',color="red", ax=scatter_plot)
scatter_plot.set_ylim(0, 100)
scatter_plot.set_xlim(0, 100)

plt.show()
plt.savefig(output_path,format="pdf")
