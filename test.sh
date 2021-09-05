for D in $(find ./cloudrun -mindepth 1 -maxdepth 1 -type d) ; do
    echo "${D##*/}";
done
