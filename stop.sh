#!/bin/bash

# A2A Demo 微服务停止脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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
    echo -e "${RED}================================${NC}"
    echo -e "${RED}    A2A Demo 微服务停止脚本    ${NC}"
    echo -e "${RED}================================${NC}"
}

# 停止服务
stop_services() {
    print_message "停止所有微服务..."
    docker compose down --remove-orphans
    
    print_message "清理未使用的容器和网络..."
    docker system prune -f
}

# 显示状态
show_status() {
    print_message "当前服务状态:"
    docker compose ps
}

# 主函数
main() {
    print_header
    
    # 检查Docker是否运行
    if ! docker info &> /dev/null; then
        print_error "Docker 未运行，请先启动 Docker"
        exit 1
    fi
    
    # 停止服务
    stop_services
    
    # 显示状态
    show_status
    
    print_message "所有服务已停止"
}

# 运行主函数
main "$@"
