from math import cos, sin


def polar_to_cartesian(r, theta) -> tuple[float, float]:
    return r * cos(theta), r * sin(theta)
