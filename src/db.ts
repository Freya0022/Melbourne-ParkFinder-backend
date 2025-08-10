import mysql from "mysql2/promise";
import dotenv from "dotenv";

dotenv.config();

import { SecretsManagerClient, GetSecretValueCommand } from "@aws-sdk/client-secrets-manager";

type DbConfig = {
  host: string;
  user: string;
  password: string;
  database: string;
  port?: number;
};

async function loadDbConfig(): Promise<DbConfig> {
  const region = process.env.AWS_REGION || "ap-southeast-2";
  const secretId =
    process.env.RDS_SECRET_ID || "prod/rds/melbourne-parkfinder";

  const client = new SecretsManagerClient({ region });
  const resp = await client.send(
    new GetSecretValueCommand({ SecretId: secretId })
  );

  if (!resp.SecretString) {
    throw new Error(`"${secretId}" no SecretString`);
  }

  const secret = JSON.parse(resp.SecretString) as {
    host: string;
    username: string;
    password: string;
    dbname: string;
    port?: number;
  };

  return {
    host: secret.host,
    user: secret.username,
    password: secret.password,
    database: secret.dbname,
    port: secret.port ?? 3306,
  };
}

let poolPromise: Promise<mysql.Pool> | null = null;

export async function getDb(): Promise<mysql.Pool> {
  if (!poolPromise) {
    poolPromise = (async () => {
      const cfg = await loadDbConfig();
      return mysql.createPool({
        host: cfg.host,
        user: cfg.user,
        password: cfg.password,
        database: cfg.database,
        port: cfg.port ?? 3306,
        connectionLimit: 10,
        waitForConnections: true,
        queueLimit: 0,
      });
    })();
  }
  return poolPromise;
}