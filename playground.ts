import { addMailServer } from "./src/functions";

await addMailServer({
  orgId: 1,
  defaultIpPoolId: 1,
  serverPublicId: "vodo-magic-server",
});

// Exit the process
process.exit(0);
