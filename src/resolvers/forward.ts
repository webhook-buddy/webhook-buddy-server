import { combineResolvers } from 'graphql-resolvers';
import { isAuthenticated, isWebhookAllowed } from './authorization';
import { insert } from '../models/forward';
import { extractContentType } from '../utils/http';
import { findById } from '../models/webhook';
import { KeyValue } from '../models/types';
import pubSub, { EVENTS } from '../subscriptions';
import { findByWebhookId } from '../models/endpoint';

type AddForwardInput = {
  webhookId: number;
  url: string;
  method: string;
  statusCode: number;
  headers: KeyValue[];
  query: KeyValue[];
  body: string;
};

const keyValueToObject = (keyValues: KeyValue[]) =>
  keyValues.reduce((acc, cur) => {
    acc[cur.key] = cur.value;
    return acc;
  }, {});

export default {
  Mutation: {
    addForward: combineResolvers(
      isAuthenticated,
      isWebhookAllowed,
      async (_, { input }: { input: AddForwardInput }, { me }) => {
        const forward = await insert(
          input.webhookId,
          me.id,
          input.url,
          input.method,
          input.statusCode,
          keyValueToObject(input.headers),
          keyValueToObject(input.query),
          extractContentType(keyValueToObject(input.headers)),
          input.body,
        );

        const webhook = await findById(forward.webhookId, me.id);
        const endpoint = await findByWebhookId(webhook.id);

        pubSub.publish(EVENTS.WEBHOOK.UPDATED, {
          webhookUpdated: {
            webhook,
            endpoint,
          },
        });

        return {
          forward,
          webhook,
        };
      },
    ),
  },
};
