import { KeyValue } from './types';
import { many, single } from '../db';
import { isJSON } from '../utils/json';

export interface Forward {
  id: number;
  webhookId: number;
  userId: number;
  createdAt: Date;
  url: string;
  method: string;
  statusCode: number;
  success: boolean;
  headers: KeyValue[];
  query: KeyValue[];
  contentType?: string;
  body?: string;
}

const include =
  'id, created_at, webhook_id, user_id, url, method, status_code, headers, query, content_type, body';

const map = (entity: any): Forward | null =>
  entity === null
    ? null
    : {
        id: entity.id,
        webhookId: entity.webhook_id,
        userId: entity.user_id,
        createdAt: entity.created_at,
        url: entity.url,
        method: entity.method,
        statusCode: entity.status_code,
        success:
          entity.status_code >= 200 && entity.status_code < 300,
        headers: Object.entries(entity.headers).map(
          o => ({ key: o[0], value: o[1] } as KeyValue),
        ),
        query: Object.entries(entity.query).map(
          o => ({ key: o[0], value: o[1] } as KeyValue),
        ),
        contentType: entity.content_type,
        body: entity.body,
      };

export const findByKeys = async (keys: { webhookId: number }[]) => {
  const forwards = await many(
    `
      SELECT ${include}
      FROM forwards
      WHERE
      ${keys.reduce((acc, cur) => {
        if (!Number.isInteger(cur.webhookId))
          throw new Error('Invalid operation.'); // Guard against SQL injection

        return `${acc} OR webhook_id = ${cur.webhookId}`;
      }, '1 = 0')}
      ORDER BY id DESC
    `,
  );

  return keys.map(key =>
    forwards
      .filter(forward => forward.webhook_id === key.webhookId)
      .map(e => map(e)),
  );
};

export const insert = async (
  webhookId: number,
  userId: number,
  url: string,
  method: string,
  statusCode: number,
  headers: object,
  query: object,
  contentType: string | null | undefined,
  body?: string,
) =>
  map(
    await single(
      `
        INSERT INTO forwards
          (created_at, webhook_id, user_id, url, method, status_code, headers, query, content_type, body, body_json)
        VALUES
          (current_timestamp, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
        RETURNING ${include}
      `,
      [
        webhookId,
        userId,
        url,
        method,
        statusCode,
        headers,
        query,
        contentType,
        body,
        contentType === 'application/json' && isJSON(body)
          ? body
          : null, // Don't JSON.parse() before inserting, as that'll throw an exception for JSON arrays: https://github.com/brianc/node-postgres/issues/442
      ],
    ),
  );
