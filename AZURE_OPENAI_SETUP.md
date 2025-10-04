# Azure OpenAI 配置指南

本指南将帮助您配置 Azure OpenAI 服务以运行 A2A Demo 项目。

## 🔧 前置要求

1. **Azure 订阅**: 需要一个有效的 Azure 订阅
2. **Azure OpenAI 服务**: 在 Azure 中创建 OpenAI 服务实例
3. **模型部署**: 在 Azure OpenAI 中部署 GPT-4 模型

## 📋 步骤 1: 创建 Azure OpenAI 资源

### 1.1 登录 Azure 门户
访问 [Azure 门户](https://portal.azure.com/) 并登录您的账户。

### 1.2 创建 OpenAI 资源
1. 在 Azure 门户中搜索 "OpenAI"
2. 点击 "创建" 按钮
3. 填写以下信息：
   - **订阅**: 选择您的 Azure 订阅
   - **资源组**: 创建新的或选择现有的资源组
   - **区域**: 选择支持 Azure OpenAI 的区域（如 East US、West Europe 等）
   - **名称**: 为您的资源命名（例如：`my-openai-resource`）
   - **定价层**: 选择适合的定价层

### 1.3 等待部署完成
资源创建通常需要几分钟时间。

## 🚀 步骤 2: 部署模型

### 2.1 访问 Azure OpenAI Studio
1. 在 Azure 门户中找到您创建的 OpenAI 资源
2. 点击 "转到 Azure OpenAI Studio"
3. 或者直接访问 [Azure OpenAI Studio](https://oai.azure.com/)

### 2.2 部署 GPT-4 模型
1. 在 Azure OpenAI Studio 中，点击 "部署" 标签
2. 点击 "创建新部署"
3. 选择以下配置：
   - **模型**: 选择 `gpt-4o` 或 `gpt-4`
   - **部署名称**: 输入一个名称（例如：`gpt-4o-deployment`）
   - **模型版本**: 选择最新版本
   - **容量**: 根据您的需求设置

### 2.3 等待部署完成
模型部署可能需要几分钟到几小时不等。

## 🔑 步骤 3: 获取 API 密钥和端点

### 3.1 获取 API 密钥
1. 在 Azure 门户中，找到您的 OpenAI 资源
2. 在左侧菜单中点击 "密钥和端点"
3. 复制 **密钥 1** 或 **密钥 2**

### 3.2 获取端点 URL
1. 在同一页面中，复制 **端点** URL
2. 端点格式通常为：`https://your-resource-name.openai.azure.com/`

## ⚙️ 步骤 4: 配置环境变量

### 4.1 创建 .env 文件
在项目根目录创建 `.env` 文件：

```bash
cp env.example .env
```

### 4.2 编辑 .env 文件
使用您获取的 Azure OpenAI 信息更新 `.env` 文件：

```bash
# 注释掉 OpenAI API Key（如果存在）
# OPENAI_API_KEY=your_openai_api_key_here

# Azure OpenAI 配置
AZURE_OPENAI_API_KEY=your_azure_api_key_here
AZURE_OPENAI_ENDPOINT=https://your-resource-name.openai.azure.com/
AZURE_OPENAI_API_VERSION=2024-02-15-preview
AZURE_OPENAI_DEPLOYMENT_NAME=your_deployment_name
```

### 4.3 替换实际值
将以下值替换为您的实际配置：

- `your_azure_api_key_here`: 您的 Azure OpenAI API 密钥
- `your-resource-name`: 您的 Azure OpenAI 资源名称
- `your_deployment_name`: 您创建的模型部署名称

## 🧪 步骤 5: 测试配置

### 5.1 运行测试脚本
```bash
./test-docker.sh
```

### 5.2 启动服务
```bash
# 开发模式
./start-dev.sh

# 或生产模式
./start.sh
```

### 5.3 验证服务
访问 http://localhost:3000 并测试 AI 功能是否正常工作。

## 🔍 故障排除

### 常见问题

#### 1. 认证错误
```
Error: Invalid API key
```
**解决方案**: 检查 API 密钥是否正确，确保没有多余的空格或字符。

#### 2. 端点错误
```
Error: Invalid endpoint
```
**解决方案**: 确保端点 URL 格式正确，包含 `https://` 前缀。

#### 3. 模型未找到
```
Error: Model not found
```
**解决方案**: 检查部署名称是否正确，确保模型已成功部署。

#### 4. 配额限制
```
Error: Rate limit exceeded
```
**解决方案**: 检查您的 Azure OpenAI 配额限制，考虑升级定价层。

### 调试技巧

#### 1. 检查环境变量
```bash
# 检查环境变量是否正确加载
docker compose exec finance-agent env | grep AZURE
```

#### 2. 查看服务日志
```bash
# 查看特定服务的日志
docker compose logs finance-agent
docker compose logs it-agent
docker compose logs buildings-agent
```

#### 3. 测试 API 连接
```bash
# 进入容器测试
docker compose exec finance-agent python -c "
import openai
import os
client = openai.AzureOpenAI(
    api_key=os.getenv('AZURE_OPENAI_API_KEY'),
    api_version=os.getenv('AZURE_OPENAI_API_VERSION'),
    azure_endpoint=os.getenv('AZURE_OPENAI_ENDPOINT')
)
print('Azure OpenAI 客户端创建成功')
"
```

## 📚 参考资源

- [Azure OpenAI 服务文档](https://docs.microsoft.com/en-us/azure/cognitive-services/openai/)
- [Azure OpenAI Studio](https://oai.azure.com/)
- [OpenAI Python SDK](https://github.com/openai/openai-python)

## 💡 最佳实践

1. **安全性**: 永远不要在代码中硬编码 API 密钥
2. **环境隔离**: 为不同环境（开发、测试、生产）使用不同的 Azure OpenAI 资源
3. **监控**: 定期检查使用量和成本
4. **备份**: 保存好您的 API 密钥和配置信息
5. **版本控制**: 将 `.env` 文件添加到 `.gitignore` 中

## 🆘 获取帮助

如果您遇到问题，可以：

1. 查看本文档的故障排除部分
2. 检查 Azure OpenAI 服务状态
3. 查看项目的 GitHub Issues
4. 联系 Azure 支持团队
