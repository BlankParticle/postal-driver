import { addDomain, setMailServerConfig } from "./src/functions";
import { setOrgIpPools } from "./src/functions";

console.log(
  await addDomain({
    domain: "blankparticle.me",
    orgId: 1,
    orgPublicId: "test",
  })
);

// Exit the process
process.exit(0);
