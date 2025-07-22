import {
  CopilotRuntime,
  copilotRuntimeNextJSAppRouterEndpoint,
  ExperimentalEmptyAdapter,
} from "@copilotkit/runtime";
import { NextRequest } from "next/server";
import { A2AClientAgent } from "./a2a";
import { openai } from "@ai-sdk/openai";

const A2A_URL_1 = process.env.A2A_URL_1 || "http://127.0.0.1:9999";
const A2A_URL_2 = process.env.A2A_URL_2 || "http://127.0.0.1:9998";
const A2A_URL_3 = process.env.A2A_URL_3 || "http://127.0.0.1:9997";

const runtime = new CopilotRuntime({
  agents: {
    a2a_chat: new A2AClientAgent({
      model: openai("gpt-4o", { parallelToolCalls: false }),
      agentUrls: [A2A_URL_1, A2A_URL_2, A2A_URL_3],
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
