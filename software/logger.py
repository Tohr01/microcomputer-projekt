# Create on logger object to log messages singleton
import logging
import sys

logger = logging.getLogger('assembler')
if not logger.hasHandlers():
    logger.setLevel(logging.DEBUG)
    stream_handler = logging.StreamHandler(sys.stdout)

    formatter = logging.Formatter('[%(name)s] - [%(levelname)s] - %(message)s')
    stream_handler.setFormatter(formatter)
    logger.addHandler(stream_handler)


def change_log_level(level: int):
    logger.setLevel(level)
