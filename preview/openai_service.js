// ================================================================
// OpenAI Service — GPT-4o / GPT-4o-mini / o1 / o3-mini
// ================================================================
const OpenAIService = {
  apiKey: localStorage.getItem('openai_api_key') || '',
  baseUrl: 'https://api.openai.com/v1',

  // 默认模型
  defaultModel: localStorage.getItem('openai_model') || 'gpt-4o',

  // 可用模型列表
  models: [
    { id: 'gpt-4o', name: 'GPT-4o', context: 128000, multimodal: true },
    { id: 'gpt-4o-mini', name: 'GPT-4o-mini', context: 128000, multimodal: true },
    { id: 'o1', name: 'o1', context: 200000, multimodal: true },
    { id: 'o3-mini', name: 'o3-mini', context: 200000, multimodal: false },
    { id: 'gpt-4-turbo', name: 'GPT-4 Turbo', context: 128000, multimodal: true },
  ],

  isConfigured() {
    return this.apiKey.length > 0;
  },

  setApiKey(key) {
    this.apiKey = key;
    localStorage.setItem('openai_api_key', key);
  },

  getApiKey() {
    return this.apiKey;
  },

  clearApiKey() {
    this.apiKey = '';
    localStorage.removeItem('openai_api_key');
  },

  setDefaultModel(modelId) {
    this.defaultModel = modelId;
    localStorage.setItem('openai_model', modelId);
  },

  // 通用聊天补全
  async chatCompletion(params) {
    if (!this.isConfigured()) throw new Error('OPENAI_KEY_MISSING');

    const { model, messages, temperature = 0.7, maxTokens = 4096 } = params;

    const response = await fetch(`${this.baseUrl}/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.apiKey}`,
      },
      body: JSON.stringify({
        model: model || this.defaultModel,
        messages,
        temperature,
        max_tokens: maxTokens,
      }),
    });

    if (!response.ok) {
      const err = await response.json().catch(() => ({}));
      throw new Error(err.error?.message || `OpenAI API error: ${response.status}`);
    }

    return response.json();
  },

  // 简单文本生成
  async generateText(prompt, options = {}) {
    const { model, systemPrompt, temperature = 0.7, maxTokens = 4096 } = options;

    const messages = [];
    if (systemPrompt) messages.push({ role: 'system', content: systemPrompt });
    messages.push({ role: 'user', content: prompt });

    const result = await this.chatCompletion({
      model: model || this.defaultModel,
      messages,
      temperature,
      maxTokens,
    });

    return result.choices?.[0]?.message?.content || '';
  },

  // 流式生成
  async streamCompletion(params, onChunk) {
    if (!this.isConfigured()) throw new Error('OPENAI_KEY_MISSING');

    const { model, messages, temperature = 0.7, maxTokens = 4096 } = params;

    const response = await fetch(`${this.baseUrl}/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.apiKey}`,
      },
      body: JSON.stringify({
        model: model || this.defaultModel,
        messages,
        temperature,
        max_tokens: maxTokens,
        stream: true,
      }),
    });

    if (!response.ok) {
      const err = await response.json().catch(() => ({}));
      throw new Error(err.error?.message || `OpenAI API error: ${response.status}`);
    }

    const reader = response.body.getReader();
    const decoder = new TextDecoder();
    let fullContent = '';

    while (true) {
      const { done, value } = await reader.read();
      if (done) break;

      const chunk = decoder.decode(value, { stream: true });
      const lines = chunk.split('\n').filter(l => l.startsWith('data: '));

      for (const line of lines) {
        const data = line.slice(6).trim();
        if (data === '[DONE]') continue;

        try {
          const parsed = JSON.parse(data);
          const content = parsed.choices?.[0]?.delta?.content || '';
          if (content) {
            fullContent += content;
            if (onChunk) onChunk(content, fullContent);
          }
        } catch (e) {
          // skip malformed JSON
        }
      }
    }

    return fullContent;
  },

  // 获取可用模型列表
  async fetchModels() {
    if (!this.isConfigured()) throw new Error('OPENAI_KEY_MISSING');

    const response = await fetch(`${this.baseUrl}/models`, {
      headers: {
        'Authorization': `Bearer ${this.apiKey}`,
      },
    });

    if (!response.ok) throw new Error(`Failed to fetch models: ${response.status}`);

    const data = await response.json();
    return data.data || [];
  },

  // 测试连接
  async testConnection() {
    try {
      const result = await this.generateText('Hello, respond with "OK" only.', {
        model: 'gpt-4o-mini',
        maxTokens: 10,
      });
      return { success: true, message: 'OpenAI 连接成功', data: result };
    } catch (e) {
      return { success: false, message: e.message };
    }
  },
};
