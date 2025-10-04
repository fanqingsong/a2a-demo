#!/bin/bash

# Docker 配置测试脚本

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
    echo -e "${BLUE}    Docker 配置测试脚本        ${NC}"
    echo -e "${BLUE}================================${NC}"
}

# 检查Docker
check_docker() {
    print_message "检查 Docker 安装..."
    if command -v docker &> /dev/null; then
        docker --version
    else
        print_error "Docker 未安装"
        return 1
    fi
    
    if command -v docker compose &> /dev/null; then
        docker compose version
    else
        print_error "Docker Compose 未安装"
        return 1
    fi
}

# 检查配置文件
check_config_files() {
    print_message "检查配置文件..."
    
    local files=(
        "docker-compose.yml"
        "docker-compose.dev.yml"
        "Dockerfile.frontend"
        "Dockerfile.agents"
        "env.example"
    )
    
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            print_message "✅ $file 存在"
        else
            print_error "❌ $file 不存在"
            return 1
        fi
    done
}

# 检查脚本权限
check_scripts() {
    print_message "检查脚本权限..."
    
    local scripts=(
        "start.sh"
        "start-dev.sh"
        "stop.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            if [ -x "$script" ]; then
                print_message "✅ $script 可执行"
            else
                print_warning "⚠️  $script 不可执行，正在修复..."
                chmod +x "$script"
            fi
        else
            print_error "❌ $script 不存在"
            return 1
        fi
    done
}

# 验证Docker Compose语法
validate_compose() {
    print_message "验证 Docker Compose 语法..."
    
    if docker compose -f docker-compose.yml config &> /dev/null; then
        print_message "✅ docker-compose.yml 语法正确"
    else
        print_error "❌ docker-compose.yml 语法错误"
        return 1
    fi
    
    if docker compose -f docker-compose.dev.yml config &> /dev/null; then
        print_message "✅ docker-compose.dev.yml 语法正确"
    else
        print_error "❌ docker-compose.dev.yml 语法错误"
        return 1
    fi
}

# 检查环境变量
check_env() {
    print_message "检查环境变量配置..."
    
    if [ -f "env.example" ]; then
        print_message "✅ env.example 存在"
        print_warning "请确保已创建 .env 文件并设置 OPENAI_API_KEY"
    else
        print_error "❌ env.example 不存在"
        return 1
    fi
}

# 显示使用说明
show_usage() {
    echo ""
    print_message "测试完成！使用说明："
    echo ""
    echo -e "${GREEN}1. 设置环境变量:${NC}"
    echo "   cp env.example .env"
    echo "   # 编辑 .env 文件，设置 OPENAI_API_KEY"
    echo ""
    echo -e "${GREEN}2. 启动生产环境:${NC}"
    echo "   ./start.sh"
    echo ""
    echo -e "${GREEN}3. 启动开发环境:${NC}"
    echo "   ./start-dev.sh"
    echo ""
    echo -e "${GREEN}4. 停止服务:${NC}"
    echo "   ./stop.sh"
    echo ""
    echo -e "${GREEN}5. 查看详细文档:${NC}"
    echo "   cat DOCKER_README.md"
    echo ""
}

# 主函数
main() {
    print_header
    
    local exit_code=0
    
    # 运行所有检查
    check_docker || exit_code=1
    check_config_files || exit_code=1
    check_scripts || exit_code=1
    validate_compose || exit_code=1
    check_env || exit_code=1
    
    if [ $exit_code -eq 0 ]; then
        print_message "🎉 所有检查通过！Docker 配置正确。"
        show_usage
    else
        print_error "❌ 部分检查失败，请修复问题后重试。"
        exit 1
    fi
}

# 运行主函数
main "$@"
