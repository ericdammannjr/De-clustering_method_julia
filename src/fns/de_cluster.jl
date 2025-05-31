function de_cluster(dataframe, percentile, SED, soft_margin)

    th = quantile(dataframe[:, 2], percentile)
    W = SED/24
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

    if isdefined(Main, :EOT)

        eval(Main, :(Base.delete_binding(Main, :EOT)))

    end

    s_event = POT[:,1] .- W/2
    e_event = POT[:,1] .+ W/2
    dif_events = (s_event[2:end] .- e_event[1:end-1]) .* 24
    t = findall(x -> round(x) <= soft_margin, dif_events)
    n = length(t)

    if n != 0

        EOT = fill(NaN, length(e_event), 2)
        EOT[:, 2] .= POT[:, 2]
        EOT[1:end-1, 1] .= dif_events
        N_POT = copy(POT)
        fmax = zeros(Int, n, 2)  

        for k in 1:n

            P = t[k]
            fmin = minimum(EOT[P:P+1, 2])
            h = findall(x -> x == fmin, EOT[:, 2])
            fmax[k, 1] = findfirst(x -> x == maximum(EOT[P:P+1, 2]), EOT[:, 2])
            fmax[k, 2] = h[end]
            EOT[h, 2] .= 0

        end

        N_POT[:, 2] .= EOT[:, 2]
        N_POT = N_POT[N_POT[:, 2] .!= 0, :]
        Ind_events = zeros(size(N_POT))
        Ind_events[:, 1] .= N_POT[:, 1]
        Ind_events[:, 2] .= N_POT[:, 2]

        return Ind_events

    else

        Ind_events = zeros(size(POT))
        Ind_events[:, 1] .= POT[:, 1]
        Ind_events[:, 2] .= POT[:, 2]

        return Ind_events

    end

end