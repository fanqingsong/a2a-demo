# A2A Demo Docker 部署指南

本项目已使用 Docker Compose 进行容器化部署，支持生产环境和开发环境两种模式。

## 🚀 快速开始

### 1. 环境准备

确保您的系统已安装：
- Docker (20.10+)
- Docker Compose (2.0+)

### 2. 配置环境变量

复制环境变量示例文件：
```bash
cp env.example .env
```

编辑 `.env` 文件，选择以下其中一种配置方式：

#### 方式1: 使用 OpenAI API
```bash
OPENAI_API_KEY=your_openai_api_key_here
```

#### 方式2: 使用 Azure OpenAI（推荐）
```bash
# 注释掉 OpenAI API Key
# OPENAI_API_KEY=your_openai_api_key_here

# 配置 Azure OpenAI
AZURE_OPENAI_API_KEY=your_azure_api_key_here
AZURE_OPENAI_ENDPOINT=https://your-resource-name.openai.azure.com/
AZURE_OPENAI_API_VERSION=2024-02-15-preview
AZURE_OPENAI_DEPLOYMENT_NAME=your_deployment_name
```

> 💡 **Azure OpenAI 配置**: 如果您使用 Azure OpenAI，请参考 [Azure OpenAI 配置指南](AZURE_OPENAI_SETUP.md) 获取详细的设置说明。

### 3. 启动服务

#### 生产模式
```bash
./start.sh
```

#### 开发模式（支持热重载）
```bash
./start-dev.sh
```

### 4. 访问应用

服务启动后，您可以通过以下地址访问：

- **前端应用**: http://localhost:3000
- **Finance Agent**: http://localhost:8001
- **IT Agent**: http://localhost:8002
- **Buildings Agent**: http://localhost:8003

### 5. 停止服务

```bash
./stop.sh
```

## 📁 文件结构

```
a2a-demo/
├── docker-compose.yml          # 生产环境配置
├── docker-compose.dev.yml      # 开发环境配置
├── Dockerfile.frontend         # 前端应用Dockerfile
├── Dockerfile.agents          # Python agents Dockerfile
├── start.sh                   # 生产模式启动脚本
├── start-dev.sh              # 开发模式启动脚本
├── stop.sh                   # 停止脚本
├── env.example               # 环境变量示例
└── DOCKER_README.md          # 本文档
```

## 🔧 服务配置

### 微服务架构

- **Frontend**: Next.js 应用，端口 3000
- **Finance Agent**: Python 微服务，端口 8001
- **IT Agent**: Python 微服务，端口 8002
- **Buildings Agent**: Python 微服务，端口 8003

### 网络配置

所有服务运行在 `a2a-network` 网络中，支持服务间通信。

### 环境变量

| 变量名 | 描述 | 必需 | 备注 |
|--------|------|------|------|
| `OPENAI_API_KEY` | OpenAI API 密钥 | ⚠️ | 与 Azure OpenAI 二选一 |
| `AZURE_OPENAI_API_KEY` | Azure OpenAI API 密钥 | ⚠️ | 与 OpenAI API 二选一 |
| `AZURE_OPENAI_ENDPOINT` | Azure OpenAI 端点 | ⚠️ | 使用 Azure OpenAI 时必需 |
| `AZURE_OPENAI_API_VERSION` | Azure OpenAI API 版本 | ❌ | 默认: 2024-02-15-preview |
| `AZURE_OPENAI_DEPLOYMENT_NAME` | Azure OpenAI 部署名称 | ⚠️ | 使用 Azure OpenAI 时必需 |
| `NODE_ENV` | Node.js 环境 | ❌ | 默认: production |
| `PORT` | 各服务端口 | ❌ | 自动配置 |

## 🛠️ 开发模式特性

开发模式 (`docker-compose.dev.yml`) 提供以下特性：

- **热重载**: 代码修改后自动重新加载
- **卷挂载**: 本地代码直接映射到容器
- **实时日志**: 支持实时查看服务日志
- **调试支持**: 便于开发和调试

## 📊 监控和日志

### 查看服务状态
```bash
docker compose ps
```

### 查看服务日志
```bash
# 查看所有服务日志
docker compose logs -f

# 查看特定服务日志
docker compose logs -f frontend
docker compose logs -f finance-agent
docker compose logs -f it-agent
docker compose logs -f buildings-agent
```

### 进入容器调试
```bash
# 进入前端容器
docker compose exec frontend sh

# 进入agent容器
docker compose exec finance-agent bash
```

## 🔄 更新和重建

### 重建镜像
```bash
docker compose build --no-cache
```

### 重新启动服务
```bash
docker compose restart
```

### 完全重新部署
```bash
docker compose down
docker compose up -d --build
```

## 🐛 故障排除

### 常见问题

1. **端口冲突**
   - 检查端口 3000, 8001, 8002, 8003 是否被占用
   - 修改 `docker-compose.yml` 中的端口映射

2. **API Key 问题**
   - 确保 `.env` 文件中的 `OPENAI_API_KEY` 设置正确
   - 检查 API Key 是否有效且有足够额度

3. **服务启动失败**
   - 查看服务日志：`docker compose logs [service_name]`
   - 检查 Docker 和 Docker Compose 版本

4. **网络问题**
   - 确保 Docker 网络正常：`docker network ls`
   - 重启 Docker 服务

### 清理命令

```bash
# 清理所有容器和网络
docker compose down --remove-orphans

# 清理未使用的镜像和卷
docker system prune -f

# 清理所有数据（谨慎使用）
docker system prune -a --volumes
```

## 📝 自定义配置

### 修改端口

编辑 `docker-compose.yml` 中的端口映射：
```yaml
services:
  frontend:
    ports:
      - "8080:3000"  # 将前端端口改为8080
```

### 添加新服务

1. 在 `docker-compose.yml` 中添加新服务配置
2. 更新网络依赖关系
3. 重新构建和启动服务

### 环境变量配置

在 `docker-compose.yml` 中添加环境变量：
```yaml
services:
  frontend:
    environment:
      - CUSTOM_VAR=value
```

## 🤝 贡献

如果您在使用过程中遇到问题或有改进建议，请：

1. 检查本文档的故障排除部分
2. 查看项目的 GitHub Issues
3. 提交新的 Issue 或 Pull Request

## 📄 许可证

MIT License - 详见 LICENSE 文件
