import type { Plugin } from "@opencode-ai/plugin";

/**
 * LM Studio exposes embedding models through /v1/models as well as chat
 * models. OpenCode's provider schema currently does not accept the
 * "embedding" output modality, so keep those models out of the discovered
 * chat-provider configuration.
 */
export const FilterLmstudioEmbeddings: Plugin = async () => ({
  config: async (config: any) => {
    const models = config?.provider?.lmstudio?.models;
    if (!models || typeof models !== "object") return;

    for (const [key, value] of Object.entries(models)) {
      const model = (value ?? {}) as Record<string, any>;
      const outputModalities = model.modalities?.output;
      const modelId = String(model.id ?? key);

      const isEmbeddingModel =
        (Array.isArray(outputModalities) && outputModalities.includes("embedding")) ||
        /(^|[-_/])embedding([-_/]|$)/i.test(modelId) ||
        /^text-embedding[-_/]/i.test(key);

      if (isEmbeddingModel) {
        delete models[key];
        console.log(`[opencode] Ignoring LM Studio embedding model: ${modelId}`);
      }
    }

    try {
      const configuredBaseURL = String(
        config?.provider?.lmstudio?.options?.baseURL ??
          "http://127.0.0.1:1234/v1",
      ).replace(/\/v1\/?$/, "");
      const response = await fetch(`${configuredBaseURL}/api/v0/models`, {
        signal: AbortSignal.timeout(2000),
      });
      if (!response.ok) return;

      const payload = (await response.json()) as {
        data?: Array<{
          id?: string;
          state?: string;
          loaded_context_length?: number;
        }>;
      };

      for (const loadedModel of payload.data ?? []) {
        if (
          loadedModel.state !== "loaded" ||
          !loadedModel.id ||
          !loadedModel.loaded_context_length
        ) {
          continue;
        }

        const normalizedId = loadedModel.id.replace(/[^a-zA-Z0-9_-]/g, "_");
        const entry = Object.entries(models).find(([key, value]) => {
          const model = (value ?? {}) as Record<string, any>;
          return (
            key === normalizedId ||
            model.id === loadedModel.id ||
            model.id === normalizedId
          );
        });

        if (entry) {
          const model = entry[1] as Record<string, any>;
          model.limit = {
            ...(model.limit ?? {}),
            context: loadedModel.loaded_context_length,
          };
          console.log(
            `[opencode] LM Studio context for ${loadedModel.id}: ${loadedModel.loaded_context_length}`,
          );
        }
      }
    } catch {
      // The /api/v0 endpoint is optional; discovery still works without it.
    }
  },
});
