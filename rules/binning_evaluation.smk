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
    
    
    ########## RULE METABAT2 ##########
"""
This rule uses metabat to group contigs into bins
"""
rule metabat2 : 
    params : 
        run_type = get_run_type,
    input : 
        assembly = "outputs/{run_name}/{assember_name}/assembly.fasta",
        run = get_run_path,
        script = "binning_and_evaluation/metabat2_wraper.sh",
    conda : "../env/metabat2.yaml",
    threads : 8
    resources :
        cpus_per_task = 8,
        mem_mb=10*1000, # 1 giga = 1000 mega
        runtime=12*60,
    output : 
        directory("outputs/{run_name}/{assember_name}/bins"),
    shell : 
        "{input.script} {params.run_type} {input.run} {input.assembly} {output}"
