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


##### Binning #####     
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
    output : directory("outputs/{run_name}/{assember_name}/bins"),
    shell : "{input.script} {params.run_type} {input.run} {input.assembly} {output}"

##### Quality-based #####
rule checkm : 
    params : 
        output_directory = "outputs/{run_name}/{assember_name}/checkm",
        bins_extension = "fa",
    input :
        script = "binning_and_evaluation/checkm_wraper.sh",
        bins = "outputs/{run_name}/{assember_name}/bins",
    conda : "../env/checkm.yaml",
    resources :
        mem_mb=100*1000, # 1 giga = 1000 mega
        runtime=24*60
    output : "outputs/{run_name}/{assember_name}/checkm/bins_quality_check.tsv"
    shell : "{input.script} {params.bins_extension} {input.bins} {params.output_directory} {output}"

rule bin_quality_based_stats : 
    input :
        script = "binning_and_evaluation/bin_quality_based_report_writer.py",
        bins = "outputs/{run_name}/{assember_name}/bins",
        checkm_results = "outputs/{run_name}/{assember_name}/checkm/bins_quality_check.tsv",
    conda : "../env/python.yaml",
    resources :
        mem_mb=100*1000, # 1 giga = 1000 mega
        runtime=1*60,
    output : "outputs/{run_name}/{assember_name}/bin_quality_based_report.txt"
    shell : 
        "python3 {input.script} {input.checkm_results} {input.bins} > {output}"
