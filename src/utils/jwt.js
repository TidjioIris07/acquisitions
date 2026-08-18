import jwt from 'jsonwebtoken';
import logger from '#config/logger.js';

const JWT_SECRET =
  process.env.JWT_SECRET || 'your_secret_key_please_change_in_production';
const JWT_EXPIRES_IN = '1d';

export const jwtToken = {
  sign(payload) {
    try {
      return jwt.sign(payload, JWT_SECRET, {
        expiresIn: JWT_EXPIRES_IN,
      });
    } catch (error) {
      logger.error('Failed to sign JWT', error);
      throw new Error('Failed to sign JWT', { cause: error });
    }
  },

  verify(token) {
    try {
      return jwt.verify(token, JWT_SECRET);
    } catch (error) {
      logger.error('Failed to verify JWT', error);
      throw new Error('Failed to verify JWT', { cause: error });
    }
  },
};
