import swaggerJsdoc from 'swagger-jsdoc';
import env from './env';

const options: swaggerJsdoc.Options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Warungin API',
      version: '1.1.0',
      description: 'Multi-Tenant System API Documentation',
      contact: {
        name: 'Warungin',
      },
    },
    servers: [
      {
        url: env.BACKEND_URL,
        description: 'Development server',
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
    },
    security: [
      {
        bearerAuth: [],
      },
    ],
  },
  apis: ['./src/routes/**/*.ts', './src/**/*.ts'],
};

export const swaggerSpec = swaggerJsdoc(options);

