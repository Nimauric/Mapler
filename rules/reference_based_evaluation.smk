def get_files_in_folder(path):
    files = os.listdir(path)
    for i in range(len(files)) :
        files[i] = path + files[i]
    arguments = " ".join(files)
    return arguments
    
    
rule metaquast :
    params : 
        reference_genomes = get_files_in_folder(config["reference-genomes"])
    input : 
        script = "reference_based_evaluation/metaquast_wraper.sh", 
        assembly = "outputs/{run_name}/{assember_name}/assembly.fasta",
    conda : "../env/quast.yaml"
    resources :
        mem_mb=10*1000, # 1 giga = 1000 mega
        runtime=24*60,
    output : directory("outputs/{run_name}/{assember_name}/metaquast_results/summary/TSV/"),
    shell : "{input.script} {input.assembly} outputs/{wildcards.run_name}/{wildcards.assember_name}/metaquast_results/ {params.reference_genomes}"


rule assembly_references_based_stats :
    input : 
        script = "reference_based_evaluation/report_writer.py"
        metaquast_output = "../data/assemblies_quality_check/{assembly}_{run}/summary/TSV", 
        coverage_information = config["abundance-information"]n
    conda : "../env/python.yaml"
    output : "outputs/{run_name}/{assember_name}/reference_based_report.txt"
    shell : "python3 {input.script} {input.metaquast_output} {input.coverage_information}" 
        #"python3 {input.script} {input.metaquast_output} {input.coverage_information}  > {output}" 