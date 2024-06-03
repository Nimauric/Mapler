# mapping contigs on reference with metaquast
rule metaquast :
    params : 
        reference_genomes = config["reference_genomes"],
        output_directory="outputs/{sample}/{assembler}/metaquast/results/"
    conda : "../envs/quast.yaml"
    resources :
        mem_mb=20*1000,
        runtime=24*60,
    input : "outputs/{sample}/{assembler}/assembly.fasta",
    output : directory("outputs/{sample}/{assembler}/metaquast/results/summary/TSV/"),
    shell : "sources/contig_quality_analysis/metaquast_wraper.sh {input} {params.output_directory} {params.reference_genomes}"

rule metaquast_report_writer :
    input : 
        metaquast_output = "outputs/{sample}/{assembler}/metaquast/results/summary/TSV/", 
        coverage_information = config["abundance_information"]
    conda : "../envs/python.yaml"
    output : "outputs/{sample}/{assembler}/metaquast/report.txt",
    shell : "python3 sources/contig_quality_analysis/metaquast_report_writer.py {input.metaquast_output} {input.coverage_information}  > {output}" 



# mapping reads on contigs should be flexible to either use long or short reads
rule read_contig_mapping_evaluation : 
    params : 
        expand("{sample}", sample=get_samples("name")),
        output_directory="outputs/{sample}/{assembler}/",
        threshold = config["read_mapping_threshold"]
    input :
        reads = lambda wildcards: get_sample("read_path", wildcards),
        mapping = "outputs/{sample}/{assembler}/{reference_reads}_on_contigs.bam",    
    output : "outputs/{sample}/{assembler}/{reference_reads}_on_contigs_mapping_evaluation/report.txt"
    conda : "../envs/python.yaml"
    shell : "python3 ./sources/contig_quality_analysis/read_mapping_evaluation.py {input.reads} {input.mapping} {params.threshold} > {output}"

# mapping contigs on themselves ?

# contig statistics ? N50...

# compare mapping contigs on reference with mapping reads on reference  ?