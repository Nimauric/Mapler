########## INCLUSIONS ##########
include : "rules/assembly.smk"
include : "rules/assembly_evaluation.smk"
include : "rules/binning_evaluation.smk"

# Read runs-assemblers pair
pacbio_hifi_assemblies = expand("{run}/{assembler}",
    run = [r["name"] for r in config["pacbio-hifi"]],
    assembler = config["pacbio-hifi-assemblers"])
if(config["pacbio-hifi-assemblers"] == None) : pacbio_hifi_assemblies = []


pacbio_clr_assemblies = expand("{run}/{assembler}",
    run = [r["name"] for r in config["pacbio-clr"]],
    assembler = config["pacbio-clr-assemblers"])
if(config["pacbio-clr-assemblers"] == None) : pacbio_clr_assemblies = []

ont_assemblies = expand("{run}/{assembler}",
    run = [r["name"] for r in config["ont"]],
    assembler = config["ont-assemblers"])
if(config["ont-assemblers"] == None) : ont_assemblies = []


pacbio_clr_illumina_hybrid_assemblies = expand("{pacbio}/hybrid_{illumina}/{assembler}",
    pacbio = [r["name"] for r in config["pacbio-clr"]],
    illumina =  [r["name"] for r in config["illumina"]],
    assembler = config["pacbio-clr-illumina-hybrid-assemblers"])
if(config["pacbio-clr-illumina-hybrid-assemblers"] == None) : pacbio_clr_illumina_hybrid_assemblies = []

assemblies = ( pacbio_hifi_assemblies 
             + pacbio_clr_assemblies
             + ont_assemblies
             + pacbio_clr_illumina_hybrid_assemblies )

########## RULE ALL ##########
rule all :
    input :
	# For each run-assembler pair
        expand("outputs/{assembly}/assembly.fasta", assembly = assemblies),

        expand("outputs/{assembly}/reference_based_report.txt", assembly = assemblies)
            if(config["metrics"] and ("reference-based" in config["metrics"])) else "Snakefile",

        expand("outputs/{assembly}/reference_free_report.txt", assembly = assemblies)
            if(config["metrics"] and ("reference-free" in config["metrics"])) else "Snakefile",

        expand("outputs/{assembly}/bin_quality_based_report.txt", assembly = assemblies)
            if(config["metrics"] and ("bin-quality-based" in config["metrics"])) else "Snakefile",
            


        #"test.txt",


rule compile_cpp : 
    input : 
        "{file}.cpp"
    output : 
        "{file}.out"
    shell : 
        "g++ {input} -std=c++11 -o {output}"

