import { db } from "./db";
import { organizations, domains } from "./schema";
import { randomUUID } from "node:crypto";
import {
  generateDKIMKeyPair,
  generatePublicKey,
  getUniqueDKIMSelector,
  randomAlphaNumeric,
} from "./utils";
import { eq, sql } from "drizzle-orm/sql";
import { lookupCNAME, lookupMX, lookupTXT } from "./dns";
import {
  buildDkimRecord,
  buildSpfRecord,
  parseDkim,
  parseSpfIncludes,
} from "./dns/txtParsers";

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
  domainId: string
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

  if (!domainInfo.verifiedAt) {
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

  if (domainInfo.spfStatus !== "OK") {
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

  if (domainInfo.dkimStatus !== "OK") {
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

  if (domainInfo.returnPathStatus !== "OK") {
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

  if (domainInfo.mxStatus !== "OK") {
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
