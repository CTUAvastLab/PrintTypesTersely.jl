module PrintTypesTersely

import Base

# const _terseprint = Ref(true)
const _terseprint = Ref(false)

on() = set(true)
off() = set(false)

function set(a)
    _terseprint[] = a
end

function with_state(f::Function, a)
    orig_val = _terseprint[]
    _terseprint[] = a
    f()
    _terseprint[] = orig_val
end

function base_show_terse(io::IO, @nospecialize(x::Type))
    # print(io, typeof(x))
    if x isa Union
        print(io, "Union")
        Base.show_delim_array(io, Base.uniontypes(x), '{', ',', '}', false)
        return
    end
    x = Base.unwrap_unionall(x)
    print(io, "$(x.name){…}")
    return
end

@static if VERSION < "1.6.0-"
function base_show_full_1_5(io::IO, @nospecialize(x::Type))
    # basically copied from the Julia sourcecode, seems it's one of most robust fixes to Pevňákoviny
    # specifically function show(io::IO, @nospecialize(x::Type))
    if x isa DataType
        Base.show_datatype(io, x)
        return
    elseif x isa Union
        if x.a isa DataType && Core.Compiler.typename(x.a) === Core.Compiler.typename(DenseArray)
            T, N = x.a.parameters
            if x == StridedArray{T,N}
                print(io, "StridedArray")
                Base.show_delim_array(io, (T,N), '{', ',', '}', false)
                return
            elseif x == StridedVecOrMat{T}
                print(io, "StridedVecOrMat")
                Base.show_delim_array(io, (T,), '{', ',', '}', false)
                return
            elseif StridedArray{T,N} <: x
                print(io, "Union")
                Base.show_delim_array(io, vcat(StridedArray{T,N}, Base.uniontypes(Core.Compiler.typesubtract(x, StridedArray{T,N}))), '{', ',', '}', false)
                return
            end
        end
        print(io, "Union")
        Base.show_delim_array(io, Base.uniontypes(x), '{', ',', '}', false)
        return
    end

    x::UnionAll
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
end

@static if VERSION >= "1.6.0-"
function base_show_full_1_6(io::IO, @nospecialize(x::Type))
    # basically copied from the Julia sourcecode, seems it's one of most robust fixes to Pevňákoviny
    # specifically function show(io::IO, @nospecialize(x::Type))
    if Base.print_without_params(x)
        Base.show_type_name(io, Base.unwrap_unionall(x).name)
        return
    elseif get(io, :compact, true) && Base.show_typealias(io, x)
        return
    elseif x isa DataType
        Base.show_datatype(io, x)
        return
    elseif x isa Union
        if get(io, :compact, true)
            Base.show_unionaliases(io, x)
        else
            print(io, "Union")
            Base.show_delim_array(io, Base.uniontypes(x), '{', ',', '}', false)
        end
        return
    end

    x = x::UnionAll
    wheres = TypeVar[]
    let io = IOContext(io)
        while x isa UnionAll
            var = x.var
            if var.name === :_ || Base.io_has_tvar_name(io, var.name, x)
                counter = 1
                while true
                    newname = Symbol(var.name, counter)
                    if !Base.io_has_tvar_name(io, newname, x)
                        var = TypeVar(newname, var.lb, var.ub)
                        x = x{var}
                        break
                    end
                    counter += 1
                end
            else
                x = x.body
            end
            push!(wheres, var)
            io = IOContext(io, :unionall_env => var)
        end
        show(io, x)
    end
    Base.show_wheres(io, wheres)
end
end

function Base.show(io::IO, @nospecialize(x::Type))
    # println("_terseprint[] in Base.show: $(_terseprint[])")
    if _terseprint[]
        return base_show_terse(io, x)
    else
        # VERSION < v"1.6.0-" returns true for 1.5.* and older, but for rc and beta of 1.6 it returns true
        @static if VERSION < v"1.6.0-"
            return base_show_full_1_5(io, x)
        else
            return base_show_full_1_6(io, x)
        end
    end
end

end
