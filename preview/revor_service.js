// ================================================================
// Revor Service — 外展服务 (LinkedIn/Email/WhatsApp)
// ================================================================

const RevorService = {
  BASE_URL: 'https://revor.ai',
  _apiKey: null,

  capabilities: {
    'outreach': {
      id: 'outreach',
      name: 'Revor 智能外展',
      icon: '📨',
      desc: '通过 LinkedIn/Email/WhatsApp 自动化外展，智能检测意图并起草内容',
    },
  },

  getApiKey() {
    if (this._apiKey) return this._apiKey;
    return localStorage.getItem('revor_api_key') || '';
  },

  setApiKey(key) {
    this._apiKey = key;
    localStorage.setItem('revor_api_key', key);
  },

  isConfigured() {
    return !!this.getApiKey();
  },

  async dispatchOutreach(params) {
    const apiKey = this.getApiKey();
    if (!apiKey) throw new Error('REVOR_KEY_INVALID: 请先配置 Revor API Key');

    try {
      const response = await fetch(`${this.BASE_URL}/api/v1/outreach`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${apiKey}`,
        },
        body: JSON.stringify({
          channel: params.channel || 'linkedin',
          recipient: params.recipient || '',
          message: params.message || '',
          subject: params.subject || '',
          context: params.context || '',
          ...params.extra,
        }),
        signal: AbortSignal.timeout(60000),
      });

      if (!response.ok) {
        const errData = await response.json().catch(() => ({}));
        if (response.status === 401) throw new Error('REVOR_KEY_INVALID: API Key 无效');
        if (response.status === 429) throw new Error('REVOR_RATE_LIMIT: 请求过于频繁');
        throw new Error(errData.message || errData.error || `请求失败 (${response.status})`);
      }

      return await response.json();
    } catch (err) {
      if (err.name === 'TimeoutError' || err.name === 'AbortError') {
        throw new Error('请求超时，请检查网络连接');
      }
      if (err.message.startsWith('REVOR_')) throw err;
      throw new Error('网络连接失败: ' + err.message);
    }
  },
};

window.RevorService = RevorService;
