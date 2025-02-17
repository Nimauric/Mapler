bins_extension="$1"
input_directory="$2"
output_directory="$3"
output_file="$4"
database_dir="$5"

# build directorys
mkdir "$output_directory" 

# download database
echo ""
if [ ! -d "$database_dir" ] || [ -z "$(ls -A "$database_dir")" ]; then
    checkm2 database --download --path "$database_dir"
fi

# run checkm2
echo""
checkm2 predict --input "$input_directory" --extension "$bins_extension" --output-directory "$output_directory" --threads $(nproc) --force

echo "Done !"
