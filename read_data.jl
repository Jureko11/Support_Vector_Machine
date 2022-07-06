# Programmierprojekt Support Vector Machine (SVM)
# Entwickler: Jonas Dieckow, Jurek Holler, Simon Dückers
# Diese Datei liest die Daten ein und erzeugt die benötigten Tupel

# Das Format der Daten ist das Folgende: In jeder Zeile der einzulesenden Datei befinden sich
# drei Zahlen. Die ersten zwei sind Floating Points mit den Koordinaten von xi, die letzte
# Zahl ist −1 oder +1.
# erster und zweiter Float gibt Vektor für die ersten Stelle im Tupel
# Int an der dritten Stelle wird an zweite Stelle des Tupels geschrieben

function read_data:
    io = open("Beispiel.txt", "r")
    data = readlines(io)
    for line in eachline("Beispiel.txt")
        println(line)
    end
    close(io)
end