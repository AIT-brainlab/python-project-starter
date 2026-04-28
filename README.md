# python-project-starter
This is the template starter for Python project

```
.
|-- .devcontainer/               # Where the development containers are defined
|-- .vscode/                     # Where the vscode related configuration are kept
|-- data                         # ! Where data is kept. All the data are ignored by default.
|   `-- example.csv
|-- docs/                        # ! Where document (design, paper, any for reference) is kept. 
|-- logs/                        # Where logs are kept.
|-- models/                      # ! Where models (weight) should be stored.
|-- notebooks/                   # ! Where jupyter notebook should be stored.
|   `-- 0-starter.ipynb
|-- src/                         # ! Where development modules should be.
|   |-- project                  # Example modules with Brainlab practice.
|       |-- __init__.py
|       |-- cli.py
|       |-- logger.py
|       |-- processor
|       |   |-- __init__.py
|       |   |-- works.py
|       |   `-- works_test.py
|       |-- processor_celery
|       |   |-- __init__.py
|       |   |-- cli.py
|       |   |-- works.py
|       |   `-- works_test.py
|       `-- web
|           |-- __init__.py
|           |-- py.typed
|           |-- router.py
|           `-- templates
|               |-- base.html
|               |-- example.html
|               `-- index.html
|-- .gitignore
|-- .python-version
|-- dev-setup.sh                 # ! run this one when you cloned
|-- LICENSE
|-- local.env.example            # ! copy and create `local.env`
|-- pyproject.toml               # python configuration. You have to change this.
|-- README.md
|-- supervisord.conf             # ! if you want to run multiple processes at the same time, learn this one
`-- uv.lock
```

## How to use this

