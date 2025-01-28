
function prepare_datasets()
    run(`
    bash -c 'if [ ! -d "ImprovedECC/include/CategoricalEdgeClustering-master/data/JLD_Files" ]; then
        (cd ImprovedECC/include/CategoricalEdgeClustering-master/data/ && unzip JLD_Files.zip)
    fi'
    `)
end