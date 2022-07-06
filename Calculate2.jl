using LinearAlgebra
using CSV
using DataFrames
using QPDAS
using PyCall

println("\nGeht los!\n")

# Einlesen der Daten aus den Dateien und speichern dieser in einer passenden Form
# values_dataframe = DataFrame(CSV.read("D:\\_Simon\\_Studium\\Drive\\GoodNotes\\CoMa\\Programmierprojekt Support Vector Machine\\Beispiel1.txt", DataFrame, header=[:x1, :x2, :y]))
values_dataframe = DataFrame(CSV.read("D:\\Users\\Simon\\tubcloud\\CoMa\\Programmierprojekt Support Vector Machine\\Beispiel2.txt", DataFrame, header=[:x1, :x2, :y]))

# println("values_dataframe", values_dataframe)
d = values_dataframe[:, 1:2]
# println("d ", d)


x = [[d[i,1], d[i, 2]] for i in 1:nrow(values_dataframe)]
punkte = [[values_dataframe[i,1], values_dataframe[i, 2], values_dataframe[i, 3]] for i in 1:nrow(values_dataframe)]
# println("x ", x)
println("punkte ", punkte)
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
P = M * 0.001+Matrix{Float64}(I,k,k)

z = -ones(k)
A = ones(k,k) .* y'
C = -Matrix{Float64}(I,k,k)
b = zeros(k)
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
m = -w[2]/w[1]
println("w ", w)
println("m ", m)
println(typeof(m))

# Berechnung von b und n
sI = []      # in diesem Array sind alle Indizes, für die α echt größer als 0 ist
for i=1:length(α)      # gehe durch den Spaltenvektor α
    if α[i] > 0    # wenn der Wert für α echt größer als 0, dann füge den Index an dem dieser Wert steht in sI ein
        push!(sI, i)
    end
end

inner_sum = 0
outer_sum = 0
Z = length(sI)
for i ∈ sI    # berechne die äußere Summenformel
    for j ∈ sI    # berechne die innere Summenformel
        inner_sum = inner_sum + α[j]*y[j]*x'[j]*x[i]        # x' ist die Transponierte von x
    end        
    outer_sum = outer_sum + y[i] - inner_sum
end
b = 1/Z * outer_sum
n = b/w[2]
println("b ", b)
println("w[2] ", w[2])
println("n ", n)


# Abstand
abstand = 1/norm(w)
println("abstand ", abstand)
println("norm(w) ", norm(w))


# py"""
# import sys
# sys.path.insert(0, "./visualizev6simon")
# """
# visualize = pyimport("visualizev6simon")["visualize"]

# # D:\\_Simon\\_Studium\\Drive\\GoodNotes\\CoMa\\Programmierprojekt Support Vector Machine\\visualizev6simon.py

# using PyCall
# pushfirst!(PyVector(pyimport("sys")."./visualizev6simon"), "")
# pyimport("visualizev6simon.py")
# punkte = [[2.0, 1.0, -1],
#      [4.0, 1.0, -1],
#      [4.0, 3.0, -1],
#      [1.0, 2.0, 1],
#      [1.0, 4.0, 1],
#      [3.0, 4.0, 1]]
# visualizev6simon.visualize(1, 0, punkte, 1)

# using PyCall
# plt = pyimport("matplotlib")


using PyCall
using PyPlot
py"""
import numpy as np
import matplotlib
matplotlib.use('qtagg')
import matplotlib.pyplot as plt

def gerade(w, x, b):
    res = w * x - b
    return res


def visualize(w, b, punkte, abstand):
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

    # Ploten der Punkte und der Geraden
    plt.figure(figsize=(5, 5))
    x = np.arange(min_x - 2, max_x + 3)
    vgerade = np.vectorize(gerade)
    plt.plot(x, vgerade(w, x, b), color='tomato', linewidth=2)  # Teilgerade

    # nächste Punkte berechnen
    naechste_punkte = [punkt for punkt in punkte if (gerade(w, (punkt[0]), b + abstand) == punkt[1]) or (
            gerade(w, (punkt[0]), b - abstand) == punkt[1])]

    plt.plot(x, vgerade(w, x, b + abstand), color='grey', linestyle='--', alpha=0.5)  # linke Grenzgerade
    plt.plot(x, vgerade(w, x, b - abstand), color='grey', linestyle='--', alpha=0.5)  # rechte Grenzgerade
    plt.fill_between(x, vgerade(w, x, b + abstand), vgerade(w, x, b - abstand), edgecolor='none',
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
    b_in_gerade = round(b, 2)
    if b_in_gerade < 0:
        b_in_gerade = ' - ' + str(abs(b))
    elif b_in_gerade > 0:
        b_in_gerade = ' + ' + str(b)
    else:
        b_in_gerade = ''

    # Titel
    plt.title(label='Geradengleichung: g(x) = {}x{}'.format(w, b_in_gerade), size=16)
    plt.xlim([min(min_x, min_y), max(max_x, max_y)])
    plt.ylim(min(min_x, min_y), max(max_x, max_y))
    plt.show()

visualize($m, $n, $punkte, $abstand)
"""
# py"visualize"(m, 0, punkte, 1) (alternativ)