import { readConfig, tokenVerifier } from "./auth.ts";
import { createHandler } from "./server.ts";
const config = readConfig();
Deno.serve(createHandler(config, tokenVerifier(config)));
