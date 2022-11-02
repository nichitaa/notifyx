/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_GATEWAY_HOST_PORT: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
