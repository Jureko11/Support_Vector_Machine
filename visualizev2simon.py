import numpy as np
import matplotlib.pyplot as plt
import pprint


def gerade(w, x, b):
    res = w * x - b
    return res


def visualize(w, b, punkte, abstand):
    # Punkte: Matrix: Zeilen für einzelnen Punkt: Erste Zahl für x, zweite für y, dritte für Seite der Gerade --> Farbe
    # abstand: Abstand von der Gerade zur den Punkten die am nächsten an der Gerade liegen
    punkte_links = [x for idx, x in enumerate(punkte) if punkte[idx][2] == 1]
    punkte_rechts = [x for idx, x in enumerate(punkte) if punkte[idx][2] == -1]
    pprint.pprint("punkte_links " + str(punkte_links))
    pprint.pprint("punkte_rechts " + str(punkte_rechts))
    min_y = min(min(i[1] for i in punkte_links), min(i[1] for i in punkte_rechts)) - 0.5
    max_y = max(max(i[1] for i in punkte_links), max(i[1] for i in punkte_rechts)) + 0.5
    for i in punkte_links:
        print(i[0])
    print("\n")
    for i in punkte_rechts:
        print(i[0])
    print("\n")

    min_x = min([i[0] for i in punkte_links]) - 0.5
    max_x = max([i[0] for i in punkte_rechts]) + 0.5
    print("min_x {}".format(min_x))
    print("max_x {}".format(max_x))
    x = np.arange(min_x-2, max_x+3)
    y_dif = max_y - min_y
    x_dif = max_x - min_x  # Punkte_Linien_Dicke
    vgerade = np.vectorize(gerade)
    plt.plot(x, vgerade(w, x, b), color='tomato', linewidth=max(x_dif-5, 2))
    plt.plot(x, vgerade(w, x, b+abstand), color='grey', linestyle='--', alpha=0.5)
    plt.plot(x, vgerade(w, x, b-abstand), color='grey', linestyle='--', alpha=0.5)
    plt.fill_between(vgerade(w, x, b), vgerade(w, x, b+abstand), vgerade(w, x, b-abstand), edgecolor='none',
                     color='grey', alpha=0.1)  # linke Gerade, Mittellinie, rechte Gerade
    for x in punkte_links:
        plt.scatter(x[0], x[1], color='teal', linewidth=max(x_dif-3, 3))
    for x in punkte_rechts:
        plt.scatter(x[0], x[1], color='yellowgreen', linewidth=max(x_dif-3, 3))
    # plt.scatter(punkte_rechts)
    # # for punkt in punkte:
    # plt.figure(figsize=(x_dif, x_dif))
    plt.axis('equal')
    plt.xlim(min_x, max_x)
    plt.ylim(min_y, max_y)
    plt.title(label='Geradengleichung: {} * x - {}'.format(w, b), size=16)

    plt.show()


punkte = \
    [[2.0, 1.0, -1],
     [4.0, 1.0, -1],
     [4.0, 3.0, -1],
     [1.0, 2.0, 1],
     [1.0, 4.0, 1],
     [3.0, 4.0, 1]]

visualize(1, 0, punkte, 1)
