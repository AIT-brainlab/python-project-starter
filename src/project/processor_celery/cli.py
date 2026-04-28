import logging
from typing import Annotated
from typer import Typer
import typer
from celery.result import AsyncResult # type: ignore
from time import sleep

from rich.console import Console
from rich.pretty import pprint

from project.processor_celery.works import queue, addition_job, subtraction_job, multiplier_job
console = Console(highlight=False)
cli = Typer()

@cli.command()
def addition(a:Annotated[int, typer.Argument(help="First number argument")], 
        b:Annotated[int, typer.Argument(help="Second number argument")]):
    """
    It will perform an addition between `a` and `b`.
    """
    logging.debug(f"Calling `addition` from processor_celery")
    job_id:str = addition_job.delay(a,b)
    logging.info(f"celery job_id={job_id}")

@cli.command()
def subtraction(a:Annotated[int, typer.Argument(help="First number argument")], 
        b:Annotated[int, typer.Argument(help="Second number argument")]):
    """
    This is the another default command.
    It will perform a subtraction between `a` and `b`.
    """
    logging.debug(f"Calling `addition` from processor_celery")
    job_id:str = subtraction_job.delay(a,b)
    logging.info(f"celery job_id={job_id}")

@cli.command()
def multiplier(a:Annotated[int, typer.Argument(help="First number argument")], 
        b:Annotated[int, typer.Argument(help="Second number argument")]):
    """
    This multiplier is a part of celery job.
    The job will simulate long processing time with 10 seconds sleep then return with the answer
    """
    logging.debug(f"Calling `addition` from processor_celery")
    job_id:str = multiplier_job.delay(a,b)
    logging.info(f"celery job_id={job_id}")

@cli.command()
def start():
    parameter = [
        'worker',
        '--loglevel=INFO',
        '-n worker1@%h'
    ]
    queue.worker_main(parameter) # type: ignore

@cli.command()
def status(job_id:str):
    job = AsyncResult(job_id, app=queue)
    status = {                 # type: ignore
        "id": job.id,          # type: ignore
        "status": job.status,  # type: ignore
        "state": job.state,    # type: ignore
        "result": job.result   # type: ignore
    }
    pprint(status, expand_all=True)
    
@cli.command()
def cancel(job_id:str):
    job = AsyncResult(job_id, app=queue)
    queue.control.revoke(job_id, terminate=True, signal='SIGKILL') # type: ignore
    sleep(1) # sleep here and the job status has time to process
    status(job_id=job_id)

@cli.command()
def clear(job_id:str):
    job = AsyncResult(job_id, app=queue)
    if(job.status == "STARTED"):
        console.print(f"[red]Job can not `clear` during processing. Please cancel it first.")
        return
    job.forget()
    sleep(1) # sleep here and the job status has time to process
    console.print(f"[green]job_id={job_id} is cleared.")