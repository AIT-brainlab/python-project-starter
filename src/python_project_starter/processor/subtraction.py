from typing import Annotated
import typer
from typer import Typer
import logging

cli = Typer()
@cli.command()
def subtraction(a:Annotated[int, typer.Argument(help="First number argument")], 
        b:Annotated[int, typer.Argument(help="Second number argument")]):
    """
    This is the another default command.
    It will perform a subtraction between `a` and `b`.
    """
    logging.debug("Calling `subtraction`")
    print(f"The calculation is {a-b}.")
