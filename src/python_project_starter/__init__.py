import python_project_starter.utils.logger

import typer
import os
_PROJECT_NAME = os.environ["PROJECT_NAME"]
cli = typer.Typer()

@cli.command()
def home():
    """
    This is the default command
    """
    print(f"Welcome to {_PROJECT_NAME}")

@cli.command()
def home2():
    """
    This is the default command
    """
    print(f"Welcome to {_PROJECT_NAME} na ja")

# logging.info("App start")
