########## RULE ALL ##########
# Read runs
runs = config["long-reads-hi-fi"]
runs_names = [r["name"] for r in runs]

# Read runs-assemblers pair
hifi_assemblies = expand("{run}/{assembler}", 
    run = [r["name"] for r in config["long-reads-hi-fi"]], 
    assembler = config["long-reads-hi-fi-assemblers"])

assemblies = hifi_assemblies

rule all :
    input :
        # For each run-assembler pair
        expand("outputs/{assembly}/assembly.fasta", assembly = assemblies),
        
        #expand("outputs/{assembly}/reference_based_report.txt", assembly = assemblies) 
        #    if("reference-based" in config["metrics"]) else None,


        #"test.txt",


# Assembly
import rules/assembly.smk

# Metaquast

# Abundance calculator

# Reference-based report writer


