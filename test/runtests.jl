using PrintTypesTersely
using Test

struct A{T}
end

struct B{C,D}
	data::D
end

const B{C} = B{C, D} where {D}

@testset "PrintTypesTersely.jl" begin

	@testset "testing modes" begin
		PrintTypesTersely.on()
		@test PrintTypesTersely._terseprint[] == true
		PrintTypesTersely.off()
		@test PrintTypesTersely._terseprint[] == false
        PrintTypesTersely.with_state(true) do
			@test PrintTypesTersely._terseprint[] == true
        end
		PrintTypesTersely.with_state(false) do
			@test PrintTypesTersely._terseprint[] == false
        end
    end

    @testset "testing terseprint on" begin
        PrintTypesTersely.with_state(true) do
            @test repr(A{Vector{Int}}) == "A{…}"
            @test repr(A{Union{Int, Missing}}) == "A{…}"
            @test repr(B{Int, Float32}) == "B{…}"
            @test repr(B{Int}) == "B{…}"
            @test repr(DenseMatrix{Int}) == "DenseArray{…}"
            @test repr(StridedVector{Int}) == "Union{DenseArray{…}, Base.ReinterpretArray{…}, Base.ReshapedArray{…}, SubArray{…}}"
        end
    end

    @testset "testing terseprint off" begin
        PrintTypesTersely.with_state(false) do
            @test repr(A{Vector{Int}}) == "A{Array{Int64,1}}"
			@test repr(A{Union{Int, Missing}}) == "A{Union{Missing, Int64}}"
			@test repr(B{Int, Float32}) == "B{Int64,Float32}"
            @test repr(B{Int}) == "B{Int64,D} where D"
            @test repr(DenseMatrix{Int}) == "DenseArray{Int64,2}"
            @test repr(StridedVector{Int}) == "StridedArray{Int64, 1}"
        end
    end

	# add this after new Mill and JsonGrinder are released
	# include("mill_jsongrinder_integration.jl")
end
