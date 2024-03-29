import { connection as rawMySqlConnection, db } from "./db";
import {
  organizations,
  domains,
  credentials,
  organizationIpPools,
  servers,
  webhooks,
  httpEndpoints,
  routes,
} from "./schema";
import { randomUUID } from "node:crypto";
import {
  generateDKIMKeyPair,
  generatePublicKey,
  getUniqueDKIMSelector,
  randomAlphaNumeric,
} from "./utils";
import { and, eq, sql } from "drizzle-orm/sql";
import { lookupCNAME, lookupMX, lookupTXT } from "./dns";
import {
  buildDkimRecord,
  buildSpfRecord,
  parseDkim,
  parseSpfIncludes,
} from "./dns/txtParsers";
import { fileURLToPath } from "node:url";
import { readFile } from "node:fs/promises";

export type CreateOrgInput = {
  orgId: number;
  orgPublicId: string;
};

export async function createOrg(input: CreateOrgInput) {
  await db.insert(organizations).values({
    id: input.orgId,
    uuid: randomUUID(),
    name: input.orgPublicId,
    permalink: input.orgPublicId.toLowerCase(),
    ownerId: 1, // There should be only one postal user, thus id should be 1
  });
}

export type AddDomainInput = {
  orgId: number;
  orgPublicId: string;
  domain: string;
};

export async function addDomain(input: AddDomainInput) {
  const { privateKey, publicKey } = await generateDKIMKeyPair();
  const verificationToken = randomAlphaNumeric(32);
  const dkimSelector = await getUniqueDKIMSelector();
  const domainId = randomUUID();

  await db.insert(domains).values({
    uuid: domainId,
    name: input.domain,
    verificationToken,
    verificationMethod: "DNS",
    ownerType: "Organization",
    ownerId: input.orgId,
    dkimPrivateKey: privateKey,
    dkimIdentifierString: dkimSelector,
    createdAt: sql`CURRENT_TIMESTAMP`,
    updatedAt: sql`CURRENT_TIMESTAMP`,
  });
  return {
    dkimSelector,
    dkimPublicKey: publicKey,
    domainId,
  };
}

export type VerifyDomainDNSRecordsOutput = {
  error: string;
  fix: string;
}[];

export async function verifyDomainDNSRecords(
  domainId: string,
  forceReverify: boolean = false
): Promise<VerifyDomainDNSRecordsOutput> {
  const domainInfo = await db.query.domains.findFirst({
    where: eq(domains.uuid, domainId),
  });

  if (!domainInfo) {
    return [{ error: "Domain not found", fix: "Contact support" }];
  }

  const txtRecords = await lookupTXT(domainInfo.name);
  if (!txtRecords.success) {
    return [{ error: txtRecords.error, fix: "Contact support" }];
  }

  if (!domainInfo.verifiedAt || forceReverify) {
    const record = `uninbox-verification ${domainInfo.verificationToken}`;
    const verified = txtRecords.data.includes(record);
    if (verified) {
      await db
        .update(domains)
        .set({
          verifiedAt: sql`CURRENT_TIMESTAMP`,
        })
        .where(eq(domains.uuid, domainId));
    } else {
      return [
        {
          error: "Domain ownership not verified",
          fix: `Add the following TXT record on root (@) of your domain: "${record}"`,
        },
      ];
    }
  }

  const errors: VerifyDomainDNSRecordsOutput = [];

  if (domainInfo.spfStatus !== "OK" || forceReverify) {
    const spfDomains = parseSpfIncludes(
      txtRecords.data.find((_) => _.startsWith("v=spf1")) || ""
    );

    if (!spfDomains) {
      errors.push({
        error: "SPF record not found",
        fix: `Add the following TXT record on root (@) of your domain: ${buildSpfRecord(
          [process.env.SERVER_SPF_DOMAIN!],
          "~all"
        )}`,
      });
      await db
        .update(domains)
        .set({ spfStatus: "Missing", spfError: "SPF record not found" })
        .where(eq(domains.uuid, domainId));
    } else if (!spfDomains.includes.includes(process.env.SERVER_SPF_DOMAIN!)) {
      errors.push({
        error: "SPF record not found",
        fix: `Add the following TXT record on root (@) of your domain: ${buildSpfRecord(
          [process.env.SERVER_SPF_DOMAIN!, ...spfDomains.includes],
          "~all"
        )}`,
      });
      await db
        .update(domains)
        .set({ spfStatus: "Invalid", spfError: "SPF record Invalid" })
        .where(eq(domains.uuid, domainId));
    } else {
      await db
        .update(domains)
        .set({ spfStatus: "OK", spfError: null })
        .where(eq(domains.uuid, domainId));
    }
  }

  if (domainInfo.dkimStatus !== "OK" || forceReverify) {
    const domainKeyRecords = await lookupTXT(
      `postal-${domainInfo.dkimIdentifierString}._domainkey.${domainInfo.name}`
    );
    const publicKey = generatePublicKey(domainInfo.dkimPrivateKey);

    if (!domainKeyRecords.success) {
      errors.push({
        error: "DKIM record not found",
        fix: `Add the following TXT record on postal-${
          domainInfo.dkimIdentifierString
        }._domainkey.${domainInfo.name} : ${buildDkimRecord({
          t: "s",
          h: "sha256",
          p: publicKey,
        })}`,
      });
      await db
        .update(domains)
        .set({ dkimStatus: "Missing", dkimError: "DKIM record not found" })
        .where(eq(domains.uuid, domainId));
    } else {
      const domainKey = parseDkim(
        domainKeyRecords.data.find((_) => _.startsWith("v=DKIM1")) || ""
      );

      if (
        !domainKey ||
        domainKey["h"] !== "sha256" ||
        domainKey["p"] !== publicKey
      ) {
        errors.push({
          error: "DKIM record not found",
          fix: `Add the following TXT record on postal-${
            domainInfo.dkimIdentifierString
          }._domainkey.${domainInfo.name} : ${buildDkimRecord({
            t: "s",
            h: "sha256",
            p: publicKey,
          })}`,
        });
        await db
          .update(domains)
          .set({ dkimStatus: "Invalid", dkimError: "DKIM record Invalid" })
          .where(eq(domains.uuid, domainId));
      } else {
        await db
          .update(domains)
          .set({ dkimStatus: "OK", dkimError: null })
          .where(eq(domains.uuid, domainId));
      }
    }
  }

  if (domainInfo.returnPathStatus !== "OK" || forceReverify) {
    const returnPathCname = await lookupCNAME(`psrp.${domainInfo.name}`);
    if (!returnPathCname.success) {
      errors.push({
        error: "Return-Path CNAME record not found",
        fix: `Add the following CNAME record on psrp.${domainInfo.name} : ${process.env.SERVER_RETURN_PATH_DOMAIN}`,
      });
      await db
        .update(domains)
        .set({
          returnPathStatus: "Missing",
          returnPathError: "Return-Path CNAME record not found",
        })
        .where(eq(domains.uuid, domainId));
    } else if (
      !returnPathCname.data.includes(process.env.SERVER_RETURN_PATH_DOMAIN!)
    ) {
      errors.push({
        error: "Return-Path CNAME record not found",
        fix: `Add the following CNAME record on psrp.${domainInfo.name} : ${process.env.SERVER_RETURN_PATH_DOMAIN}`,
      });
      await db
        .update(domains)
        .set({
          returnPathStatus: "Invalid",
          returnPathError: null,
        })
        .where(eq(domains.uuid, domainId));
    } else {
      await db
        .update(domains)
        .set({ returnPathStatus: "OK", returnPathError: null })
        .where(eq(domains.uuid, domainId));
    }
  }

  if (domainInfo.mxStatus !== "OK" || forceReverify) {
    const mxRecords = await lookupMX(domainInfo.name);
    if (!mxRecords.success) {
      errors.push({
        error: "MX record not found",
        fix: `Add the following MX record on root (@) of your domain with priority 10 : ${process.env.SERVER_MAIL_EXCHANGER_DOMAIN}`,
      });
      await db
        .update(domains)
        .set({ mxStatus: "Missing", mxError: "MX record not found" })
        .where(eq(domains.uuid, domainId));
    } else if (
      !mxRecords.data.find(
        (x) =>
          x.exchange === process.env.SERVER_MAIL_EXCHANGER_DOMAIN &&
          x.priority === 10
      )
    ) {
      errors.push({
        error: "Proper MX record not found",
        fix: `Add the following MX record on root (@) of your domain with priority 10 : "${process.env.SERVER_MAIL_EXCHANGER_DOMAIN}"`,
      });
      await db
        .update(domains)
        .set({ mxStatus: "Invalid", mxError: "MX record Invalid" })
        .where(eq(domains.uuid, domainId));
    } else {
      await db
        .update(domains)
        .set({ mxStatus: "OK", mxError: null })
        .where(eq(domains.uuid, domainId));
    }
  }

  return errors;
}

export type SetMailServerKeyInput = {
  type: "SMTP" | "API";
  publicOrgId: string;
  serverId: number;
  serverPublicId: string;
};

export async function setMailServerKey(input: SetMailServerKeyInput) {
  const key = randomAlphaNumeric(24);
  const uuid = randomUUID();

  await db.update(credentials).set({
    serverId: input.serverId,
    type: input.type,
    createdAt: sql`CURRENT_TIMESTAMP`,
    updatedAt: sql`CURRENT_TIMESTAMP`,
    key: key,
    uuid,
    hold: 0,
    name: input.serverPublicId + input.type === "SMTP" ? "-api" : "-smtp",
  });

  return {
    key,
  };
}

export type SetOrgIpPoolsInput = {
  orgId: number;
  poolIds: number[];
};

export async function setOrgIpPools(input: SetOrgIpPoolsInput) {
  const existingPools = await db.query.organizationIpPools.findMany({
    where: eq(organizationIpPools.organizationId, input.orgId),
  });

  const poolsToAdd = input.poolIds.filter(
    (pool) => !existingPools.some((_) => _.ipPoolId === pool)
  );

  const poolsToRemove = existingPools
    .filter((pool) => !input.poolIds.some((_) => _ === pool.ipPoolId))
    .map((_) => _.ipPoolId!);

  for await (let pool of poolsToAdd) {
    await db.insert(organizationIpPools).values({
      organizationId: input.orgId,
      ipPoolId: pool,
      createdAt: sql`CURRENT_TIMESTAMP`,
      updatedAt: sql`CURRENT_TIMESTAMP`,
    });
  }

  for await (let pool of poolsToRemove) {
    await db
      .delete(organizationIpPools)
      .where(
        and(
          eq(organizationIpPools.organizationId, input.orgId),
          eq(organizationIpPools.ipPoolId, pool)
        )
      );
  }
}

export type SetMailServerConfigInput = {
  serverId: number;
  sendLimit?: number;
  outboundSpamThreshold?: number;
  messageRetentionDays?: number;
  rawMessageRetentionDays?: number;
  rawMessageRetentionSize?: number;
};

export async function setMailServerConfig(input: SetMailServerConfigInput) {
  await db
    .update(servers)
    .set({
      sendLimit: input.sendLimit,
      outboundSpamThreshold: input.outboundSpamThreshold?.toString(),
      messageRetentionDays: input.messageRetentionDays,
      rawMessageRetentionDays: input.rawMessageRetentionDays,
      rawMessageRetentionSize: input.rawMessageRetentionSize,
    })
    .where(eq(servers.id, input.serverId));
}

export type SetMailServerEventWebhookInput = {
  orgId: number;
  serverId: number;
  serverPublicId: string;
  mailBridgeUrl: string;
};

export async function setMailServerEventWebhook(
  input: SetMailServerEventWebhookInput
) {
  const webhookUrl = `${input.mailBridgeUrl}/postal/events/${input.orgId}/${input.serverPublicId}`;
  await db.update(webhooks).set({
    url: webhookUrl,
    name: input.serverPublicId,
    serverId: input.serverId,
    uuid: randomUUID(),
    allEvents: 1,
    enabled: 1,
    createdAt: sql`CURRENT_TIMESTAMP`,
    updatedAt: sql`CURRENT_TIMESTAMP`,
  });
  return { webhookUrl };
}

export type SetMailServerRoutingHttpEndpointInput = {
  orgId: number;
  serverPublicId: string;
  serverId: number;
  endpoint: string;
  mailBridgeUrl: string;
};

export async function setMailServerRoutingHttpEndpoint(
  input: SetMailServerRoutingHttpEndpointInput
) {
  const endpointUrl = `${input.mailBridgeUrl}/postal/mail/inbound/${input.orgId}/${input.serverPublicId}`;
  const uuid = randomUUID();
  await db.insert(httpEndpoints).values({
    name: "uninbox-mail-bridge-http",
    url: endpointUrl,
    encoding: "BodyAsJson",
    format: "Hash",
    stripReplies: 1,
    createdAt: sql`CURRENT_TIMESTAMP`,
    updatedAt: sql`CURRENT_TIMESTAMP`,
    includeAttachments: 1,
    timeout: 30,
    uuid,
  });
  return { endpointUrl };
}

export type SetMailServerRouteForDomainInput = {
  orgId: number;
  domainId: number;
  serverId: number;
  endpointId: number;
  username: string;
};
export async function setMailServerRouteForDomain(
  input: SetMailServerRouteForDomainInput
) {
  const uuid = randomUUID();
  const token = randomAlphaNumeric(8);
  await db.insert(routes).values({
    domainId: input.domainId,
    serverId: input.serverId,
    name: input.username || "*",
    endpointId: input.endpointId,
    endpointType: "HTTPEndpoint",
    spamMode: "Mark",
    createdAt: sql`CURRENT_TIMESTAMP`,
    updatedAt: sql`CURRENT_TIMESTAMP`,
    token,
    mode: "Endpoint",
    uuid,
  });
}

export type AddMailServerInput = {
  orgId: number;
  serverPublicId: string;
  defaultIpPoolId: number;
};

// This function takes time to complete, so use it with caution
export async function addMailServer(input: AddMailServerInput) {
  const uuid = randomUUID();
  const token = randomAlphaNumeric(6);

  const [{ insertId }] = await db.insert(servers).values({
    organizationId: input.orgId,
    name: input.serverPublicId,
    mode: "Live",
    createdAt: sql`CURRENT_TIMESTAMP`,
    updatedAt: sql`CURRENT_TIMESTAMP`,
    permalink: input.serverPublicId,
    token,
    messageRetentionDays: 60,
    ipPoolId: input.defaultIpPoolId,
    uuid,
    rawMessageRetentionDays: 30,
    rawMessageRetentionSize: 2048,
    privacyMode: 0,
    allowSender: 0,
    logSmtpData: 0,
    spamThreshold: "5",
    spamFailureThreshold: "20",
  });

  // Start Vodo Magic
  await rawMySqlConnection.query(
    `CREATE DATABASE \`postal-server-${insertId}\``
  );
  await rawMySqlConnection.query(`USE \`postal-server-${insertId}\``);

  const createMailServerQuery = (
    await readFile(
      fileURLToPath(new URL("./sql/create-mail-server.sql", import.meta.url)),
      "utf-8"
    )
  ).replaceAll("\t", " ");

  await rawMySqlConnection.query(createMailServerQuery);
  await rawMySqlConnection.query(`USE \`postal\``);
  // End Vodo Magic
}
