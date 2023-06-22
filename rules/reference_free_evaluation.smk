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


rule reads_on_contigs_mapping : 
    params : 
        run_type = get_run_type,
        output_directory =  "outputs/{run_name}/{assember_name}/reference_free",
    conda :	"../env/minimap2.yaml"
    threads : 8
    resources :
        cpus_per_task = 8,
        mem_mb=10*1000, # 1 giga = 1000 mega
        runtime=2*24*60,
    input : 
        script = "reference_free_evaluation/minimap2_wraper.sh",
        assembly = "outputs/{run_name}/{assember_name}/assembly.fasta",
        run = get_run_path,
    output : "outputs/{run_name}/{assember_name}/reference_free/reads_on_contigs_mapping.paf"
    shell : "{input.script} {input.assembly} {params.run_type} {input.run} {params.output_directory} {output} " 


rule assembly_references_free_stats :
    params : 
        threshold = "5000"
    input : 
        script = "reference_free_evaluation/report_writer.out",
        assembly = "outputs/{run_name}/{assember_name}/assembly.fasta",
        run = get_run_path,
        reads_on_contigs_mapping = "outputs/{run_name}/{assember_name}/reference_free/reads_on_contigs_mapping.paf",
    output : 
        contigs_sequence_based_stats = "outputs/{run_name}/{assember_name}/reference_free/contigs_sequence_based_stats.csv",
        contigs_alignement_based_stats = "outputs/{run_name}/{assember_name}/reference_free/contigs_alignement_based_stats.csv",
        txt_report = "outputs/{run_name}/{assember_name}/reference_free_report.txt"

    shell : 
        "./{input.script} {input.reads_on_contigs_mapping} {input.run} {input.assembly} {output.contigs_sequence_based_stats} {output.contigs_alignement_based_stats} {output.txt_report} {params.threshold}"
    
