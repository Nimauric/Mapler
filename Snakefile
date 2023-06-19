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
        # For each run-assembler pair
        expand("outputs/{assembly}/assembly.fasta", assembly = assemblies),
        
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
rule metaflye_assembly :
    input :
        script = "assemblers/metaflye_wraper.sh", # script
        run = config["long-reads-hi-fi"]["{run}"], # data
    output :
        "outputs/{run}/metaflye/assembly.fasta"
    conda : 
       	"env/metaflye.yaml"
    threads : 8
    resources :
        cpus_per_task = 8,
        mem_mb=32*1000, # 1 giga = 1000 mega
        runtime=3*24*6,
    shell :
        "./{input.script} {wildcards.run} {input.run} ../data/assemblies/metaflye_{wildcards.run}/" 




# Metaquast

# Abundance calculator

# Reference-based report writer

