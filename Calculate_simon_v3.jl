using LinearAlgebra
using CSV
using DataFrames
using QPDAS
using PyCall
using PyPlot
using Glob

function svm(beispiel)
    println("\nGeht los mit $beispiel !\n")
    # Einlesen der Daten aus den Dateien und speichern dieser in einer passenden Form
    values_dataframe = DataFrame(CSV.read("./$beispiel", DataFrame, header=[:x1, :x2, :y]))  # allgemeiner Import
    # values_dataframe = DataFrame(CSV.read("D:\\_Simon\\_Studium\\Drive\\GoodNotes\\CoMa\\Programmierprojekt Support Vector Machine\\$beispiel", DataFrame, header=[:x1, :x2, :y]))
    # values_dataframe = DataFrame(CSV.read("D:\\Users\\Simon\\tubcloud\\CoMa\\Programmierprojekt Support Vector Machine\\Beispiel1.txt", DataFrame, header=[:x1, :x2, :y]))
    # values_dataframe = DataFrame(CSV.read("D:\\Studium\\TU Berlin\\2022_SoSe\\CoMa II\\Programmierprojekt\\Beispiel1.txt", DataFrame, header=[:x1, :x2, :y]))

    # println("values_dataframe", values_dataframe)
    d = values_dataframe[:, 1:2]
    # println("d ", d)


    x = [[d[i,1], d[i, 2]] for i in 1:nrow(values_dataframe)]
    punkte = [[values_dataframe[i,1], values_dataframe[i, 2], values_dataframe[i, 3]] for i in 1:nrow(values_dataframe)]
    # println("x ", x)
    # println("punkte ", punkte)
    y = values_dataframe[:, 3]
    # println("y ", y)

    # x = convert(Vector{Float64}, x)
    y = convert(Vector{Float64}, y)

    #=
    println(x)
    println(y)
    println(typeof(x))
    println(typeof(y))
    =#

    # Berechnung des quadratischen Programms
    k = length(y)
    M = ones(k,k)
    for i=1:k
        for j=1:k
            M[i,j] = y[i]*y[j]*(x[i] ⋅ x[j])
        end
    end
    # println("M=",M)
    P = M + 0.001*Matrix{Float64}(I,k,k)

    z = -ones(k)
    # A = ones(k,k) .* y'
    A = permutedims(y)
    C = -Matrix{Float64}(I,k,k)
    b = [0.0]
    d = zeros(k)

    #=
    println("P=",P)
    println("z=",z)
    println("A=",A)
    println("C=",C)
    println("b=",b)
    println("d=",d)
    =#

    qp = QuadraticProgram(A, b, C, d, z, P)
    # println(qp)
    sol, val = solve!(qp)           # sol ist das α
    α = sol
    println("α ", α)

    # Berechung von w (Vektor) -> m als Steigung
    w = [0;0]
    for i = 1:k
        w = w + α[i]*y[i]*x[i]
    end
    m = -w[1]/w[2]
    println("w ", w)
    println("m ", m)
    println(typeof(m))

    # Berechnung von b
    sI = []      # in diesem Array sind alle Indizes, für die α echt größer als 0 ist
    for i=1:length(α)      # gehe durch den Spaltenvektor α
        if α[i] > 10^(-5)*norm(α)    # wenn der Wert für α echt größer als 0, dann füge den Index an dem dieser Wert steht in sI ein
            push!(sI, i)
        end
    end
    println("sI: ",sI)

    outer_sum = 0
    Z = length(sI)
    if Z == 0
        b = 0
    else
        for i ∈ sI    # berechne die äußere Summenformel
            inner_sum = 0
            # println("i: ",i)
            for j ∈ sI    # berechne die innere Summenformel
                # println("j: ",j)
                inner_sum += α[j]*y[j]*x'[j]*x[i]        # x' ist die Transponierte von x
            end        
            outer_sum += (y[i] - inner_sum)
        end
        b = 1/Z * outer_sum
    end

    # if isnan(b)
    #     b = 0
    # end
    println("b ", b)
    println("w[2] ", w[2])

    py"""
    import numpy as np
    import matplotlib
    matplotlib.use('qtagg')
    import matplotlib.pyplot as plt

    def gerade(w, x, b):
        if b is None:
            b = 0
        if w is None:
            w = 0
        res = w * x - b
        return res

    def visualize(w, b, punkte, beispiel):
        # Punkte: Matrix: Zeilen für einzelnen Punkt: Erste Zahl für x, zweite für y, dritte für Seite der Gerade → Farbe
        # nächste Punkte: Aufbau wie punkte; enthält nur Punkte, die geringsten Abstand zur Gerade haben;
        # (nächste Punkte auch in punkte)
        # abstand: Abstand von der Gerade zu den Punkten die am nächsten an der Gerade liegen

        # Unterscheidung in Punkte in links und rechts für Farbgebung
        punkte_links = [x for idx, x in enumerate(punkte) if punkte[idx][2] == 1]
        punkte_rechts = [x for idx, x in enumerate(punkte) if punkte[idx][2] == -1]
        # Berechnung von Grenzwerten für die Darstellung von Achsen
        min_y = min(min(i[1] for i in punkte_links), min(i[1] for i in punkte_rechts))
        max_y = max(max(i[1] for i in punkte_links), max(i[1] for i in punkte_rechts))
        # Hinzufügen von Abstandsrändern als Anteil von der Gesamtlänge (15 % auf beiden Seiten)
        y_dif = max_y - min_y
        min_y = min_y - (y_dif * 3 / 20)
        max_y = max_y + (y_dif * 3 / 20)

        min_x = min(min(i[0] for i in punkte_links), min(i[0] for i in punkte_rechts))
        max_x = max(max(i[0] for i in punkte_links), max(i[0] for i in punkte_rechts))
        x_dif = max_x - min_x  # Punkte_Linien_Dicke
        min_x = min_x - (x_dif * 3 / 20)
        max_x = max_x + (x_dif * 3 / 20)
        # y_dif = max_y - min_y  (wird mehr nicht gebraucht)
        # x_dif = max_x - min_x  # Punkte_Linien_Dicke

        print("w[0]:", w[0])
        print("w[1]:", w[1])
        print("b:", b)
        print("w:", -w[0]/w[1])
        print("b/w[1]:", b/w[1])

        # Ploten der Punkte und der Geraden
        plt.figure(figsize=(5, 5))
        x = np.arange(min_x - 2, max_x + 3)
        # x = np.arange(-10**6, 10**6)
        vgerade = np.vectorize(gerade)
        plt.plot(x, vgerade((-w[0]/w[1]), x, (b/w[1])), color='tomato', linewidth=2)  # Teilgerade

        # nächste Punkte berechnen  
        # print([punkt for punkt in punkte])
        for punkt in punkte:
            y_linke_gerade = gerade(round((-w[0]/w[1]), 2), (punkt[0]), round((((b-1)/w[1])), 2))
            y_rechte_gerade = gerade(round((-w[0]/w[1]), 2), (punkt[0]), round((((b+1)/w[1])), 2))
            p_gerade_gleich = False
            if (punkt[1] == y_linke_gerade or punkt[1] == y_rechte_gerade):
                p_gerade_gleich = True
            print("Punkte x: {}, y: {}; y Wert linke Gerade: {}, y Wert rechte Gerade: {} {}".format(punkt[0], punkt[1], y_linke_gerade, y_rechte_gerade, p_gerade_gleich))


        naechste_punkte = [punkt for punkt in punkte if (gerade(round((-w[0]/w[1]), 2), (punkt[0]), round((((b+1)/w[1])), 2)) == round(punkt[1], 2)) or (
                gerade(round((-w[0]/w[1]), 2), (punkt[0]), round((((b-1)/w[1])), 2)) == round(punkt[1], 2))]

        # naechste_punkte = [punkt for punkt in punkte if (gerade(round((-w[0]/w[1]), 1), (punkt[0]), round((((b+1)/w[1])), 1)) == round(punkt[1], 1)) or (
        #         gerade(round((-w[0]/w[1]), 1), (punkt[0]), round((((b-1)/w[1])), 1)) == round(punkt[1], 1))]
        print("naechste_punkte:", naechste_punkte)

        plt.plot(x, vgerade((-w[0]/w[1]), x, ((b-1)/w[1])), color='grey', linestyle='--', alpha=0.5)  # linke Grenzgerade
        plt.plot(x, vgerade((-w[0]/w[1]), x, ((b+1)/w[1])), color='grey', linestyle='--', alpha=0.5)  # rechte Grenzgerade
        # plt.plot(x, vgerade(round((-w[0]/w[1]), 2), np.around(x, 2), round(((b-1)/w[1]), 2)), color='grey', linestyle='--', alpha=0.5)  # linke Grenzgerade
        # plt.plot(x, vgerade((-w[0]/w[1]), x, ((b-1)/w[1])), color='grey', linestyle='--', alpha=0.5)  # linke Grenzgerade
        # plt.plot(x, vgerade((-w[0]/w[1]), x, ((b-1)/w[1])), color='grey', linestyle='--', alpha=0.5)  # linke Grenzgerade
        # plt.plot(np.around(x, 2), vgerade(round((-w[0]/w[1]), 2), np.around(x, 2), round(((b+1)/w[1]), 2)), color='grey', linestyle='--', alpha=0.5)  # rechte Grenzgerade
        # plt.plot(np.around(x, 2), vgerade(round((-w[0]/w[1]), 2), np.around(x, 2), round(((b-1)/w[1]), 2)), color='grey', linestyle='--', alpha=0.5)  # rechte Grenzgerade
        # plt.plot(np.around(x, 2), np.around(vgerade((-w[0]/w[1]), x, ((b-1)/w[1])), 2), color='grey', linestyle='--', alpha=0.5)  # linke Grenzgerade
        plt.fill_between(x, vgerade((-w[0]/w[1]), x, ((b+1)/w[1])), vgerade((-w[0]/w[1]), x, ((b-1)/w[1])), edgecolor='none',
                        color='grey', alpha=0.1)  # Fläche zwischen Geraden, Argumente: linke, mittel und rechte Gerade

        # Plotten der Punkte aus der jeweiligen Liste in der einer gewählten Farbe
        # Hervorhebung der am naechsten an der Gerade liegenden Punkte mit einem Kreis
        for x in naechste_punkte:
            plt.scatter(x[0], x[1], color='none', s=250, edgecolors='black', alpha=0.7)
        for x in punkte_links:
            plt.scatter(x[0], x[1], color='teal', linewidth=3)
        for x in punkte_rechts:
            plt.scatter(x[0], x[1], color='yellowgreen', linewidth=3)
        # Unterscheidung Vorzeichen von b bei Gerade
        b_in_gerade = round(b/w[1], 2)
        if b_in_gerade < 0:
            b_in_gerade = ' - ' + str(abs(b_in_gerade))
        elif b_in_gerade > 0:
            b_in_gerade = ' + ' + str(b_in_gerade)
        elif b_in_gerade == 0:
            b_in_gerade = ''

        # Titel
        plt.title(label='Geradengleichung: g(x) = {}x{}\n{}'.format(round((-w[0]/w[1]), 2), b_in_gerade, str(beispiel)), size=16)
        plt.xlim(min_x, max_x)
        plt.ylim(min_y, max_y)

        # plt.xlim(min(min_x, min_y), min(max_x, max_y))
        # plt.ylim(max(min_x, min_y), max(max_x, max_y))
        plt.show()

    visualize($w, $b, $punkte, $beispiel) 
    """
    # py"visualize"(m, 0, punkte, 1) (alternativ)
end

# alle Tests
# Testdateien: "Beispiel...txt"
for beispiel in glob("Beispiel*.txt")
    svm(beispiel)
end

# einzelne Tests:
# svm("Beispiel15.txt")
