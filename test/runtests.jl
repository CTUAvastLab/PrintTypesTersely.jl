using PrintTypesTersely
using Test

struct A{T}
end

struct B{C,D}
	data::D
end

const B{C} = B{C, D} where {D}

@testset "PrintTypesTersely.jl" begin

    @testset "testing terseprint on" begin
        PrintTypesTersely.with_state(true) do
            @test repr(A{Vector{Int}}) == "A{…}"
            @test repr(B{Int, Float32}) == "B{…}"
            @test repr(B{Int}) == "B{…}"
        end
    end

    @testset "testing terseprint off" begin
        PrintTypesTersely.with_state(false) do
            @test repr(A{Vector{Int}}) == "A{Array{Int64,1}}"
			@test repr(B{Int, Float32}) == "B{Int64,Float32}"
            @test repr(B{Int}) == "B{Int64,D} where D"
        end
    end

	# add this after new Mill and JsonGrinder are released
	# include("mill_jsongrinder_integration.jl")
end
