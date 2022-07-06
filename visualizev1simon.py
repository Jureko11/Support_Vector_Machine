import numpy as np
import matplotlib.pyplot as plt
import pprint


def gerade(w, x, b):
    res = w * x - b
    return res


def visualize(w, b, punkte):
    # Punkte: Matrix: Zeilen für einzelnen Punkt: Erste Zahl für x, zweite für y, dritte für Seite der Gerade --> Farbe
    punkte_links = [x for idx, x in enumerate(punkte) if punkte[idx][2] == 1]
    punkte_rechts = [x for idx, x in enumerate(punkte) if punkte[idx][2] == -1]
    pprint.pprint(punkte_links)
    pprint.pprint(punkte_rechts)
    min_x = min(i[0] for i in punkte_links) - 2
    max_x = max(i[0] for i in punkte_rechts) + 2
    print(min_x)
    print(max_x)
    x = np.arange(min_x, max_x)
    vgerade = np.vectorize(gerade)
    plt.plot(x, vgerade(w, x, b))
    for x in punkte_links:
        plt.scatter(x[0], x[1], color='teal')
    for x in punkte_rechts:
        plt.scatter(x[0], x[1], color='yellowgreen')
    # plt.scatter(punkte_rechts)
    # # for punkt in punkte:
    plt.xlim(min_x, max_x)

    plt.axis('equal')
    plt.show()


punkte = \
    [[2.0, 1.0, -1],
     [4.0, 1.0, -1],
     [4.0, 3.0, -1],
     [1.0, 2.0, 1],
     [1.0, 4.0, 1],
     [3.0, 4.0, 1]]

visualize(2, 3, punkte)
