# We do this to load the logger (which will config the logger for this module)
import python_project_starter.utils.logger # type: ignore
from typer import Typer
from python_project_starter.cli import cli as main_cli# type: ignore


# This is how you do logging
import logging
logging.debug("App start")

# This is how can we structure the cli
cli = Typer()
cli.add_typer(main_cli)


