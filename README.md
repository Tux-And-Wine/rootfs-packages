# TuxWine 构建系统

用于交叉编译软件包的构建系统，为 Android Wine 模拟器构建 rootfs。

## 快速开始

```bash
# 1. 克隆项目
git clone https://github.com/Tux-And-Wine/rootfs-packages.git
cd rootfs-packages

# 2. 安装依赖（需要root权限）
sudo ./setup-environment.sh -y

# 3. 配置
cp config.example.sh config.sh
vim config.sh  # 编辑 PREFIX 和 TARGET_HOST

# 4. 构建
./start-build.sh zlib          # 构建单个包
./start-build.sh all           # 构建所有包
```

## 常用命令

```bash
./start-build.sh --list        # 列出所有可用包
./start-build.sh --info zlib   # 查看包信息
./start-build.sh --deps glib   # 查看依赖树
./start-build.sh --status      # 查看构建状态
./start-build.sh -r zlib       # 重建包
./start-build.sh --clean       # 清理编译产物
./start-build.sh --log         # 查看构建日志
```

## 构建选项

| 选项 | 说明 |
|------|------|
| `-r` | 清理后重建 |
| `-v` | 详细输出 |
| `-k` | 遇错继续 |
| `-j N` | 并行任务数 |

## 详细文档

使用手册请参考 `md.txt` 文件。

## 许可证

GPL-3.0
