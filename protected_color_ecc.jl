using SparseArrays
using LinearAlgebra
using StatsBase
using JuMP
using Gurobi
using Clustering

function protected_color_ecc(EdgeList::Vector{Vector{Int64}}, EdgeColors::Array{Int64,1}, n::Int64, protected_color::Int64, protected_color_limit::Int64, optimalflag::Bool=false, outputflag::Int64=0)

    k = maximum(EdgeColors)
    m = length(EdgeList)

    model = Model(optimizer_with_attributes(() -> Gurobi.Optimizer(gurobi_env), "OutputFlag" => outputflag))
    set_silent(model)
    set_optimizer_attribute(model, "OutputFlag", 0)

    @variable(model, x_e[1:m])

    if optimalflag
        @variable(model, x_vc[1:n, 1:k], Bin)
    else
        @variable(model, x_vc[1:n, 1:k])
        @constraint(model, x_vc .<= ones(n, k))
        @constraint(model, x_vc .>= zeros(n, k))
        @constraint(model, x_e .<= ones(m))
        @constraint(model, x_e .>= zeros(m))
    end

    for i = 1:n
        @constraint(model, sum(x_vc[i, j] for j = 1:k) == k - 1)
    end

    E = filter(e -> EdgeColors[e] == protected_color, 1:m)
    @constraint(model, sum(x_e[j] for j = E) <= protected_color_limit)

    @objective(model, Min, sum(x_e[i] for i = 1:m))

    for e = 1:m
        color = EdgeColors[e]
        edge = EdgeList[e]

        for v = edge
            @constraint(model, x_e[e] >= x_vc[v, color])
        end
    end
    start = time()
    JuMP.optimize!(model)
    runtime = time() - start

    X = JuMP.value.(x_vc)
    LPval = JuMP.objective_value(model)

    return LPval, X, runtime
end