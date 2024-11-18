from pyray import *

from util import polar_to_cartesian

WIN_WIDTH = 1080
WIN_HEIGHT = 1080

RADIUS = 20
DIST_MUL = 3

# Initialization
init_window(1920, 1080, 'Prime Spiral')
camera = Camera2D((WIN_WIDTH / 2, WIN_HEIGHT / 2), (0, 0), 0, 1)

prev_mouse_pos = get_mouse_position()

set_target_fps(60)

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
    for i in range(1, 100000):
        x, y = polar_to_cartesian(i * DIST_MUL, i * DIST_MUL)
        draw_rectangle(int(x), int(y), RADIUS, RADIUS, WHITE)
    end_mode_2d()
    end_drawing()
close_window()
