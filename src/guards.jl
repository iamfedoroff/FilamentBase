function guard(x, width; p=6, shape=:both)
    if shape == :left
        guard_left(x, width; p)
    elseif shape == :right
        guard_right(x, width; p)
    elseif shape == :both
        guard_both(x, width; p)
    else
        error("The shape must be one of :left, :right, or :both.")
    end
end


function guard_left(x, width; p=6)
    if width >= (x[end] - x[1])
        error("Guard width should be smaller than the grid domain size.")
    end
    N = length(x)
    if width == 0
        guard = ones(N)
    else
        xloc1 = x[1]
        xloc2 = x[1] + width
        gauss1 = zeros(N)
        gauss2 = ones(N)
        for i=1:N
            if x[i] >= xloc1
                gauss1[i] = 1 - exp(-((x[i] - xloc1) / (width / 2))^p)
            end
            if x[i] <= xloc2
                gauss2[i] = exp(-((x[i] - xloc2) / (width / 2))^p)
            end
        end
        guard = @. (gauss1 + gauss2) / 2
    end
    return guard
end


function guard_right(x, width; p=6)
    if width >= (x[end] - x[1])
        error("Guard width should be smaller than the grid domain size.")
    end
    N = length(x)
    if width == 0
        guard = ones(N)
    else
        xloc1 = x[end] - width
        xloc2 = x[end]
        gauss1 = ones(N)
        gauss2 = zeros(N)
        for i=1:N
            if x[i] >= xloc1
                gauss1[i] = exp(-((x[i] - xloc1) / (width / 2))^p)
            end
            if x[i] <= xloc2
                gauss2[i] = 1 - exp(-((x[i] - xloc2) / (width / 2))^p)
            end
        end
        guard = @. (gauss1 + gauss2) / 2
    end
    return guard
end


function guard_both(x, width; p=6)
    if width >= (x[end] - x[1]) / 2
        error("Guard width should be smaller than the grid domain size.")
    end
    lguard = guard_left(x, width; p=p)
    rguard = guard_right(x, width; p=p)
    return @. lguard + rguard - 1
end
