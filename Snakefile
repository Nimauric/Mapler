########## RULE ALL ##########
# Read runs
runs = config["long-reads-hi-fi"]

# Read runs-assemblers pair
hifi_assemblies = expand("{assembler}_{run}", 
    run = config["long-reads-hi-fi"], 
    assembler = config["long-reads-hi-fi-assemblers"])

assemblies = hifi_assemblies

rule all :
    input :
        # For each run

        # For each run-assembler pair
        expand("../data/assemblies/{assembly}/assembly.fasta", assembly = assemblies) 

        expand("../data/stats_reports/{assembly}/reference_based_report.txt", assembly = assemblies) 
            if("reference-based" in config["metrics"]) else None,


# Assembly

# Metaquast

# Abundance calculator

# Reference-based report writer

