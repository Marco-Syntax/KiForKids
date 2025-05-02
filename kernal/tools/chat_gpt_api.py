# ./tools/chat_gpt_api.py
# python -m tools.chat_gpt_api
# Summary: A simple tool to interact with the OpenAI Chat GPT API.
from openai import OpenAI
from time import time
from globals.KernalBasics import *

logger = get_logger(__name__)


class ChatGptApi:

    def __init__(self):
        self.client = OpenAI()

    def prompt(self, model="gpt-4.1-nano", prompt="How are you today?", max_tokens=4000):
        start = time()
        messages = [{"role": "user", "content": prompt}]
        response = self.client.chat.completions.create(
            model=model, messages=messages, max_completion_tokens=max_tokens, n=1, top_p=1
        )
        logger.info(f"Time taken for GPT response: {time() - start:.2f} s with model {model} and {max_tokens} tokens")
        return response.choices[0].message.content

    def role_prompt(self, model="gpt-4.1-nano", system_prompt="", user_prompt="", max_tokens=4000):
        start = time()
        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt}
        ]
        response = self.client.chat.completions.create(
            model=model,
            messages=messages,
            max_completion_tokens=max_tokens,
            n=1,
            top_p=1
        )
        logger.info(f"Time taken for GPT response: {time() - start:.2f} s with model {model} and {max_tokens} tokens")
        return response.choices[0].message.content


# For standalone execution
if __name__ == "__main__":
    gpt = ChatGptApi()
    response = gpt.prompt(model="gpt-4o-mini", prompt="How are you today?")
    logger.info(response)
