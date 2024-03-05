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


pacbio_hifi_illumina_hybrid_assemblies = expand("{long}/hybrid_{illumina}/{assembler}",
    long = [r["name"] for r in config["pacbio-hifi"]],
    illumina =  [r["name"] for r in config["illumina"]],
    assembler = config["pacbio-hifi-illumina-hybrid-assemblers"])
if(config["pacbio-hifi-illumina-hybrid-assemblers"] == None) : pacbio_hifi_illumina_hybrid_assemblies = []

pacbio_clr_illumina_hybrid_assemblies = expand("{long}/hybrid_{illumina}/{assembler}",
    long = [r["name"] for r in config["pacbio-clr"]],
    illumina =  [r["name"] for r in config["illumina"]],
    assembler = config["pacbio-clr-illumina-hybrid-assemblers"])
if(config["pacbio-clr-illumina-hybrid-assemblers"] == None) : pacbio_clr_illumina_hybrid_assemblies = []

ont_illumina_hybrid_assemblies = expand("{long}/hybrid_{illumina}/{assembler}",
    long = [r["name"] for r in config["ont"]],
    illumina =  [r["name"] for r in config["illumina"]],
    assembler = config["ont-illumina-hybrid-assemblers"])
if(config["ont-illumina-hybrid-assemblers"] == None) : ont_illumina_hybrid_assemblies = []

assemblies = ( pacbio_hifi_assemblies 
             + pacbio_clr_assemblies
             + ont_assemblies
             + pacbio_hifi_illumina_hybrid_assemblies
             + pacbio_clr_illumina_hybrid_assemblies
             + ont_illumina_hybrid_assemblies )

########## RULE ALL ##########
rule all :
    input :
	# For each run-assembler pair
        expand("outputs/{assembly}/assembly.fasta", assembly = assemblies),

        expand("outputs/{assembly}/reference_based_report.txt", assembly = assemblies)
            if(config["metrics"] and ("reference-based" in config["metrics"])) else "Snakefile",

        expand("outputs/{assembly}/reference_free_sample_comparison_report.txt", assembly = assemblies)
            if(config["metrics"] and ("reference-free-sample-comparison" in config["metrics"])) else "Snakefile",
        
        expand("outputs/{assembly}/reference_free_report.txt", assembly = assemblies)
            if(config["metrics"] and ("reference-free" in config["metrics"])) else "Snakefile",

        expand("outputs/{assembly}/bin_quality_based_report.txt", assembly = assemblies)
            if(config["metrics"] and ("bin-quality-based" in config["metrics"])) else "Snakefile",
            
        expand("outputs/{assembly}/reference_free/per_bin_mapping.csv", assembly = assemblies)
            if(config["metrics"] and ("bin-quality-based" in config["metrics"])) else "Snakefile",
        
        expand("outputs/{assembly}/reference_free_sample_comparison/per_bin_mapping.csv", assembly = assemblies)
            if(config["metrics"] and ("bin-quality-based" in config["metrics"]) and ("reference-free-sample-comparison" in config["metrics"])) else "Snakefile",


        #"test.txt",


rule compile_cpp : 
    conda : "./env/c++.yaml",
    input : 
        "{file}.cpp"
    output : 
        "{file}.out"
    shell : 
        "g++ {input} -std=c++17 -o {output}"

