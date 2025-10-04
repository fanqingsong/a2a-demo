#!/bin/bash

# A2A Demo 微服务开发模式启动脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  A2A Demo 开发模式启动脚本    ${NC}"
    echo -e "${BLUE}================================${NC}"
}

# 检查Docker是否安装
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker 未安装，请先安装 Docker"
        exit 1
    fi
    
    if ! command -v docker compose &> /dev/null; then
        print_error "Docker Compose 未安装，请先安装 Docker Compose"
        exit 1
    fi
}

# 检查环境变量
check_env() {
    # 检查是否设置了OpenAI或Azure OpenAI配置
    if [ -z "$OPENAI_API_KEY" ] && [ -z "$AZURE_OPENAI_API_KEY" ]; then
        print_warning "未设置AI服务配置"
        print_warning "请选择以下其中一种方式配置:"
        print_warning ""
        print_warning "方式1 - OpenAI API:"
        print_warning "  export OPENAI_API_KEY=your_openai_api_key_here"
        print_warning ""
        print_warning "方式2 - Azure OpenAI:"
        print_warning "  export AZURE_OPENAI_API_KEY=your_azure_api_key_here"
        print_warning "  export AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com/"
        print_warning "  export AZURE_OPENAI_DEPLOYMENT_NAME=your_deployment_name"
        print_warning ""
        print_warning "或者创建 .env 文件并添加相应配置"
        exit 1
    fi
    
    # 如果使用Azure OpenAI，检查必要的配置
    if [ -n "$AZURE_OPENAI_API_KEY" ]; then
        if [ -z "$AZURE_OPENAI_ENDPOINT" ]; then
            print_error "使用Azure OpenAI时，必须设置 AZURE_OPENAI_ENDPOINT"
            exit 1
        fi
        print_message "使用 Azure OpenAI 服务"
    else
        print_message "使用 OpenAI 服务"
    fi
}

# 清理旧的容器
cleanup() {
    print_message "清理旧的容器..."
    docker compose -f docker-compose.dev.yml down --remove-orphans 2>/dev/null || true
}

# 构建镜像
build_images() {
    print_message "构建 Docker 镜像..."
    docker compose -f docker-compose.dev.yml build --no-cache
}

# 启动服务
start_services() {
    print_message "启动开发模式微服务..."
    docker compose -f docker-compose.dev.yml up -d
    
    print_message "等待服务启动..."
    sleep 10
    
    # 检查服务状态
    print_message "检查服务状态..."
    docker compose -f docker-compose.dev.yml ps
}

# 显示服务信息
show_info() {
    echo ""
    print_message "开发模式服务启动完成！"
    echo ""
    echo -e "${GREEN}🌐 前端应用:${NC} http://localhost:3000"
    echo -e "${GREEN}💰 Finance Agent:${NC} http://localhost:8001"
    echo -e "${GREEN}💻 IT Agent:${NC} http://localhost:8002"
    echo -e "${GREEN}🏢 Buildings Agent:${NC} http://localhost:8003"
    echo ""
    print_message "开发模式特性:"
    echo "  - 代码热重载"
    echo "  - 实时日志输出"
    echo "  - 卷挂载支持"
    echo ""
    print_message "使用以下命令查看日志:"
    echo "  docker compose -f docker-compose.dev.yml logs -f [service_name]"
    echo ""
    print_message "使用以下命令停止服务:"
    echo "  docker compose -f docker-compose.dev.yml down"
    echo ""
}

# 主函数
main() {
    print_header
    
    # 检查依赖
    check_docker
    
    # 检查环境变量
    if [ -f ".env" ]; then
        source .env
    fi
    check_env
    
    # 清理和构建
    cleanup
    build_images
    
    # 启动服务
    start_services
    
    # 显示信息
    show_info
}

# 处理中断信号
trap 'print_warning "正在停止开发服务..."; docker compose -f docker-compose.dev.yml down; exit 0' INT TERM

# 运行主函数
main "$@"
