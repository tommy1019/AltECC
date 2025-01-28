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

open("table.tex", "w") do file

    foreach(function (dataset)
            n, EdgeColors, EdgeList = dataset.load()

            m = length(EdgeColors)
            r = MaxHyperedgeSize(EdgeList)
            k = maximum(EdgeColors)

            color_counts = zeros(k)
            foreach(e -> color_counts[e] += 1, EdgeColors)

            println("==================================================================================================")
            println("==================================================================================================")
            println("==================================================================================================")
            println("Running tests on dataset: " * dataset.name)
            println("    $n nodes")
            println("    $m edges")
            println("    $r maximum hyperedge size")
            println("    $k colors")
            println("--------------------------------------------------------------------------------------------------")

            if !isdir("output_cf")
                mkdir("output_cf")
            end

            if !isfile("output_cf/" * dataset.name * "_ecc.jld")
                println("No ECC LP found, calculating...")
                lp_objective, x, runtime = EdgeCatClusGeneral(EdgeList, EdgeColors, n, false, 1)
                save("output_cf/" * dataset.name * "_ecc.jld", "lp_objective", lp_objective, "x", x, "runtime", runtime)
                println("    Done.")
            end

            if !isfile("output_cf/" * dataset.name * "_cfecc.jld")
                println("No CFECC LP found, calculating...")
                lp_objective, x, runtime = color_fair_ecc(EdgeList, EdgeColors, n, false, 1)
                save("output_cf/" * dataset.name * "_cfecc.jld", "lp_objective", lp_objective, "x", x, "runtime", runtime)
                println("    Done.")
            end

            ecc = load("output_cf/" * dataset.name * "_ecc.jld")
            cfecc = load("output_cf/" * dataset.name * "_cfecc.jld")

            start = time()
            ecc["node_color"] = rowmin(ecc["x"])[:, 2]
            ecc_rowmin_time = time() - start

            start = time()
            cfecc["node_color"] = rowmin(cfecc["x"])[:, 2]
            cfecc_rowmin_time = time() - start

            println("ECC Objective")
            println("    LP Objective: $(ecc["lp_objective"])")
            println("    Runtime: $(ecc["runtime"])")

            start = time()
            oecc_aecc = eval_ecc(EdgeList, EdgeColors, ecc["node_color"])
            oecc_aecc_round_time = (time() - start) + ecc_rowmin_time

            start = time()
            oecc_acfecc = eval_ecc(EdgeList, EdgeColors, cfecc["node_color"])
            oecc_acfecc_round_time = (time() - start) + ecc_rowmin_time

            println("    A_ECC: $oecc_aecc ($(oecc_aecc_round_time)s)")
            println("    A_CFECC: $oecc_acfecc ($(oecc_acfecc_round_time)s)")

            println("CFECC Objective")
            println("    LP Objective: $(cfecc["lp_objective"])")
            println("    Runtime: $(cfecc["runtime"])")

            start = time()
            ocfecc_aecc = eval_cfecc(EdgeList, EdgeColors, ecc["node_color"], k)
            ocfecc_aecc_round_time = (time() - start) + cfecc_rowmin_time

            start = time()
            ocfecc_acfecc = eval_cfecc(EdgeList, EdgeColors, cfecc["node_color"], k)
            ocfecc_acfecc_round_time = (time() - start) + cfecc_rowmin_time

            println("    A_ECC: $ocfecc_acfecc ($(ocfecc_aecc_round_time)s)")
            println("    A_CFECC: $ocfecc_acfecc ($(ocfecc_acfecc_round_time)s)")

            write(file, "        $(dataset.name)")

            write(file, " & $(n)")
            write(file, " & $(m)")
            write(file, " & $(r)")
            write(file, " & $(k)")

            write(file, " & $(@sprintf("%0.2f", ecc["runtime"]))")
            write(file, " & $(@sprintf("%0.2f", cfecc["runtime"]))")

            write(file, " & $(@sprintf("%0.2f", oecc_aecc / ecc["lp_objective"]))")
            write(file, " & $(@sprintf("%0.2f", oecc_acfecc / ecc["lp_objective"]))")

            write(file, " & $(@sprintf("%0.2f", ocfecc_aecc / cfecc["lp_objective"]))")
            write(file, " & $(@sprintf("%0.2f", ocfecc_acfecc / cfecc["lp_objective"]))")

            write(file, "\\\\\n")

        end, datasets)

end