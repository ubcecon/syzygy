if !isdir(ENV["HOME"] * "/.julia/environments") && isdir("/opt/julia/environments")
    isdir(ENV["HOME"] * "/.julia") ? true : mkdir(ENV["HOME"] * "/.julia")
    cp("/opt/julia/environments", ENV["HOME"] * "/.julia/environments")
end
