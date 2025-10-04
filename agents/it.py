import os
import uvicorn

from a2a.server.apps import A2AStarletteApplication
from a2a.server.request_handlers import DefaultRequestHandler
from a2a.server.tasks import InMemoryTaskStore
from a2a.types import (
    AgentCapabilities,
    AgentCard,
    AgentSkill,
)
from a2a.server.agent_execution import AgentExecutor, RequestContext
from a2a.server.events import EventQueue
from a2a.utils import new_agent_text_message
from a2a.types import (
    Message
)
import openai

PORT = os.getenv("PORT", "9998")
URL = os.getenv("URL", f"http://localhost:{PORT}")

# 配置OpenAI客户端以支持Azure OpenAI
def get_openai_client():
    """获取配置好的OpenAI客户端"""
    # 检查是否使用Azure OpenAI
    azure_api_key = os.getenv("AZURE_OPENAI_API_KEY")
    azure_endpoint = os.getenv("AZURE_OPENAI_ENDPOINT")
    azure_api_version = os.getenv("AZURE_OPENAI_API_VERSION", "2024-02-15-preview")
    azure_deployment = os.getenv("AZURE_OPENAI_DEPLOYMENT_NAME")
    
    if azure_api_key and azure_endpoint:
        # 使用Azure OpenAI
        return openai.AzureOpenAI(
            api_key=azure_api_key,
            api_version=azure_api_version,
            azure_endpoint=azure_endpoint
        ), azure_deployment or "gpt-4o"
    else:
        # 使用标准OpenAI
        return openai.OpenAI(), "gpt-4o"

class ITAgent:
    """IT Agent."""

    async def invoke(self, message: Message) -> str:
        client, model = get_openai_client()
        
        response = client.chat.completions.create(
            model=model,
            messages=[
                {"role": "developer", "content": "You are simulating an agent in the IT department of a company, as part of a demo. You simulate being in charge of the IT infrastructure, and given request you will respond pretending to operate that system. But you will always simulate successfully carrying out the request. Never say the steps that need to be done to fulfill a request: REMEMBER: you are SIMULATING to be in charge of the system and you pretend to do any task yourself. If you set up a new account, let the user know the name @acme.com. That's what the demo is about ;)"},
                {"role": "user", "content": message.parts[0].root.text}
            ]
        )
        return response.choices[0].message.content

skill = AgentSkill(
    id='it_agent',
    name='The IT Agent is in charge of the IT infrastructure',
    description='The IT Agent is in charge of the IT infrastructure',
    tags=['it', 'infrastructure'],
    examples=[
        'I want to purchase a new laptop for the office',
        'I want to set up a new email account for a new employee'
    ],
)

public_agent_card = AgentCard(
    name='IT Agent',
    description='The IT Agent is in charge of the IT infrastructure. Set up new accounts, provision new devices, etc.',
    url=f'{URL}/',
    version='1.0.0',
    defaultInputModes=['text'],
    defaultOutputModes=['text'],
    capabilities=AgentCapabilities(streaming=True),
    skills=[skill],  # Only the basic skill for the public card
    supportsAuthenticatedExtendedCard=True,
)


class ITAgentExecutor(AgentExecutor):
    """IT Agent Implementation."""

    def __init__(self):
        self.agent = ITAgent()

    async def execute(
        self,
        context: RequestContext,
        event_queue: EventQueue,
    ) -> None:
        result = await self.agent.invoke(context.message)
        await event_queue.enqueue_event(new_agent_text_message(result))

    async def cancel(
        self, context: RequestContext, event_queue: EventQueue
    ) -> None:
        raise Exception('cancel not supported')


def main():
    request_handler = DefaultRequestHandler(
        agent_executor=ITAgentExecutor(),
        task_store=InMemoryTaskStore(),
    )

    server = A2AStarletteApplication(
        agent_card=public_agent_card,
        http_handler=request_handler,
        extended_agent_card=public_agent_card,
    )

    uvicorn.run(server.build(), host='0.0.0.0', port=int(PORT))

if __name__ == '__main__':
    main()
