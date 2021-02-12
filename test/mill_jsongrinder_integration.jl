using Mill, JsonGrinder

metadata = fill("metadata", 4)
a = BagNode(ArrayNode(rand(3,4)),[1:4], metadata)
b = BagNode(ArrayNode(rand(3,4)),[1:2,3:4], metadata)
c = BagNode(ArrayNode(rand(3,4)),[1:1,2:2,3:4], metadata)
d = BagNode(ArrayNode(rand(3,4)),[1:4,0:-1], metadata)
wa = WeightedBagNode(ArrayNode(rand(3,4)),[1:4], rand(1:4, 4), metadata)
wb = WeightedBagNode(ArrayNode(rand(3,4)),[1:2,3:4], rand(1:4, 4), metadata)
wc = WeightedBagNode(ArrayNode(rand(3,4)),[1:1,2:2,3:4], rand(1:4, 4), metadata)
wd = WeightedBagNode(ArrayNode(rand(3,4)),[1:4,0:-1], rand(1:4, 4), metadata)
e = ArrayNode(rand(2, 2))

f = ProductNode((wb,b))
g = ProductNode([c, wc])
h = ProductNode((wc,c))
i = ProductNode((
              b,
              ProductNode((
                        b,
                        BagNode(
                                BagNode(
                                        ArrayNode(rand(2,4)),
                                        [1:1, 2:2, 3:3, 4:4]
                                       ),
                                [1:3, 4:4]
                               )
                       ))
             ))
k = ProductNode((a = wb, b = b))
l = ProductNode((a = wc, b = c))

ext1 = ExtractDict(Dict("a" => ExtractScalar(Float64,2,3),"b" => ExtractScalar(Float64), "c" => ExtractArray(ExtractScalar(Float64,2,3))))
ext2 = ExtractDict(Dict("a" => ExtractScalar(Float64,2,3)))

@testset "testing terseprint on - Mill" begin
    PrintTypesTersely.with_state(true) do
        @test repr(typeof([h,i])) == "Array{…}"
        @test repr(typeof(h)) == "ProductNode{…}"
    end
end

@testset "testing terseprint off - Mill" begin
    PrintTypesTersely.with_state(false) do
        @test repr(typeof([h,i])) == (VERSION < v"1.6.0-" ? "Array{ProductNode{T,Nothing} where T,1}" : "Vector{ProductNode{T, Nothing} where T}")
        # because there are metadata in Mill 2.4 but not in 2.3
        if :metadata ∈ fieldnames(LazyNode)
            @test repr(typeof(h)) ==  (VERSION < v"1.6.0-" ?
                "ProductNode{Tuple{WeightedBagNode{ArrayNode{Array{Float64,2},Nothing},AlignedBags{Int64},Int64,Array{String,1}},BagNode{ArrayNode{Array{Float64,2},Nothing},AlignedBags{Int64},Array{String,1}}},Nothing}" :
                "ProductNode{Tuple{WeightedBagNode{ArrayNode{Matrix{Float64}, Nothing}, AlignedBags{Int64}, Int64, Vector{String}}, BagNode{ArrayNode{Matrix{Float64}, Nothing}, AlignedBags{Int64}, Vector{String}}}, Nothing}")
        else
            @test repr(typeof(h)) ==  (VERSION < v"1.6.0-" ?
                "ProductNode{Tuple{WeightedBagNode{ArrayNode{Array{Float64,2},Nothing},AlignedBags,Int64,Array{String,1}},BagNode{ArrayNode{Array{Float64,2},Nothing},AlignedBags,Array{String,1}}},Nothing}" :
                "ProductNode{Tuple{WeightedBagNode{ArrayNode{Matrix{Float64}, Nothing}, AlignedBags{Int64}, Int64, Vector{String}}, BagNode{ArrayNode{Matrix{Float64}, Nothing}, AlignedBags{Int64}, Vector{String}}}, Nothing}")
        end
    end
end

@testset "testing terseprint on - JsonGrinder" begin
    PrintTypesTersely.with_state(true) do
        @test repr(typeof([ext1, ext2])) == "Array{…}"
        @test repr(typeof(ext1)) == "ExtractDict{…}"
    end
end

@testset "testing terseprint off - JsonGrinder" begin
    PrintTypesTersely.with_state(false) do
        @test repr(typeof([ext1, ext2])) == (VERSION < v"1.6.0-" ? "Array{ExtractDict,1}" : "Vector{ExtractDict}")
        @test repr(typeof(ext1)) == (VERSION < v"1.6.0-" ?
            "ExtractDict{Dict{String,JsonGrinder.AbstractExtractor}}" :
            "ExtractDict{Dict{String, JsonGrinder.AbstractExtractor}}")
    end
end

@testset "testing obscure terseprint things" begin
    function experiment(ds::LazyNode{T}) where {T<:Symbol}
        @show ds
        @show T
    end
    a = methods(experiment)
    a_method = a.ms[1]
    b = getfield(a_method.sig, 2)
    c = getfield(b, 3)
    d = c[2]
    e = d.body

    t = UnionAll(TypeVar(:t), LazyNode)
    u = typeof(LazyNode(:oh_hi, ["Mark"]))

    orig_terse = PrintTypesTersely._terseprint[]

    v = UnionAll(TypeVar(:T, AbstractMillModel), BagModel)

    PrintTypesTersely.with_state(true) do
        @test occursin("(ds::LazyNode{…}) where T<:Symbol", repr(methods(experiment)))
        @test repr(t) == "LazyNode{…}"
        @test repr(u) == "LazyNode{…}"
        @test repr(d) == "LazyNode{…}"
        @test repr(e) == "LazyNode{…}"
        @test repr(v) == "BagModel{…}"
    end

    PrintTypesTersely.with_state(false) do
        # because there are metadata in Mill 2.4 but not in 2.3
        if :metadata ∈ fieldnames(LazyNode)
            expected = (VERSION < v"1.6.0-" ? "(ds::LazyNode{T,D,C} where C where D) where T<:Symbol" :
            "(ds::LazyNode{T, D, C} where {D, C}) where T<:Symbol")
            @test occursin(expected, repr(methods(experiment)))
            @test repr(u) == (VERSION < v"1.6.0-" ? "LazyNode{:oh_hi,Array{String,1},Nothing}" : "LazyNode{:oh_hi, Vector{String}, Nothing}")
            @test repr(d) == (VERSION < v"1.6.0-" ? "LazyNode{T<:Symbol,D,C} where C where D" : "LazyNode{T<:Symbol, D, C} where {D, C}")
            @test repr(e) == (VERSION < v"1.6.0-" ? "LazyNode{T<:Symbol,D,C} where C" : "LazyNode{T<:Symbol, D, C} where C")
        else
            expected = (VERSION < v"1.6.0-" ? "(ds::LazyNode{T,D} where D) where T<:Symbol" :
            "(ds::LazyNode{T, D} where D) where T<:Symbol")
            @test occursin("(ds::LazyNode{T,D} where D) where T<:Symbol", repr(methods(experiment)))
            @test repr(u) == (VERSION < v"1.6.0-" ? "LazyNode{:oh_hi,Array{String,1}}" : "LazyNode{:oh_hi, Vector{String}}")
            @test repr(d) == "LazyNode{T<:Symbol,D} where D"
            @test repr(e) == (VERSION < v"1.6.0-" ? "LazyNode{T<:Symbol,D}" : "LazyNode{T<:Symbol, D}")
        end
        @test repr(t) == "LazyNode"
        @test repr(v) == "BagModel"
    end
end
