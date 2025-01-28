datasets = vcat(
    map(
        s -> (name=s, load=function ()
            data = load("ImprovedECC/include/CategoricalEdgeClustering-master/data/JLD_Files/" * s * ".jld")
            return (data["n"], data["EdgeColors"], data["EdgeList"])
        end),
        ["DAWN", "MAG-10", "Cooking", "Brain", "Walmart-Trips"]
    ),
    (name="Trivago-Clickout", load=function ()
        data = matread("ImprovedECC/trivago-dataset/Trivago_Clickout_EdgeLabels.mat")
        H = data["H"]
        m, n = size(H)
        return (n, data["EdgeLabels"], incidence2elist(H))
    end)
)