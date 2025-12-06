#!/bin/sh
# 首次启动初始化脚本（5G 160MHz自动信道+隐藏SSID + 2.4G配置禁用 + 预设密码）
[ -f /etc/init_done ] && exit 0  # 仅执行一次，避免重复修改

# ====================== 1. 设置 root 管理员密码 ======================
echo 'root:Ma707055060@' | chpasswd  # 自动哈希加密，符合系统安全规范

# ====================== 2. WiFi 核心配置 ======================
# 清除默认 WiFi 接口配置（避免冲突）
uci delete wireless.@wifi-iface[0] 2>/dev/null
uci delete wireless.@wifi-iface[1] 2>/dev/null

# ---------------------- 2.4G WiFi（配置SSID/密码，禁用状态） ----------------------
uci set wireless.@wifi-device[0].disabled='0'  # 临时启用设备以配置接口
uci add wireless wifi-iface
uci set wireless.@wifi-iface[-1].device='radio0'  # mediatek/filogic 2.4G默认节点
uci set wireless.@wifi-iface[-1].network='lan'
uci set wireless.@wifi-iface[-1].mode='ap'
uci set wireless.@wifi-iface[-1].ssid='dong2.4'  # 预设2.4G SSID
uci set wireless.@wifi-iface[-1].encryption='psk2'  # WPA2-PSK加密
uci set wireless.@wifi-iface[-1].key='m707055060@'  # 预设2.4G密码
uci set wireless.@wifi-iface[-1].disabled='1'  # 禁用2.4G接口
uci set wireless.@wifi-device[0].disabled='1'  # 禁用2.4G设备（双重保障）

# ---------------------- 5G WiFi（160MHz+自动信道+隐藏SSID+启用） ----------------------
# 5G 设备基础配置（radio1 为 mediatek/filogic 5G默认节点）
uci set wireless.@wifi-device[1].disabled='0'  # 启用5G设备
uci set wireless.@wifi-device[1].channel='auto'  # 自动选择信道
uci set wireless.@wifi-device[1].htmode='HE160'  # 启用 160MHz 带宽（WiFi 6 特性，mediatek/filogic 平台支持）
uci set wireless.@wifi-device[1].country='CN'  # 中国区信道合规（避免信道受限）

# 5G 接口配置
uci add wireless wifi-iface
uci set wireless.@wifi-iface[-1].device='radio1'
uci set wireless.@wifi-iface[-1].network='lan'
uci set wireless.@wifi-iface[-1].mode='ap'
uci set wireless.@wifi-iface[-1].ssid='dong'  # 与2.4G同名SSID
uci set wireless.@wifi-iface[-1].encryption='psk2'  # 兼容所有设备
uci set wireless.@wifi-iface[-1].key='m707055060@'  # 与2.4G同密码
uci set wireless.@wifi-iface[-1].disabled='0'  # 启用5G接口
uci set wireless.@wifi-iface[-1].hidden='1'  # 隐藏SSID（不广播）

# ====================== 3. 保存配置并生效 ======================
uci commit wireless
wifi reload  # 无需重启，即时应用所有配置

# ====================== 4. 标记初始化完成 ======================
touch /etc/init_done

# 日志记录（可通过 logread 命令查看执行结果）
logger -t "init-script" "首次启动配置完成：root密码已设置；2.4G WiFi（SSID=dong）已配置禁用；5G WiFi（隐藏SSID=dong，160MHz自动信道）已启用"
