module PrintTypesTersely

import Mill: AbstractNode, AbstractMillModel
import JsonGrinder: AbstractExtractor
import Base

TerseTypes = Union{AbstractNode,AbstractMillModel,AbstractExtractor}

const _terseprint = Ref(true)

function terseprint(a)
    _terseprint[] = a
end

function with_terseprint(f::Function, a)
    orig_val = _terseprint[]
    _terseprint[] = a
    f()
    _terseprint[] = orig_val
end

function base_show_terse(io::IO, x::Type{T}) where {T<:TerseTypes}
    while hasproperty(x, :body) && !hasproperty(x, :name)
        x = x.body
    end
    print(io, "$(x.name){…}")
    return
end

function base_show_full(io::IO, x::Type{T}) where {T<:TerseTypes}
    # basically copied from the Julia sourcecode, seems it's one of most robust fixes to Pevňákoviny
    # specifically function show(io::IO, @nospecialize(x::Type))
    if x isa DataType
        Base.show_datatype(io, x)
        return
    elseif x isa Union
        if x.a isa DataType && Core.Compiler.typename(x.a) === Core.Compiler.typename(DenseArray)
            T2, N = x.a.parameters
            if x == StridedArray{T2,N}
                print(io, "StridedArray")
                Base.show_delim_array(io, (T2,N), '{', ',', '}', false)
                return
            elseif x == StridedVecOrMat{T2}
                print(io, "StridedVecOrMat")
                Base.show_delim_array(io, (T2,), '{', ',', '}', false)
                return
            elseif StridedArray{T2,N} <: x
                print(io, "Union")
                Base.show_delim_array(io, vcat(StridedArray{T2,N}, Base.uniontypes(Core.Compiler.typesubtract(x, StridedArray{T2,N}))), '{', ',', '}', false)
                return
            end
        end
        print(io, "Union")
        Base.show_delim_array(io, Base.uniontypes(x), '{', ',', '}', false)
        return
    end

    # this type assert is behaving obscurely. When in Mill, it does not assert that LazyNode{T<:Symbol,D} where D is UnionAll, but in debugging using Debugger, it does
    # x::UnionAll
    if Base.print_without_params(x)
        return show(io, Base.unwrap_unionall(x).name)
    end

    if x.var.name === :_ || Base.io_has_tvar_name(io, x.var.name, x)
        counter = 1
        while true
            newname = Symbol(x.var.name, counter)
            if !Base.io_has_tvar_name(io, newname, x)
                newtv = TypeVar(newname, x.var.lb, x.var.ub)
                x = UnionAll(newtv, x{newtv})
                break
            end
            counter += 1
        end
    end

    show(IOContext(io, :unionall_env => x.var), x.body)
    print(io, " where ")
    show(io, x.var)
end

function Base.show(io::IO, x::Type{T}) where {T<:TerseTypes}
    if _terseprint[]
        return base_show_terse(io, x)
    else
        return base_show_full(io, x)
    end
end

end
