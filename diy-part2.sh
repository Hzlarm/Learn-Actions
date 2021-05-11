# 修改openwrt登陆地址,把下面的10.0.0.1修改成你想要的就可以了
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate

# 修改主机名字，把OpenWrt-123修改你喜欢的就行（不能纯数字或者使用中文）
#sed -i '/uci commit system/i\uci set system.@system[0].hostname='OpenWrt-123'' package/lean/default-settings/files/zzz-default-settings
sed -i 's/OpenWrt/Newifi-D2/g' package/base-files/files/bin/config_generate

sed -i 's/ra0/wlan0/g' target/linux/ramips/mt7621/base-files/etc/board.d/01_leds
sed -i 's/rai0/wlan1/g' target/linux/ramips/mt7621/base-files/etc/board.d/01_leds

# 版本号里显示一个自己的名字（281677160 build $(TZ=UTC-8 date "+%Y.%m.%d") @ 这些都是后增加的）
sed -i "s/OpenWrt /Hzlarm build $(TZ=UTC-8 date "+%Y.%m.%d") @ OpenWrt /g" package/lean/default-settings/files/zzz-default-settings

# 修改 argon 为默认主题,可根据你喜欢的修改成其他的（不选择那些会自动改变为默认主题的主题才有效果）
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 设置密码为空（安装固件时无需密码登陆，然后自己修改想要的密码）
#sed -i 's@.*CYXluq4wUazHjmCDBCqXF*@#&@g' package/lean/default-settings/files/zzz-default-settings

# Add kernel build user
[ -z $(grep "CONFIG_KERNEL_BUILD_USER=" .config) ] &&
    echo 'CONFIG_KERNEL_BUILD_USER="Hzlarm"' >>.config ||
    sed -i 's@\(CONFIG_KERNEL_BUILD_USER=\).*@\1$"Hzlarm"@' .config

# Add kernel build domain
[ -z $(grep "CONFIG_KERNEL_BUILD_DOMAIN=" .config) ] &&
    echo 'CONFIG_KERNEL_BUILD_DOMAIN="GitHub Actions"' >>.config ||
    sed -i 's@\(CONFIG_KERNEL_BUILD_DOMAIN=\).*@\1$"GitHub Actions"@' .config

cat >> package/base-files/files/etc/profile <<- 'EOF'
	Target=$([ -f /etc/openwrt_release ] && cat /etc/openwrt_release | awk 'NR==3' | cut -d "'" -f2)
	Version=$([ -f /etc/openwrt_release ] && cat /etc/openwrt_release | awk 'NR==6' | cut -d "'" -f2 || Version=Unknown)
	[ -z "${Target}" ] && Target=$(jsonfilter -e '@.model.id' < /etc/board.json | tr ',' '_')
	IP_Address=$(ifconfig -a | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | tr -d "addr:" | awk 'NR==1')
	CoreMark=$([ -f /etc/bench.log ] && egrep -o "[0-9]+" /etc/bench.log | awk 'NR==1')
	[ -z "${CoreMark}" ] && CoreMark=Unknown
	Startup=$(awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60} {printf("%d 天 %d 小时 %d 分钟\n",a,b,c)}' /proc/uptime)
	Overlay_Available="$(df -h | grep ":/overlay" | awk '{print $4}' | awk 'NR==1')"
	echo -e "\n"
	echo "           设备名称:		$(uname -n) / ${Target}"
	echo "           固件版本:		${Version}"
	echo "           内核版本:		$(uname -rs)"
	echo "           IP 地址 : 		${IP_Address}"
	echo "           运行时间: 		${Startup}"
	echo "           性能得分:		${CoreMark}"
	echo "           可用空间:		${Overlay_Available}"
	echo ""
EOF
