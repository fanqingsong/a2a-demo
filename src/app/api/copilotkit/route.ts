import {
  CopilotRuntime,
  copilotRuntimeNextJSAppRouterEndpoint,
  ExperimentalEmptyAdapter,
} from "@copilotkit/runtime";
import { NextRequest } from "next/server";
import { A2AClientAgent } from "./a2a";
import { openai } from "@ai-sdk/openai";

const runtime = new CopilotRuntime({
  agents: {
    a2a_chat: new A2AClientAgent({
      model: openai("gpt-4o", { parallelToolCalls: false }),
      agentUrls: [
        "http://127.0.0.1:9999",
        "http://127.0.0.1:9998",
        "http://127.0.0.1:9997",
      ],
      instructions: `
          You are an HR agent. You are responsible for hiring employees and other typical HR tasks.

          It's very important to contact all the departments necessary to complete the task.
          For example, to hire an employee, you must contact the Finance and IT departments and to find a table at buildings management.

          DO NOT FORGET TO COMMUNICATE BACK TO THE RELEVANT AGENT IF MAKING A TOOL CALL ON BEHALF OF ANOTHER AGENT!!!
   `,
    }),
  },
});

export const POST = async (req: NextRequest) => {
  const { handleRequest } = copilotRuntimeNextJSAppRouterEndpoint({
    runtime,
    serviceAdapter: new ExperimentalEmptyAdapter(),
    endpoint: req.nextUrl.pathname,
  });

  return handleRequest(req);
};
