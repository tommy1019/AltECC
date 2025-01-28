using MAT
using JLD
using Printf

include("ImprovedECC/include/CategoricalEdgeClustering-master/src/EdgeCatClusAlgs.jl")
include("ImprovedECC/include/CategoricalEdgeClustering-master/src/lp_isocut.jl")
include("ImprovedECC/src/helpers.jl")

include("color_fair_ecc.jl")
include("protected_color_ecc.jl")

include("utils.jl")
include("datasets.jl")
include("rounding_algorithms.jl")

prepare_datasets()

if !isdir("output_pc")
    mkdir("output_pc")
end

open("out_ecc.txt", "w") do file_ecc

    write(file_ecc, "Dataset, n, m, r, k, mistakes, lp_objective, lp_runtime, round_runtime\n")

    open("out_pc.txt", "w") do file_pc

        write(file_pc, "Dataset, n, m, r, k, protected_color_type, protected_color_limit_percent, protected_color, protected_color_count, protected_color_limit, total_mistakes, protected_color_mistakes, lp_objective, lp_runtime, round_runtime\n")

        for dataset in datasets

            n, EdgeColors, EdgeList = dataset.load()

            m = length(EdgeColors)
            r = MaxHyperedgeSize(EdgeList)
            k = maximum(EdgeColors)

            color_counts = zeros(k)
            foreach(e -> color_counts[e] += 1, EdgeColors)

            sorted_colors = sort!(collect(enumerate(color_counts)), by=c -> c[2])

            if !isfile("output_pc/" * dataset.name * "_ecc.jld")
                println("No ECC LP found, calculating...")
                lp_objective, x, runtime = EdgeCatClusGeneral(EdgeList, EdgeColors, n, false, 1)
                save("output_pc/" * dataset.name * "_ecc.jld", "lp_objective", lp_objective, "x", x, "runtime", runtime)
                println("    Done.")
            end

            ecc = load("output_pc/" * dataset.name * "_ecc.jld")

            start = time()
            ecc["node_color"] = rowmin(ecc["x"])[:, 2]
            ecc["mistakes"] = eval_ecc(EdgeList, EdgeColors, ecc["node_color"])
            ecc["round_runtime"] = time() - start

            write(file_ecc, "$(dataset.name), $n, $m, $r, $k, $(ecc["mistakes"]), $(ecc["lp_objective"]), $(ecc["runtime"]), $(ecc["round_runtime"])\n")

            for protected_color_type in ["smallest", "median", "largest"]

                protected_color = 0
                protected_color_count = 0

                if protected_color_type == "smallest"
                    protected_color, protected_color_count = first(filter(c -> c[2] != 1, sorted_colors))
                elseif protected_color_type == "median"
                    protected_color, protected_color_count = sorted_colors[floor(Int64, size(sorted_colors)[1] / 2)]
                elseif protected_color_type == "largest"
                    protected_color, protected_color_count = last(sorted_colors)
                else
                    println("Error: Unknown protected color type: $protected_color_type")
                    exit(1)
                end

                for limit_percent in 0:5:100

                    limit = floor(Int64, protected_color_count * (limit_percent / 100.0))

                    println("==================================================================================================")
                    println("==================================================================================================")
                    println("==================================================================================================")
                    println("Running tests on dataset: " * dataset.name)
                    println("    $n nodes")
                    println("    $m edges")
                    println("    $r maximum hyperedge size")
                    println("    $k colors")
                    println("    $protected_color protected color ($protected_color_type)")
                    println("        $protected_color_count count")
                    println("        $limit limit")
                    println("--------------------------------------------------------------------------------------------------")

                    jld_filename = "output_pc/$(dataset.name)_pcecc_$(protected_color_type)_$(limit_percent).jld"

                    if !isfile(jld_filename)
                        println("No PCECC LP found, calculating...")
                        lp_objective, x, runtime = protected_color_ecc(EdgeList, EdgeColors, n, protected_color, limit, false, 1)
                        save(
                            jld_filename,
                            "lp_objective", lp_objective,
                            "x", x,
                            "runtime", runtime,
                            "protected_color", protected_color,
                            "protected_color_count", protected_color_count,
                            "limit", limit,
                            "limit_percent", limit_percent
                        )
                        println("    Done.")
                    end

                    pcecc = load(jld_filename)

                    start = time()
                    pcecc["node_color"] = rowmin(pcecc["x"])[:, 2]
                    pcecc["total_mistakes"], pcecc["protected_color_mistakes"] = eval_pcecc(EdgeList, EdgeColors, pcecc["node_color"], pcecc["protected_color"], pcecc["limit"])
                    pcecc["round_runtime"] = time() - start

                    write(file_pc, "$(dataset.name), $n, $m, $r, $k, $protected_color_type, $limit_percent, $(pcecc["protected_color"]), $(pcecc["protected_color_count"]), $(pcecc["limit"]), $(pcecc["total_mistakes"]), $(pcecc["protected_color_mistakes"]), $(pcecc["lp_objective"]), $(pcecc["runtime"]), $(pcecc["round_runtime"])\n")

                end

            end
        end

    end
end