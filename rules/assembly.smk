rule metaflye_assembly : 
    params : runs = config["long-reads-hi-fi"]
    input :
        script = "assemblers/metaflye_wraper.sh",
        run_path = expand("{run_path}", run_path = [r["path"] for r in runs])
    conda : "env/flye.yaml"
    threads : 48
    resources :
        cpus_per_task = 48,
        mem_mb=320*1000, # 1 giga = 1000 mega
        runtime=3*24*60,
    output :   
        directory = expand("outputs/{run_name}/metaflye/", run_name = [r["name"] for r in runs]),
        file = expand("outputs/{run_name}/metaflye/assembly.fasta", run_name = [r["name"] for r in runs])
    shell :
        "echo test"
#./{input.script} PacBio-Hi-Fi {input.run_path} {output.directory}