import sys
import seaborn as sb
import pandas as pd


path_to_tsv = str(sys.argv[1])
unmapped_reads = sys.argv[2]
############### FUNCTIONS ###############

############### MAIN ###############
# Import data
table = pd.read_csv(path_to_tsv), delim_whitespace=True)
print(table.columns)

# Build GC/abundance plot
print("Building the GC / abundance plot...")
scatterplot = sb.scatterplot(x=table["gccontent"],y=table["meandepth"],size=table["endpos"])
scatterplot.set_xlabel("GC content")
scatterplot.set_ylabel("Contig size")
scatterplot.legend(title="Contig size")
scatterplot.get_figure().savefig("scatterplot.png")
scatterplot.get_figure().clf()

# Build contigs size boxplot
print("Building the contigs size violinplot...")
violinplot = sb.violinplot(y=table["endpos"],inner="point",cut=0)
violinplot.set(yscale="log")
violinplot.set_ylabel("Contig size")
violinplot.get_figure().savefig("violinplot.png") 



table = table.sort_values("endpos")



print("Done")


