#!/bin/sh


#SBATCH --mail-user=$nicolas.maurice@inria.fr
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

files=(./fastq/*.fastq)
for f in "${files[@]}"
do
    filename=`basename $f .fastq`
    if ! [ -f ./fastQC/${filename}_fastqc.html ]
        then
	    fastqc $f -o ./fastQC
        else
            echo "$filename already analysed"
    fi
    
done
