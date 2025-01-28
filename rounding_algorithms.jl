function eval_ecc(EdgeList, EdgeColors, c)
    m = length(EdgeList)

    mistakes = 0

    for i = 1:m
        color = EdgeColors[i]
        edge = EdgeList[i]

        sas = true

        for j = edge
            if c[j] != color
                sas = false
                break
            end
        end

        if !sas
            mistakes += 1
        end
    end

    return mistakes
end

function eval_cfecc(EdgeList, EdgeColors, c, k)
    m = length(EdgeList)

    c_mistakes = zeros(k)

    for i = 1:m
        color = EdgeColors[i]
        edge = EdgeList[i]

        sas = true

        for j = edge
            if c[j] != color
                sas = false
            end
        end

        if !sas
            c_mistakes[color] += 1
        end
    end

    worst_color, worst_color_count = first(sort!(collect(enumerate(c_mistakes)), by=c -> c[2], rev=true))

    return worst_color_count
end

function eval_pcecc(EdgeList, EdgeColors, c, protected_color, protected_color_limit)
    m = length(EdgeList)

    pc_mistakes = 0
    mistakes = 0

    for i = 1:m
        color = EdgeColors[i]
        edge = EdgeList[i]

        sas = true

        for j = edge
            if c[j] != color
                sas = false
            end
        end

        if !sas
            if color == protected_color
                pc_mistakes += 1
            end
            mistakes += 1
        end
    end

    return (mistakes, pc_mistakes)
end