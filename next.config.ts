import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // 启用standalone输出模式，用于Docker部署
  output: 'standalone',
  
  // 配置环境变量
  env: {
    OPENAI_API_KEY: process.env.OPENAI_API_KEY,
  },
  
  // 配置重写规则，用于代理API请求
  async rewrites() {
    return [
      {
        source: '/api/finance/:path*',
        destination: 'http://finance-agent:9999/:path*',
      },
      {
        source: '/api/it/:path*',
        destination: 'http://it-agent:9998/:path*',
      },
      {
        source: '/api/buildings/:path*',
        destination: 'http://buildings-agent:9997/:path*',
      },
    ];
  },
};

export default nextConfig;
