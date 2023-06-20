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
        script = "scripts/assembly_quality_checker.sh", 
        assembly = "outputs/{run_name}/{assember_name}/assembly.fasta",
    conda : 
       	"../env/quast.yaml"
    resources :
        mem_mb=10*1000, # 10 giga = 10*100 mega
        runtime=24*60,
    output :
        directory("outputs/{run_name}/{assember_name}/metaquast_results/summary/TSV/"),
    shell : 
        "{input.script} {input.assembly} ../data/assemblies_quality_check/{wildcards.assembly} {params.reference_genomes}"



