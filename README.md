# ALPS.jl

[![Build Status](https://travis-ci.org/yomichi/ALPS.jl.svg?branch=master)](https://travis-ci.org/yomichi/ALPS.jl)

This package aims to serve Julia API to handle I/O files of [ALPS (Algorithms and Libraries for Physics Simulations)](http://alps.comp-phys.org/mediawiki/index.php/Main_Page), for example, to generate input files.

NOTE : This is UNOFFICIAL project.

# Requirements
- Julia v0.4-
- ALPS2
    - Note that `ALPS.jl` does not build ALPS automatically.

# Install

     julia> Pkg.add("ALPS")

# Usage

    using ALPS

    # Parameter and Parameters are typealias of
    # Dict{AbstractArray, Any} and Vector{Parameter}

    params = Parameters()
    for T in 1.0:0.1:2.0
      push!(params, Parameter(
        "LATTICE" => "chain lattice",
        "MODEL" => "spin",
        "ALGORITHM" => "loop",
        "L" => 8,
        "T" => T
      ))
    end

    # generate input xml files named 'params.in.*.xml'
    write_inputfiles("params", params)

In future, ALPS.jl will serve API for running ALPS application and extracting data from output DHF5 files.

# Status
- Implemented features
    - To generate Input files
- Future plans 
    - To execute ALPS application
    - To extract data from output HDF5 files

