## Getting started on mac
Install orbstack, vscode

`pip install -r requirements.txt`
`python agent_kernal.py`

## Remote control?
ngrok http 8203

## Env variables needed for the system
OPENAI_API_KEY

- on mac find shell with $echo $SHELL
- $nano ~/.zshrc or $nano ~/.bash_profile
- add line export OPENAI_API_KEY='your_openai_api_key'
- $source ~/.zshrc
- restart terminal

## Format and code convention:
flake8 --max-line-length=160 --exclude .venv