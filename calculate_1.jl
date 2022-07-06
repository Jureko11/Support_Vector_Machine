function calculate(α,x,y,k)
    # Berechung von w
    w = [0;0]
    for i = 1:k
        w = w + α[i]*y[i]*x
    end

    # Berechnung von b
    sI = Set()      # in diesem Array sind alle Indizes, für die α echt größer als 0 ist
    for i in α      # gehe durch den Spaltenvektor α
        if α[i] > 0    # wenn der Wert für α echt größer als 0, dann füge den Index an dem dieser Wert steht in sI ein
            push!(sI, i)
        end
    end

    inner_sum = 0
    outer_sum = 0
    I = length(sI)
    for i ∈ sI    # berechne die äußere Summenformel
        for j ∈ sI    # berechne die innere Summenformel
            inner_sum = inner_sum + α[j]*y[j]*x'[j]*x[i]        # x' ist die Transponierte von x        # Darf man x' verwenden?? In Julia steht dann immer adjoint (=adjungierte) was eigentlich für komplexe Matrizen ist
        outer_sum = outer_sum + y[i] - inner_sum
        end
    end
    b = 1/I * outer_sum


function quadratic_programm(x,y,k)
    using LinearAlgebra
    #=
    z = -ones(n)
    A = ones(n) .* Y'
    C = -Matrix{Float64}(I,n,n)
    b = zeros(n)
    d = zeros(n)

    P = ... 0.001Matrix{Float64}(I,n,n)
    =#
    k = length(y)
    M = ones(k,k)
    for i in k:
        for j in k:
            M[i,j] = y[i]*y[j]*dot(x[i], x[j])
