import { Expo } from 'expo-server-sdk';

const expo = new Expo({ accessToken: process.env.EXPO_ACCESS_TOKEN });

export const sendPushNotification = async (tokens: string[], title: string, body: string, data: any = {}) => {
  const messages = tokens
    .filter(token => Expo.isExpoPushToken(token))
    .map(token => ({
      to: token,
      sound: 'default',
      title,
      body,
      data,
    }));

  const chunks = expo.chunkPushNotifications(messages as any);
  const tickets = [];

  for (const chunk of chunks) {
    try {
      const ticketChunk = await expo.sendPushNotificationsAsync(chunk as any);
      tickets.push(...ticketChunk);
      console.log(ticketChunk)
    } catch (error) {
      console.error('Error sending push notifications:', error);
    }
  }
  return tickets;
};
