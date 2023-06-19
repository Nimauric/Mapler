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
rule metaflye_assembly : 
    params : runs = config["long-reads-hi-fi"]
    input :
        script = "assemblers/metaflye_wraper.sh",
        run_path = expand("{run_path}", run_path = [r["path"] for r in runs])
    conda : "env/flye.yaml"

    threads : 48
    resources :
        cpus_per_task = 48,
        mem_mb=32*1000, # 1 giga = 1000 mega
        runtime=3*24*60,


    output :   
        directory = expand("outputs/{run_name}/metaflye/", run_name = [r["name"] for r in runs]),
        file = expand("outputs/{run_name}/metaflye/assembly.fasta", run_name = [r["name"] for r in runs])
    shell :
        "./{input.script} PacBio-Hi-Fi run_path {output.directory}"


#outputs/{run_name}/metaflye/
# Metaquast

# Abundance calculator

# Reference-based report writer


