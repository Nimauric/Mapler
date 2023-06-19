########## RULE ALL ##########
# Read runs
runs = config["long-reads-hi-fi"]

# Read runs-assemblers pair
hifi_assemblies = expand("{run}/{assembler}", 
    run = config["long-reads-hi-fi"], 
    assembler = config["long-reads-hi-fi-assemblers"])

assemblies = hifi_assemblies

rule all :
    input :
        # For each run

        # For each run-assembler pair
        expand("outputs/{assembly}/assembly.fasta", assembly = assemblies) 

        expand("outputs/{assembly}/reference_based_report.txt", assembly = assemblies) 
            if("reference-based" in config["metrics"]) else None,

# Initialise folder
rule directory_creation : 
    output : 
        "outputs/{run}/",
        "outputs/{run}/{assembler}/",
    shell :
        """
        mkdir outputs/{run}/
        mkdir outputs/{run}/{assembler}/
        """

# Assembly

# Metaquast

# Abundance calculator

# Reference-based report writer

