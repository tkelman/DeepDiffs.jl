# diffing an array is an application of the Longest Common Subsequence problem:
# https://en.wikipedia.org/wiki/Longest_common_subsequence_problem
function structdiff{T <: Union{Vector, String}}(X::T, Y::T)
    # we're going to solve with dynamic programming, so let's first pre-allocate
    # our result array, which will store possible lengths of the common
    # substrings.

    lengths = zeros(Int, length(X)+1, length(Y)+1)

    for (j, v2) in enumerate(Y)
        for (i, v1) in enumerate(X)
            if v1 == v2
                lengths[i+1, j+1] = lengths[i, j] + 1
            else
                lengths[i+1, j+1] = max(lengths[i+1, j], lengths[i, j+1])
            end
        end
    end

    removed = Int[]
    added = Int[]
    backtrack(lengths, removed, added, X, Y, length(X), length(Y))

    (removed, added)
end

# recursively trace back the longest common subsequence, adding items
# to the added and removed lists as we go
function backtrack(lengths, removed, added, X, Y, i, j)
    if i > 0 && j > 0 && X[i] == Y[j]
        backtrack(lengths, removed, added, X, Y, i-1, j-1)
    elseif j > 0 && (i == 0 || lengths[i+1, j] ≥ lengths[i, j+1])
        backtrack(lengths, removed, added, X, Y, i, j-1)
        push!(added, j)
    elseif i > 0 && (j == 0 || lengths[i+1, j] < lengths[i, j+1])
        backtrack(lengths, removed, added, X, Y, i-1, j)
        push!(removed, i)
    end
end

function Base.show{T<:Array, ET}(io::IO, diff::StructureDiff{T, ET})
    from = diff.orig[1]
    to = diff.orig[2]

    ifrom = 1
    iremoved = 1
    print(io, "[")
    while ifrom < length(from)
        printitem(io, :red, from, ifrom, diff.removed, iremoved) && (iremoved += 1)
        print(io, ", ")
        ifrom += 1
    end
    printitem(io, :red, from, ifrom, diff.removed, iremoved) && (iremoved += 1)
    println(io, "]")

    ito = 1
    iadded = 1
    print(io, "[")
    while ito < length(to)
        printitem(io, :green, to, ito, diff.added, iadded) && (iadded += 1)
        print(io, ", ")
        ito += 1
    end
    printitem(io, :green, to, ito, diff.added, iadded) && (iadded += 1)
    println(io, "]")
end

# returns true if the item matched
function printitem(io, color, data, dataidx, match, matchidx)
    if matchidx > length(match) || dataidx != match[matchidx]
        print(io, data[dataidx])
        false
    else
        print_with_color(color, io, string(data[dataidx]))
        true
    end
end
