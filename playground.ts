import { addDomain } from "./src/functions";

import { verifyDomainDNSRecords } from "./src/functions";

// console.log(
//   await addDomain({
//     domain: "blankparticle.me",
//     orgId: 1,
//     orgPublicId: "test",
//   })
// );

console.log(
  await verifyDomainDNSRecords("52fe0ee8-c432-4f68-8acd-456ae557dff0")
);

// Exit the process
process.exit(0);
