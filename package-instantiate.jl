import Pkg

mkdir(ENV["HOME"] * "/.julia")
mkdir(ENV["HOME"] * "/.julia/environments")
cp("tmp/environments", ENV["HOME"] * "/.julia/environments",force=true)
