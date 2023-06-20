
# Read runs
hi-fi_runs = config["long-reads-hi-fi"]
hi-fi_runs_names = [r["name"] for r in hi-fi_runs]
hi-fi_runs_paths = [r["path"] for r in hi-fi_runs]


rule metaflye_assembly : 
    params : runs = config["long-reads-hi-fi"]
    input :
        script = "assemblers/metaflye_wraper.sh",
        run_path = expand("{run_path}", run_path = hi-fi_runs_paths)
    conda : "env/flye.yaml"
    threads : 48
    resources :
        cpus_per_task = 48,
        mem_mb=320*1000, # 1 giga = 1000 mega
        runtime=3*24*60,
    output :   
        directory = expand("outputs/{run_name}/metaflye/", run_name = hi-fi_runs_names),
        file = expand("outputs/{run_name}/metaflye/assembly.fasta", run_name = hi-fi_runs_names)
    shell :
        "./{input.script} PacBio-Hi-Fi {input.run_path} {output.directory}"