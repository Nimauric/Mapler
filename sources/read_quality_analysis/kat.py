### Imports ###
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import sys

### Arguments ###
mapped_reads_stats = sys.argv[1] #"../outputs/salad-irg/test-cluster/kat/mapped-stats.tsv"
unmapped_reads_stats = sys.argv[2] #"../outputs/salad-irg/test-cluster/kat/unmapped-stats.tsv"
output_path = sys.argv[3] # "../outputs/salad-irg/test-cluster/kat/kat_plot.png"

### Data processing ###
def count_occurences(stats_path, name) : 
    occurences = pd.read_csv(stats_path, sep="\t", usecols=[0,1])
    print(name+" reads stats : ")
    print(" - Median :", occurences['median'].median())
    print(" - Average :", occurences['median'].mean())

    return occurences
mapped_occurences = count_occurences(mapped_reads_stats, "Mapped")
unmapped_occurences = count_occurences(unmapped_reads_stats, "Unapped")


### Plotting ###
xlim = max(np.percentile(mapped_occurences['median'], 95), np.percentile(unmapped_occurences['median'], 95))
plt.xlim(right=xlim, left=1)
bins=int(xlim)-1

plt.ticklabel_format(style='sci', axis='y')
plt.xlabel("Median 27-mer abundance")
plt.ylabel("Read count")

_, bins, _  = plt.hist(mapped_occurences['median'], bins=bins, alpha=0.5, range=(1, xlim), label='Mapped reads', density=False)
plt.hist(unmapped_occurences['median'], bins=bins, alpha=0.5, range=(1, xlim), label='Unmapped reads', density=False)

plt.legend()
plt.show()
plt.savefig(output_path,format="pdf")
