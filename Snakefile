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
        test.txt

        # For each run-assembler pair
        expand("outputs/{assembly}/assembly.fasta", assembly = assemblies),
        
        expand("outputs/{assembly}/reference_based_report.txt", assembly = assemblies) 
            if("reference-based" in config["metrics"]) else None,

# Initialise folder
rule directory_creation :
    output : expand("outputs/{runs_names}", runs_names = runs_names)
    shell : "mkdir outputs/{output}"


# Assembly
rule metaflye_assembly :
    input :
        script = "assemblers/metaflye_wraper.sh",
        run = config["long-reads-hi-fi"], 
    output :
        "outputs/{input.run['name']}/metaflye/assembly.fasta"
        "test.txt"
    conda : 
       	"env/metaflye.yaml"
    shell :
        "./{input.script} PacBio-Hi-Fi input.run['path'] outputs/{input.run['name']}/metaflye/" 




# Metaquast

# Abundance calculator

# Reference-based report writer

