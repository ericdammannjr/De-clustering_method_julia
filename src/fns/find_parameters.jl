function find_parameters(dataframe, percentile, W)

    time = dataframe[:, 1]
    data = dataframe[:, 2]
    th = quantile(dataframe[:, 2], percentile)
    EOT = dataframe[dataframe[:, 2] .> th, :]
    n = 0
    POT = fill(NaN, size(EOT))

    while n < size(EOT, 1)

        fmax = argmax(EOT[:, 2])
        POT[fmax, :] = EOT[fmax, :]
        dec_wind = findall((EOT[:, 1] .>= EOT[fmax, 1] - W/2) .& (EOT[:, 1] .<= EOT[fmax, 1] + W/2))
        EOT[dec_wind, 2] .= -Inf
        n = count(x -> x == -Inf, EOT[:, 2])

    end

    POT = POT[.!isnan.(POT[:, 2]), :]
    row_dimension = zeros(size(POT, 1))
    windows = Vector{Vector{Int64}}()

    for i in axes(POT,1)

        cent = POT[i,1]
        window = findall((time .>= cent - W/2) .& (time .<= cent + W/2))
        row_dimension[i] = length(window)
        push!(windows,window)

    end

    num_rows = Int(maximum(row_dimension))
    num_columns = size(POT, 1)
    sl = zeros(num_rows,num_columns)

    for i in axes(sl,2)

        sl[1:Int(row_dimension[i]),i] = data[Int.(windows[i])]

    end

    corr = cor(sl')
    M = mean(corr, dims = 2)
    S = std(corr, dims = 2)
    C = length(M)/2
    mx = findfirst(x -> x == maximum(M), M)
    mx_s = findfirst(x -> x == maximum(M .+ S), M .+ S)
    SED = abs(mx[1]-C)*2
    soft_margin = abs(SED/2 - abs(mx_s[1] - C))

    return SED, soft_margin

end