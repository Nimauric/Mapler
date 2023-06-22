########## INCLUSIONS ##########
include : "rules/assembly.smk"
include : "rules/assembly_evaluation.smk"

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

assemblies = pacbio_hifi_assemblies + pacbio_clr_assemblies + ont_assemblies

########## RULE ALL ##########
rule all :
    input :
	# For each run-assembler pair
        expand("outputs/{assembly}/assembly.fasta", assembly = assemblies),

        expand("outputs/{assembly}/reference_based_report.txt", assembly = assemblies)
            if(config["metrics"] and ("reference-based" in config["metrics"])) else "Snakefile",

        expand("outputs/{assembly}/reference_free_report.txt", assembly = assemblies)
            if(config["metrics"] and ("reference-free" in config["metrics"])) else "Snakefile",

        #"test.txt",


rule compile_cpp : 
    input : 
        "{file}.cpp"
    output : 
        "{file}.out"
    shell : 
        "g++ {input} -std=c++11 -o {output}"
