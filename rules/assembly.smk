
########## HELPERS ##########
def get_run_info(wildcards) :
    for run_type in config :
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


def get_short_run_path(wildcards) :
    for run_type in config :
        for a in config[run_type] :
            if a["name"] == wildcards.second_run_name :
                return a["forward"], a["reverse"]
    return None, None

def get_forward(wildcards) :
    forward , _ = get_short_run_path(wildcards)
    return forward

def get_reverse(wildcards) :
    _ , reverse = get_short_run_path(wildcards)
    return reverse

########## HI-FI ASSEMBLERS ##########

rule metaMDBG_assembly :
    conda : "../env/metaMDBG.yaml" 
    threads : 16
    resources :
        cpus_per_task = 16,
        mem_mb=50*1000, # 1 giga = 1000 mega
        runtime=3*24*60,
    input : 
        script = "assemblers/metaMDBG_wraper.sh",
        dependencies = "dependencies/metaMDBG/",
        run_path = get_run_path,
    output : "outputs/{run_name}/metaMDBG/assembly.fasta",
    shell : "./{input.script} {input.run_path} outputs/{wildcards.run_name}/metaMDBG"

rule metaflye_assembly :
    params : 
        run_type = get_run_type
    conda : "../env/flye.yaml"
    threads : 48
    resources :
        cpus_per_task = 48,
        mem_mb=160*1000, # 1 giga = 1000 mega
        runtime=3*24*60,
    input : 
        script = "assemblers/metaflye_wraper.sh",
        run_path = get_run_path,
    output : "outputs/{run_name}/metaflye/assembly.fasta",
    shell : "./{input.script} {params.run_type} {input.run_path} outputs/{wildcards.run_name}/metaflye"

rule hifiasm_meta_assembly :
    conda : "../env/hifiasm_meta.yaml"
    threads : 48
    resources :
        cpus_per_task = 48,
        mem_mb=80*1000, # 1 giga = 1000 mega
        runtime=3*24*60,
    input : 
        script = "assemblers/hifiasm_meta_wraper.sh",
        run_path = get_run_path,
    output : "outputs/{run_name}/hifiasm-meta/assembly.fasta",
    shell : "./{input.script} {input.run_path} outputs/{wildcards.run_name}/hifiasm-meta"

########## HYBRID ASSEMBLERS ##########

rule operams_assembly :
    params : 
        output_folder = "outputs/{run_name}/hybrid_{run_name}/opera-ms/assembly.fasta"
    input : 
        script = "assemblers/opera_ms_wraper.sh",
        r1 =  get_forward,
        r2 = get_reverse,
        long = get_run_path
    output : "outputs/{run_name}/hybrid_{second_run_name}/operaMS/assembly.fasta",
    conda : "../env/operams.yaml"
    threads : 48
    resources :
        cpus_per_task=48,
        mem_mb=160*1000, # 1 giga = 1000 mega
        runtime=3*24*60,
    shell : 
        "./{input.script} {input.r1} {input.r2} {input.long} {params.output_folder}"






