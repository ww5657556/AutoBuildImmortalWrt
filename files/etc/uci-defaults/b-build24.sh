#!/bin/sh
# 首次启动初始化脚本（2.4G配置禁用 + 5G隐藏启用 + 预设密码）
[ -f /etc/init_done ] && exit 0  # 仅执行一次，避免重复修改

# ====================== 1. 设置 root 管理员密码 ======================
echo 'root:Ma707055060@' | chpasswd  # 自动哈希加密，符合系统安全规范

# ====================== 2. WiFi 配置（2.4G配置禁用 + 5G隐藏启用） ======================
# 清除默认 WiFi 接口配置（避免冲突）
uci delete wireless.@wifi-iface[0] 2>/dev/null
uci delete wireless.@wifi-iface[1] 2>/dev/null

# ---------------------- 2.4G WiFi 配置（仅配置SSID/密码，禁用状态） ----------------------
uci set wireless.@wifi-device[0].disabled='0'  # 启用设备（仅为配置接口，后续接口禁用）
uci add wireless wifi-iface
uci set wireless.@wifi-iface[-1].device='radio0'  # mediatek/filogic 2.4G默认节点
uci set wireless.@wifi-iface[-1].network='lan'
uci set wireless.@wifi-iface[-1].mode='ap'
uci set wireless.@wifi-iface[-1].ssid='dong'  # 预设2.4G SSID
uci set wireless.@wifi-iface[-1].encryption='psk2'  # WPA2-PSK加密
uci set wireless.@wifi-iface[-1].key='m707055060@'  # 预设2.4G密码
uci set wireless.@wifi-iface[-1].disabled='1'  # 核心：禁用2.4G接口（仅保留配置）
uci set wireless.@wifi-device[0].disabled='1'  # 禁用2.4G设备（双重保障）

# ---------------------- 5G WiFi 配置（隐藏SSID + 启用状态） ----------------------
uci set wireless.@wifi-device[1].disabled='0'  # 启用5G设备（mediatek/filogic默认节点radio1）
uci add wireless wifi-iface
uci set wireless.@wifi-iface[-1].device='radio1'
uci set wireless.@wifi-iface[-1].network='lan'
uci set wireless.@wifi-iface[-1].mode='ap'
uci set wireless.@wifi-iface[-1].ssid='dong'  # 与2.4G同名SSID
uci set wireless.@wifi-iface[-1].encryption='psk2'
uci set wireless.@wifi-iface[-1].key='m707055060@'  # 与2.4G同密码
uci set wireless.@wifi-iface[-1].disabled='0'  # 启用5G接口
uci set wireless.@wifi-iface[-1].hidden='1'  # 隐藏5G SSID（不广播）

# 保存配置并立即生效
uci commit wireless
wifi reload  # 无需重启，即时应用配置

# ====================== 3. 标记初始化完成 ======================
touch /etc/init_done

# 日志记录（可通过 logread 命令查看执行结果）
logger -t "init-script" "首次启动配置完成：root密码已设置；2.4G WiFi（SSID=dong）已配置并禁用；5G WiFi（隐藏SSID=dong）已启用"
