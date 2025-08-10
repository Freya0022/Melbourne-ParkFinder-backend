import { SecretsManagerClient, GetSecretValueCommand } from "@aws-sdk/client-secrets-manager";

const REGION = process.env.AWS_REGION || "ap-southeast-2";
const SECRET_ID = process.env.RDS_SECRET_ID || "prod/rds/melbourne-parkfinder";

const client = new SecretsManagerClient({ region: REGION });

type DbSecret = {
  host: string;
  username: string;
  password: string;
  dbname: string;
  port?: number;
};

let cached: DbSecret | null = null;

export async function getDbSecret(): Promise<DbSecret> {
  if (cached) return cached;

  const resp = await client.send(new GetSecretValueCommand({ SecretId: SECRET_ID }));
  if (!resp.SecretString) throw new Error("No SecretString");

  cached = JSON.parse(resp.SecretString) as DbSecret;
  return cached;
}