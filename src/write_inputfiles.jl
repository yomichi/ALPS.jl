export Parameter, Parameters
export write_parameterfile
export write_inputfiles

@doc """
`ALPS.Parameter`, which is a typealias of `Dict{AbstractString, Any}`,
represents a set of mapping from parameter name to parameter value.
One `Parameter` corresponds to one ALPS task.
""" typealias Parameter Dict{AbstractString, Any}

@doc """
`ALPS.Parameters` is a typealias of `Vector{ALPS.Parameter}`.
One `Parameters` corresponds to one (whole) ALPS simulation.
""" typealias Parameters Vector{Parameter}

Parameters() = Parameter[]

@doc """
Generates a plain text parameter file from `parameter`,
and returns parameter filename.
""" ->
function write_parameterfile(filename :: AbstractString, parameter::Parameter)
  open(filename, "w")do io
    for (k,v) in parameter
      println(io, k, " = ", v)
    end
  end
  return filename
end

@doc """
Generates XML input files for ALPS simulation from `parameters`
and returns master XML file, `$(filename_prefix).in.xml`.
""" ->
function write_inputfiles(filename_prefix :: AbstractString, parameters::Parameters; baseseed :: Union(Unsigned, ()) = () )

  masterfilename = "$(filename_prefix).in.xml"

  if baseseed == ()
    baseseed = generate_seed()
  end

  bits = 31 - ndigits(length(parameters),2)

  io = open(masterfilename, "w")
  println(io, """<?xml version="1.0" encoding="UTF-8"?>""")
  println(io, """<?xml-stylesheet type="text/xsl" href="ALPS.xsl"?>""")
  print(io, """<JOB """)
  print(io, """xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" """)
  println(io, """xsi:noNamespaceSchemaLocation="http://xml.comp-phys.org/2003/8/job.xsd">""")
  println(io, """  <OUTPUT file="$filename_prefix.out.xml"/>""")

  for (i, p) in enumerate(parameters) 
    println(io, """  <TASK status="new">""")
    println(io, """    <INPUT file="$filename_prefix.task$i.in.xml"/>""")
    println(io, """    <OUTPUT file="$filename_prefix.task$i.out.xml"/>""")
    println(io, """  </TASK>""")

    if !haskey(p, "SEED")
      seed = baseseed
      for j in 0:(div(32,bits)+1)
        seed $= ((i-1) << (j*bits))
        seed &= ((1<<30) | ((1<<30)-1))
      end
      p["SEED"] = seed
    end
    write_taskfile("$(filename_prefix).task$(i).in.xml",p)
  end
  println(io, """</JOB>""")
  close(io)
  copy_stylesheet()
  return masterfilename
end

function write_taskfile(filename::AbstractString, parameter::Parameter)
  io = open(filename, "w")
  println(io, """<?xml version="1.0" encoding="UTF-8"?>""")
  println(io, """<?xml-stylesheet type="text/xsl" href="ALPS.xsl"?>""")
  print(io, """<SIMULATION """)
  print(io, """xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" """)
  println(io, """xsi:noNamespaceSchemaLocation="http://xml.comp-phys.org/2003/8/job.xsd">""")
  println(io, """  <PARAMETERS>""")
  for (k,v) in parameter
    print(io, """    <PARAMETER name="$k">""")
    print(io, v)
    println(io, """</PARAMETER>""")
  end
  println(io, """  </PARAMETERS>""")
  println(io, """</SIMULATION>""")
  close(io)
end

function generate_seed()
  seed = uint(time()*1.0e9)
  (seed << 10) | (seed >> 22)
end

function copy_stylesheet(dst :: AbstractString = "./ALPS.xsl")
  if ispath(dst)
    return nothing
  end
  src = joinpath(dirname(@__FILE__()), "ALPS.xsl")
  cp(src, dst)
  return nothing
end
