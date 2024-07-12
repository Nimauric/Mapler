rule metabat2_binning : 
    input : 
        contigs =  "outputs/{sample}/{assembler}/assembly.fasta",
        alignement =  "outputs/{sample}/{assembler}/{reference_reads}_on_contigs.bam"
    conda : "../envs/metabat2.yaml",
    threads : 16
    resources :
        cpus_per_task = 16,  #on mmdbg irg salad, 91% efficiency : 8 => 16
        mem_mb=10*1000, # on mmdbg irg salad, 49% efficiency
        runtime=12*60, # on mmdbg irg salad, 4 hours
    output : 
        directory = directory("outputs/{sample}/{assembler}/metabat2_bins_{reference_reads}_alignement/bins"),
        at_least_one_bin = "outputs/{sample}/{assembler}/metabat2_bins_{reference_reads}_alignement/bins/bin.1.fa"
    shell : "./sources/binning/metabat2_wraper.sh  {input.contigs} {input.alignement} {output.directory}"

rule metabat2_cobinning_short_reads : 
    input : 
        contigs =  "outputs/{sample}/{assembler}/assembly.fasta",
        alignement1 =  "outputs/{sample}/{assembler}/reads_on_contigs.bam",
        alignement2 =  "outputs/{sample}/{assembler}/short_reads_on_contigs.bam",
    conda : "../envs/metabat2.yaml",
    threads : 16
    resources :
        cpus_per_task = 16, 
        mem_mb=10*1000,
        runtime=12*60, 
    output : 
        directory = directory("outputs/{sample}/{assembler}/metabat2_bins_cobinning_alignement/bins"),
        at_least_one_bin = "outputs/{sample}/{assembler}/metabat2_bins_cobinning_alignement/bins/bin.1.fa"
    shell : "./sources/binning/metabat2_wraper.sh  {input.contigs} {input.alignement1} {output.directory} {input.alignement2}"

rule metabat2_cobinning_additional_reads : 
    input : 
        contigs =  "outputs/{sample}/{assembler}/assembly.fasta",
        alignement =  "outputs/{sample}/{assembler}/reads_on_contigs.bam",
        additional_alignements =  expand("outputs/{{sample}}/{{assembler}}/{additional_reads_name}_reads_on_contigs.bam", additional_reads_name = [ar["name"] for ar in config["additional_reads"]]),
    conda : "../envs/metabat2.yaml",
    threads : 16
    resources :
        cpus_per_task = 16, 
        mem_mb=10*1000,
        runtime=12*60, 
    output : 
        directory = directory("outputs/{sample}/{assembler}/metabat2_bins_additional_reads_cobinning_alignement/bins"),
        at_least_one_bin = "outputs/{sample}/{assembler}/metabat2_bins_additional_reads_cobinning_alignement/bins/bin.1.fa"
    shell : "./sources/binning/metabat2_wraper.sh  {input.contigs} {input.alignement} {output.directory} {input.additional_alignements}"

