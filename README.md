# PrintTypesTersely

[![Build Status](https://github.com/CTUAvastLab/PrintTypesTersely.jl/workflows/CI/badge.svg)](https://github.com/CTUAvastLab/PrintTypesTersely.jl/actions?query=workflow%3ACI)
[![Coverage Status](https://coveralls.io/repos/github/CTUAvastLab/PrintTypesTersely.jl/badge.svg?branch=master)](https://coveralls.io/github/CTUAvastLab/PrintTypesTersely.jl?branch=master)
[![codecov.io](http://codecov.io/github/CTUAvastLab/PrintTypesTersely.jl/coverage.svg?branch=master)](http://codecov.io/github/CTUAvastLab/PrintTypesTersely.jl?branch=master)

When working with recursive structures containing parametric types, printing types (e.g. in error) gets very verbose.

**PrintTypesTersely** modifies printing types so only the first type is printed.

By default the functionality is turned off, but you can turn it on by:
```julia
using PrintTypesTersely
PrintTypesTersely.on()
```

now it starts to shorten types print.
So instead of e.g. `A{Union{Int, Missing}}`, you'll see only `A{…}`.
You can disable this behavior by
```julia
PrintTypesTersely.on()
```

or you can enable the behavior only for some block of code using
```julia
PrintTypesTersely.with_state(true) do
    @test repr(A{Vector{Int}}) == "A{…}"
    @test repr(A{Union{Int, Missing}}) == "A{…}"
    @test repr(B{Int, Float32}) == "B{…}"
    @test repr(B{Int}) == "B{…}"
end
```

That's all, basically.

The default value is `false` by default, because when turned on, it breaks compilation of some packages.
