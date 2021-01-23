import { withFilter } from 'apollo-server';
import { combineResolvers } from 'graphql-resolvers';
import {
  isAuthenticated,
  isWebhookAllowed,
  isEndpointAllowed,
} from './authorization';
import {
  findById,
  findPage,
  updateRead,
  deleteWebhooks,
  Webhook,
} from '../models/webhook';
import {
  isEndpointUser,
  findById as findEndpointById,
  findByWebhookId as findEndpointByWebhookId,
} from '../models/endpoint';
import pubSub, { EVENTS } from '../subscriptions';
import { User } from '../models/user';

const subscribeWithFilter = (
  subscriptionName: string,
  eventName: string,
) =>
  withFilter(
    // it seems that combineResolvers is not allowed here
    () => pubSub.asyncIterator(eventName),

    async (payload, { endpointId }, { me }) =>
      // only double = (== instead of ===) b/c endpointId is a string while payload.webhookCreated.endpoint.id is a number
      payload[subscriptionName].endpoint.id == endpointId &&
      (await isEndpointUser(endpointId, me.id)),
  );

export default {
  Query: {
    webhook: combineResolvers(
      isAuthenticated,
      isWebhookAllowed,
      async (_, { id }: { id: string }, { me }: { me: User }) =>
        await findById(parseInt(id, 10), me.id),
    ),
    webhooks: combineResolvers(
      isAuthenticated,
      isEndpointAllowed,
      async (
        _,
        {
          endpointId,
          after,
        }: { endpointId: string; after: number | undefined },
        { me }: { me: User },
      ) => await findPage(parseInt(endpointId, 10), me.id, after),
    ),
  },

  Mutation: {
    readWebhook: combineResolvers(
      isAuthenticated,
      isWebhookAllowed,
      async (
        _,
        { input: { id } }: { input: { id: string } },
        { me }: { me: User },
      ) => {
        const webhookId = parseInt(id, 10);

        await updateRead(webhookId, me.id, true);

        const webhook = await findById(webhookId, me.id);
        const endpoint = await findEndpointByWebhookId(webhook.id);

        pubSub.publish(EVENTS.WEBHOOK.UPDATED, {
          webhookUpdated: {
            webhook,
            endpoint,
          },
        });

        return {
          webhook: await findById(webhookId, me.id),
        };
      },
    ),
    deleteWebhooks: combineResolvers(
      isAuthenticated,
      async (
        _,
        {
          input: { webhookIds, endpointId },
        }: { input: { webhookIds: string[]; endpointId: string } },
        { me }: { me: User },
      ) => {
        const affectedRows = await deleteWebhooks(
          me.id,
          parseInt(endpointId, 10),
          webhookIds.map(id => parseInt(id, 10)),
        );

        const endpoint = await findEndpointById(
          parseInt(endpointId, 10),
        );

        pubSub.publish(EVENTS.WEBHOOK.DELETED, {
          webhooksDeleted: {
            affectedRows,
            webhookIds,
            endpoint,
          },
        });

        return {
          affectedRows,
          webhookIds,
        };
      },
    ),
  },

  Subscription: {
    webhookCreated: {
      subscribe: subscribeWithFilter(
        'webhookCreated',
        EVENTS.WEBHOOK.CREATED,
      ),
    },
    webhookUpdated: {
      subscribe: subscribeWithFilter(
        'webhookUpdated',
        EVENTS.WEBHOOK.UPDATED,
      ),
    },
    webhooksDeleted: {
      subscribe: subscribeWithFilter(
        'webhooksDeleted',
        EVENTS.WEBHOOK.DELETED,
      ),
    },
  },

  Webhook: {
    reads: async (webhook: Webhook, _, { loaders }) =>
      await loaders.read.load({
        webhookId: webhook.id,
      }),
    forwards: async (webhook: Webhook, _, { me, loaders }) =>
      await loaders.forward.load({
        webhookId: webhook.id,
      }),
  },
};
