// ================================================================
// Agent Reach Service — AI Agent 互联网能力层
// 无需 API Key，CLI 工具驱动，支持 Twitter/X、Reddit、YouTube、GitHub 等
// 项目: https://github.com/Panniantong/Agent-Reach
// ================================================================

const AgentReachService = {
  BASE_URL: 'https://raw.githubusercontent.com/Panniantong/agent-reach/main',
  _installed: null,
  _checking: false,

  // 支持的渠道及对应能力
  channels: {
    'twitter': {
      id: 'twitter',
      name: 'Twitter/X',
      icon: '🐦',
      desc: '搜索推文、查看时间线、用户资料',
      command: 'twitter search',
      needsAuth: true,
      authType: 'cookie',
    },
    'reddit': {
      id: 'reddit',
      name: 'Reddit',
      icon: '📖',
      desc: '搜索帖子、子版块、热门内容',
      command: 'opencli reddit search',
      needsAuth: true,
      authType: 'browser',
    },
    'youtube': {
      id: 'youtube',
      name: 'YouTube',
      icon: '▶️',
      desc: '提取视频字幕、搜索视频、频道信息',
      command: 'yt-dlp',
      needsAuth: false,
    },
    'bilibili': {
      id: 'bilibili',
      name: 'B站',
      icon: '📺',
      desc: '搜索视频、获取详情、字幕提取',
      command: 'bili search',
      needsAuth: false,
    },
    'github': {
      id: 'github',
      name: 'GitHub',
      icon: '📦',
      desc: '仓库搜索、Issue 查询、PR 查看',
      command: 'gh search repos',
      needsAuth: false,
    },
    'web': {
      id: 'web',
      name: '全网搜索',
      icon: '🌐',
      desc: 'Jina Reader 清洗网页 + Exa 语义搜索',
      command: 'exa search',
      needsAuth: false,
    },
    'xiaohongshu': {
      id: 'xiaohongshu',
      name: '小红书',
      icon: '📕',
      desc: '搜索笔记、用户内容、热门话题',
      command: 'opencli xiaohongshu search',
      needsAuth: true,
      authType: 'cookie',
    },
    'linkedin': {
      id: 'linkedin',
      name: 'LinkedIn',
      icon: '💼',
      desc: '搜索公司、职位、人员信息',
      command: 'linkedin search',
      needsAuth: false,
    },
  },

  // 安装状态检查
  isInstalled() {
    if (this._installed !== null) return this._installed;
    this._installed = localStorage.getItem('agent_reach_installed') === 'true';
    return this._installed;
  },

  setInstalled(val) {
    this._installed = val;
    localStorage.setItem('agent_reach_installed', val ? 'true' : 'false');
  },

  // 获取安装指令
  getInstallCommand() {
    return `pip install agent-reach && agent-reach install --env=auto`;
  },

  getInstallUrl() {
    return 'https://raw.githubusercontent.com/Panniantong/agent-reach/main/docs/install.md';
  },

  // 获取健康检查命令
  getDoctorCommand() {
    return 'agent-reach doctor';
  },

  // 获取渠道状态（模拟 - Electron 中可通过 Node.js 真实调用）
  async getChannelStatus(channelId) {
    const ch = this.channels[channelId];
    if (!ch) return { available: false, error: '未知渠道' };

    // 在 Electron 环境中，可以尝试通过 child_process 执行
    // 在 Web 预览中，返回模拟状态
    if (typeof window.require !== 'undefined') {
      // Electron 环境 - 真实检测
      try {
        const { execSync } = window.require('child_process');
        execSync('which agent-reach', { timeout: 5000 });
        return { available: true, backend: ch.command, channel: ch };
      } catch {
        return { available: false, error: 'Agent Reach CLI 未安装', channel: ch };
      }
    }

    // Web 预览环境 - 模拟状态
    return {
      available: this.isInstalled(),
      backend: ch.command,
      channel: ch,
      note: this.isInstalled() ? '已配置' : '需安装 Agent Reach CLI',
    };
  },

  // 模拟搜索执行（Web 预览）/ 真实调用（Electron）
  async executeSearch(channelId, query, options = {}) {
    const ch = this.channels[channelId];
    if (!ch) throw new Error('未知渠道: ' + channelId);

    if (!this.isInstalled()) {
      throw new Error('AGENT_REACH_NOT_INSTALLED: Agent Reach CLI 未安装');
    }

    if (typeof window.require !== 'undefined') {
      // Electron 环境 - 真实 CLI 调用
      try {
        const { execSync } = window.require('child_process');
        const cmd = `${ch.command} "${query}" ${options.extra || ''}`.trim();
        const result = execSync(cmd, { timeout: 30000, encoding: 'utf8', maxBuffer: 10 * 1024 * 1024 });
        return {
          success: true,
          channel: ch.name,
          query: query,
          raw: result,
          timestamp: new Date().toISOString(),
        };
      } catch (err) {
        throw new Error('搜索执行失败: ' + (err.stderr || err.message));
      }
    }

    // Web 预览环境 - AI 模拟搜索结果
    return this._simulateSearch(channelId, query, options);
  },

  // AI 模拟搜索结果
  _simulateSearch(channelId, query, options) {
    const ch = this.channels[channelId];
    const now = new Date().toLocaleString('zh-CN');

    const mockResults = {
      'twitter': {
        platform: 'Twitter/X',
        results: [
          { id: '1', author: '@tech_insider', content: `关于"${query}"的最新讨论：AI 正在重塑行业格局，企业需要加速数字化转型...`, likes: 1240, retweets: 356, time: '2小时前' },
          { id: '2', author: '@ai_research', content: `"${query}" 相关研究取得突破性进展，新模型在多项基准测试中超越前代...`, likes: 890, retweets: 210, time: '5小时前' },
          { id: '3', author: '@startup_daily', content: `多家创业公司正在围绕"${query}"构建创新解决方案，融资热度持续升温...`, likes: 567, retweets: 134, time: '8小时前' },
        ],
      },
      'reddit': {
        platform: 'Reddit',
        results: [
          { id: '1', subreddit: 'r/artificial', title: `[Discussion] "${query}" - 行业现状与未来趋势深度分析`, upvotes: 2340, comments: 456, time: '3小时前' },
          { id: '2', subreddit: 'r/MachineLearning', title: `[Research] "${query}" 最新论文解读与代码实现`, upvotes: 1890, comments: 312, time: '6小时前' },
          { id: '3', subreddit: 'r/startups', title: `[AMA] 我们如何利用"${query}"技术从0到1`, upvotes: 1567, comments: 278, time: '12小时前' },
        ],
      },
      'youtube': {
        platform: 'YouTube',
        results: [
          { id: '1', title: `深入理解"${query}" - 完整教程`, channel: 'Tech Academy', views: '12万', duration: '45:30', time: '2天前' },
          { id: '2', title: `"${query}"实战：从入门到精通`, channel: 'AI Workshop', views: '8.5万', duration: '32:15', time: '5天前' },
          { id: '3', title: `2026年"${query}"最新趋势解读`, channel: 'Future Tech', views: '6.2万', duration: '18:40', time: '1周前' },
        ],
      },
      'bilibili': {
        platform: 'B站',
        results: [
          { id: '1', title: `【干货】"${query}"完全指南`, up: '科技美学', views: '15.6万', danmaku: 2340, time: '1天前' },
          { id: '2', title: `"${query}"入门到入土，这一篇就够了`, up: '程序员鱼皮', views: '9.8万', danmaku: 1567, time: '3天前' },
          { id: '3', title: `[收藏向]"${query}"最佳实践合集`, up: 'CodeSheep', views: '7.2万', danmaku: 890, time: '5天前' },
        ],
      },
      'github': {
        platform: 'GitHub',
        results: [
          { id: '1', name: `awesome-${query.replace(/\s+/g, '-').toLowerCase()}`, owner: 'opensource', stars: '12.5k', desc: 'A curated list of awesome resources', lang: 'Markdown', time: '更新于2天前' },
          { id: '2', name: `${query.replace(/\s+/g, '-').toLowerCase()}-framework`, owner: 'devteam', stars: '8.3k', desc: 'Production-ready framework for modern apps', lang: 'TypeScript', time: '更新于1周前' },
          { id: '3', name: `${query.replace(/\s+/g, '_').toLowerCase()}_tools`, owner: 'aitools', stars: '5.7k', desc: 'Collection of AI-powered tools and utilities', lang: 'Python', time: '更新于3天前' },
        ],
      },
      'web': {
        platform: '全网搜索 (Exa)',
        results: [
          { id: '1', title: `"${query}" - 维基百科`, url: 'https://zh.wikipedia.org/wiki/', snippet: `${query}是一个快速发展的技术领域，涵盖多个子方向和应用场景...`, relevance: 0.95 },
          { id: '2', title: `"${query}" 最新资讯与动态`, url: 'https://example.com/news/', snippet: `2026年${query}领域迎来多项重大突破，行业格局正在发生深刻变化...`, relevance: 0.92 },
          { id: '3', title: `"${query}" 技术白皮书`, url: 'https://example.com/whitepaper/', snippet: `本文深入分析${query}的核心技术原理、架构设计及最佳实践...`, relevance: 0.88 },
        ],
      },
      'xiaohongshu': {
        platform: '小红书',
        results: [
          { id: '1', author: '科技小能手', title: `"${query}"太强了！用了就回不去`, likes: '2.3万', collects: '1.2万', time: '6小时前' },
          { id: '2', author: '程序员日记', title: `吐血整理"${query}"学习路线图`, likes: '1.8万', collects: '2.5万', time: '1天前' },
          { id: '3', author: '产品经理Lucy', title: `"${query}"工具推荐，效率提升200%`, likes: '9.8千', collects: '6.7千', time: '2天前' },
        ],
      },
      'linkedin': {
        platform: 'LinkedIn',
        results: [
          { id: '1', author: 'Tech Lead at Google', content: `Excited to share our latest work on "${query}" - transforming how we approach enterprise solutions.`, likes: 890, time: '4小时前' },
          { id: '2', author: 'CTO at AI Startup', content: `Hiring engineers passionate about "${query}"! DM for details. #AI #Hiring`, likes: 567, time: '8小时前' },
          { id: '3', author: 'Industry Analyst', content: `Market report: "${query}" sector projected to grow 300% by 2027. Key players and trends analyzed.`, likes: 1230, time: '1天前' },
        ],
      },
    };

    const data = mockResults[channelId];
    if (!data) return { success: false, error: '不支持的渠道', channel: ch.name };

    return {
      success: true,
      channel: ch.name,
      query: query,
      platform: data.platform,
      results: data.results,
      searchedAt: now,
      source: 'Agent Reach · AI 模拟搜索 (Web 预览)',
      note: '安装 Agent Reach CLI 后可在桌面应用中获取实时结果',
    };
  },

  // 批量搜索多个渠道
  async searchAll(query, channelIds = ['web', 'twitter', 'reddit']) {
    const results = {};
    for (const cid of channelIds) {
      try {
        results[cid] = await this.executeSearch(cid, query);
      } catch (err) {
        results[cid] = { success: false, error: err.message };
      }
    }
    return {
      query,
      searchedAt: new Date().toLocaleString('zh-CN'),
      channels: results,
      summary: this._generateSummary(query, results),
    };
  },

  // AI 摘要生成
  _generateSummary(query, channelResults) {
    const successfulChannels = Object.entries(channelResults)
      .filter(([_, r]) => r.success)
      .map(([id, r]) => this.channels[id]?.name || id);

    if (successfulChannels.length === 0) {
      return `未获取到关于"${query}"的搜索结果，请检查网络连接或搜索词。`;
    }

    const totalResults = Object.values(channelResults)
      .filter(r => r.success)
      .reduce((sum, r) => sum + (r.results?.length || 0), 0);

    return `已从 ${successfulChannels.join('、')} 共 ${successfulChannels.length} 个渠道搜索"${query}"，获取 ${totalResults} 条相关结果。综合各渠道信息，该主题在 ${successfulChannels[0]} 上讨论最为活跃。`;
  },
};

window.AgentReachService = AgentReachService;
