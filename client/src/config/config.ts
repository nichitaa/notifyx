export const config = {
  APIGatewayBaseUrl: `http://${import.meta.env.VITE_GATEWAY_HOST_PORT}`,
  WSGatewayBaseUrl: `ws://${import.meta.env.VITE_GATEWAY_HOST_PORT}/socket`,
} as const;