  GNU nano 7.2                                                                kronatax.sh                                                                         
#!/bin/sh

conda_env=$(conda info --envs | awk '$1=="*"{print $2}')
if [ ! -f "$conda_env"/opt/krona/taxonomy/taxonomy.tab ]; then
    echo "Downloading Krona taxonomy"
    curl -s -R --retry 1 -o "${conda_env}"/opt/krona/taxonomy/taxdump.tar.gz https://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz
    ktUpdateTaxonomy.sh
fi


if [ ! -f "$conda_env"/opt/krona/taxonomy/taxonomy.tab ]; then
    exit 1
else 
    touch outputs/.kronatax
fi

