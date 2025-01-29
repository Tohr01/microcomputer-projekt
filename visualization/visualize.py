from pyray import *
from re import compile, match
from util import polar_to_cartesian

START_ADDRESS = 1000
START_PRIME = 2
END_PRIME = 30001
RAM_PATTERN = compile(r'^(\d+)\s(\d+)\s*$')

calculated_primes = []
with open('../hardware/ram.dat', 'r') as fh:
    lines = fh.readlines()
    assert len(lines) >= START_ADDRESS
    for line in lines[START_ADDRESS:]:

        match = RAM_PATTERN.match(line)
        if match is not None:
            addr = int(match.group(1))
            val = int(match.group(2), 2)
    
            if addr >= START_ADDRESS and val != 0:
                calculated_primes.append(val)
            continue
        break

calculated_primes_count = len(calculated_primes)
actual_primes_count = len([candidate for candidate in range(START_PRIME, END_PRIME + 1) if all(candidate % y != 0 for y in range(2, int(candidate ** 0.5) + 1))])

WIN_WIDTH = 1080
WIN_HEIGHT = 1080

RADIUS = 40
RADIUS_DIVISOR = 300
DIST_MUL = 2

# Initialization
init_window(1920, 1080, 'Prime Spiral')
camera = Camera2D((WIN_WIDTH / 2, WIN_HEIGHT / 2), (0, 0), 0, 1)

prev_mouse_pos = get_mouse_position()

set_target_fps(60)

max_prime = max(calculated_primes)
min_prime = min(calculated_primes)

while not window_should_close():
    if get_char_pressed() == 32: # Space bar
        camera.zoom = 1
        camera.target = (0,0)
    mouse_delta = get_mouse_wheel_move()
    new_zoom = camera.zoom + mouse_delta * 0.1
    if new_zoom <= 0:
        new_zoom = 0.001
    camera.zoom = new_zoom

    mouse_pos = get_mouse_position()
    delta = Vector2(prev_mouse_pos.x - mouse_pos.x, prev_mouse_pos.y - mouse_pos.y)
    prev_mouse_pos = mouse_pos

    if is_mouse_button_down(0):
        camera.target = get_screen_to_world_2d(Vector2(camera.offset.x + delta.x, camera.offset.y + delta.y), camera)

    begin_drawing()
    begin_mode_2d(camera)
    clear_background(BLACK)
    for prime in calculated_primes:
        x, y = polar_to_cartesian(prime * DIST_MUL, prime * DIST_MUL)
        draw_circle(int(x), int(y), prime // RADIUS_DIVISOR + 20, WHITE)
    end_mode_2d()
    draw_rectangle(0, 0, 580, 180, BLACK)
    draw_text(f'Primes from {START_PRIME} - {END_PRIME}', 25, 20, 40, WHITE)
    draw_text(f'Calculated primes count: {calculated_primes_count}', 25, 80, 30, WHITE)
    draw_text(f'Actual primes count: {actual_primes_count}', 25, 120, 30, WHITE)
    end_drawing()
close_window()
