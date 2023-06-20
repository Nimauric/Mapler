########## INCLUSIONS ##########
include : "rules/assembly.smk"
include : "rules/reference_based_evaluation.smk"


# Read runs-assemblers pair
hifi_assemblies = expand("{run}/{assembler}", 
    run = [r["name"] for r in config["pacbio-hifi"]], 
    assembler = config["pacbio-hifi-assemblers"])

lofi_assemblies = expand("{run}/{assembler}", 
    run = [r["name"] for r in config["pacbio-clr"]], 
    assembler = config["pacbio-clr-assemblers"])

if(config["pacbio-hifi-assemblers"] == None) : hifi_assemblies = []
if(config["pacbio-clr-assemblers"] == None) : lofi_assemblies = []

assemblies = hifi_assemblies + lofi_assemblies

########## RULE ALL ##########
rule all :
    input :
        # For each run-assembler pair
        expand("outputs/{assembly}/assembly.fasta", assembly = assemblies),
        
        #expand("outputs/{assembly}/reference_based_report.txt", assembly = assemblies) 
        #    if("reference-based" in config["metrics"]) else None,


        "test.txt",
