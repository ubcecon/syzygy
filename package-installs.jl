import Pkg

Pkg.pkg"st"
# cp("/tmp/environments/Project.toml","/opt/julia-1.0/local/share/julia/environments/v1.0/Project.toml")
Pkg.activate("/tmp/environments/v1.0")
Pkg.instantiate()
Pkg.pkg"add BinDeps Cairo Calculus Clustering Clp Colors DataFrames DataFramesMeta Dates DecisionTree Distributions Distances GLM HDF5 HypothesisTests IJulia Ipopt JSON KernelDensity Lazy MLBase MultivariateStats NLopt Optim ODE PDMats PGFPlots Plots PyCall PyPlot QuantEcon RDatasets SQLite Stan StatsBase Sundials ZipFile ZMQ; precompile"
Pkg.pkg"st"
