bins_extension="$1"
input_directory="$2"
output_directory="$3"
output_file="$4"

# build directorys
mkdir "$output_directory"

# call checkm tree, lineage_set, analyze and qa
echo""
checkm tree "$input_directory" "$output_directory" -x "$bins_extension"

echo ""
checkm lineage_set "$output_directory" "$output_directory"/markers.txt

echo ""
checkm analyze "$output_directory"/markers.txt "$input_directory" "$output_directory" -x "$bins_extension"

echo ""
checkm qa "$output_directory"/markers.txt "$output_directory" --tab_table -f "$output_file"


echo "Done !"
