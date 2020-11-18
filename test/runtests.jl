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
            @test repr(StridedVecOrMat{Int}) == "Union{DenseArray{…}, DenseArray{…}, Base.ReinterpretArray{…}, Base.ReinterpretArray{…}, Base.ReshapedArray{…}, Base.ReshapedArray{…}, SubArray{…}, SubArray{…}}"
            @test repr(Union{StridedVector{Int}, Int}) == "Union{Int64{…}, DenseArray{…}, Base.ReinterpretArray{…}, Base.ReshapedArray{…}, SubArray{…}}"
            @test repr(UnionAll(TypeVar(:T,Integer), Array)) == "Array{…}"
            @test repr(Union{StridedMatrix{Int}, StridedArray{Int,3}}) == "Union{DenseArray{…}, DenseArray{…}, Base.ReinterpretArray{…}, Base.ReinterpretArray{…}, Base.ReshapedArray{…}, Base.ReshapedArray{…}, SubArray{…}, SubArray{…}}"
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
            @test repr(StridedVecOrMat{Int}) == "StridedVecOrMat{Int64}"
			@test repr(Union{StridedVector{Int}, Int}) == "Union{Int64, DenseArray{Int64,1}, Base.ReinterpretArray{Int64,1,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray}, Base.ReshapedArray{Int64,1,A,MI} where MI<:Tuple{Vararg{Base.MultiplicativeInverses.SignedMultiplicativeInverse{Int64},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray}, SubArray{Int64,1,A,I,L} where L where I<:Tuple{Vararg{Union{Int64, AbstractRange{Int64}, Base.AbstractCartesianIndex, Base.ReshapedArray{T,N,A,Tuple{}} where A<:AbstractUnitRange where N where T},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, Base.ReshapedArray{T,N,A,MI} where MI<:Tuple{Vararg{Base.MultiplicativeInverses.SignedMultiplicativeInverse{Int64},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, DenseArray}}"
			@test repr(UnionAll(TypeVar(:T,Integer), Array)) == "Array"
			@test repr(Union{StridedMatrix{Int}, StridedArray{Int,3}}) == "Union{StridedArray{Int64, 3}, DenseArray{Int64,2}, Base.ReinterpretArray{Int64,2,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray}, Base.ReshapedArray{Int64,2,A,MI} where MI<:Tuple{Vararg{Base.MultiplicativeInverses.SignedMultiplicativeInverse{Int64},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray}, SubArray{Int64,2,A,I,L} where L where I<:Tuple{Vararg{Union{Int64, AbstractRange{Int64}, Base.AbstractCartesianIndex, Base.ReshapedArray{T,N,A,Tuple{}} where A<:AbstractUnitRange where N where T},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, Base.ReshapedArray{T,N,A,MI} where MI<:Tuple{Vararg{Base.MultiplicativeInverses.SignedMultiplicativeInverse{Int64},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, DenseArray}}"
        end
    end

	# add this after new Mill and JsonGrinder are released
	# include("mill_jsongrinder_integration.jl")
end
