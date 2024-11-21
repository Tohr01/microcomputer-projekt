# Prime Spiral visualization
Visualize the prime spiral using raylib.<br>
Note: Currently displays _all_ natural numbers from 1 to 100000 as placeholder until Raspberry pico or arduino communication is implemented.

## Install
Create virtualenv and run:
```bash
pip3 install -r requirements.txt
```
Note: If raylib fails to install run `brew install raylib` beforehand if you are on macOS or follow the instructions on the [raylib python installation instructions](https://electronstudio.github.io/raylib-python-cffi/README.html#installation).

## Running
```bash
python3 visualize.py
```

## Controls
- Pan and zoom with mouse drag and mouse wheel
- Reset with spacebar