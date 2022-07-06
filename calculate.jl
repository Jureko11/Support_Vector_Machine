function calculate(α,x,y,k)
    # Berechung von w
    w = [0;0]
    for i = 1:k
        w = w + α[i]*y[i]*x
    end

    # Berechnung von b
    sI = set()      # in diesem Array sind alle Indizes, für die α echt größer als 0 ist
    for i in α      # gehe durch den Spaltenvektor α
        if α > 0    # wenn der Wert für α echt größer als 0, dann füge ihn zum set sI hinzu
            push!(sI, i)

    inner_sum = 0
    outer_sum = 0
    for i=1:(length(sI))    # berechne die äußere Summenformel
        for j=1:(length(sI))    # brechen die innere Summenformel
            
            
