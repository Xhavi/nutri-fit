import { HttpsError } from 'firebase-functions/https';

export class AppError extends Error {
  constructor(
    readonly code: HttpsError['code'],
    message: string,
    readonly details?: unknown,
  ) {
    super(message);
    this.name = 'AppError';
  }

  toHttpsError(): HttpsError {
    return new HttpsError(this.code, this.message, this.details);
  }
}
