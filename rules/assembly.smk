
########## HELPERS ##########
def get_run_info(wildcards) :
    for run_type in ["pacbio-hifi", "pacbio-clr"] :
        for a in config[run_type] :
            if a["name"] == wildcards.run_name :
                return a["path"], run_type
    return None, None

def get_run_path(wildcards) : 
    run_path, _ = get_run_info(wildcards)
    return run_path

def get_run_type(wildcards) :
    _ , run_type = get_run_info(wildcards)
    return run_type


########## HI-FI ASSEMBLERS ##########
rule metaflye_assembly :
    params : 
        run_type = get_run_type
    conda : "env/flye.yaml"
    threads : 48
    resources :
        cpus_per_task = 48,
        mem_mb=320*1000, # 1 giga = 1000 mega
        runtime=3*24*60,
    input : 
        script = "assemblers/metaflye_wraper.sh",
        run_path = get_run_path,
    output : "outputs/{run_name}/metaflye/assembly.fasta",
    shell : "./{input.script} {params.run_type} {input.run_path} outputs/{wildcards.run_name}/metaflye"

