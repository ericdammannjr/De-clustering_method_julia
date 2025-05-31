using CSV, DataFrames, Statistics

include("fns/find_parameters.jl")
include("fns/de_cluster.jl")

dataframe = Matrix(CSV.read("data/Example_abashiri.csv", DataFrame))

percentile = 0.99

W = 6.0

SED, soft_margin = find_parameters(dataframe, percentile, W)

Ind_events = de_cluster(dataframe, percentile, SED, soft_margin)