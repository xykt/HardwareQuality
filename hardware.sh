#!/bin/bash
script_version="v2026-05-21"
check_bash(){
current_bash_version=$(bash --version|head -n 1|awk -F ' ' '{for (i=1; i<=NF; i++) if ($i ~ /^[0-9]+\.[0-9]+\.[0-9]+/) {print $i; exit}}'|cut -d . -f 1)
if [ "$current_bash_version" = "0" ]||[ "$current_bash_version" = "1" ]||[ "$current_bash_version" = "2" ]||[ "$current_bash_version" = "3" ];then
echo "ERROR: Bash version is lower than 4.0!"
echo "Tips: Run the following script to automatically upgrade Bash."
echo "bash <(curl -sL https://raw.githubusercontent.com/xykt/HardwareQuality/main/ref/upgrade_bash.sh)"
exit 0
fi
}
check_bash
Font_B="\033[1m"
Font_D="\033[2m"
Font_I="\033[3m"
Font_U="\033[4m"
Font_Black="\033[30m"
Font_Red="\033[31m"
Font_Green="\033[32m"
Font_Yellow="\033[33m"
Font_Blue="\033[34m"
Font_Purple="\033[35m"
Font_Cyan="\033[36m"
Font_White="\033[37m"
Back_Black="\033[40m"
Back_Red="\033[41m"
Back_Green="\033[42m"
Back_Yellow="\033[43m"
Back_Blue="\033[44m"
Back_Purple="\033[45m"
Back_Cyan="\033[46m"
Back_White="\033[47m"
Font_Suffix="\033[0m"
Font_LineClear="\033[2K"
Font_LineUp="\033[1A"
declare ADLines
declare -A aad
declare IP=""
declare IPhide
declare fullinfo=0
declare YY="cn"
declare IPV4
declare IPV6
declare ERRORcode=0
declare shelp
declare -A osinfo
declare -A mbinfo
declare -A cpuinfo
declare -A gpuinfo
declare -A meminfo
declare -A diskinfo
declare -A markinfo
declare -A sinfo
declare -A shead
declare -A sos
declare -A smb
declare -A scpu
declare -A sgpu
declare -A smem
declare -A sdisk
declare -A smark
declare -A stail
declare mode_no=0
declare mode_yes=0
declare mode_json=0
declare mode_menu=0
declare mode_disk=0
declare mode_fast=0
declare mode_fast_dep=" sysbench"
declare mode_skip=""
declare mode_output=0
declare mode_privacy=0
declare mode_verbose=0
declare outputfile=""
declare workdir="$PWD"
declare hwjson
declare ibar=0
declare bar_pid
declare ibar_step=0
declare main_pid=$$
declare PADDING=""
declare rawgithub
shelp_lines=(
"HARDWARE QUALITY CHECK SCRIPT IP质量体检脚本"
"Interactive Interface:  bash <(curl -sL Hardware.Check.Place) -EM"
"交互界面：              bash <(curl -sL Hardware.Check.Place) -M"
"Parameters 参数运行: bash <(curl -sL Hardware.Check.Place) [-d testdir] [-f] [-h] [-j] [-l language] [-n] [-o outputpath] [-p] [-x proxy] [-y] [-D] [-E] [-F] [-M] [-S chapters] [-V]"
"            -d /path/to/testdir/           Specify fio disk test directory            设置fio硬盘测试路径"
"            -f                             No mask sensitive info on reports          报告不隐藏敏感信息"
"            -h                             Help information                           帮助信息"
"            -j                             JSON output                                JSON输出"
"            -l cn|en|jp|es|de|fr|ru|pt     Specify script language                    指定报告语言"
"            -n                             No OS or dependencies check                跳过系统检测及依赖安装"
"            -o /path/to/file.ansi          Output ANSI report to file                 输出ANSI报告至文件"
"               /path/to/file.json          Output JSON result to file                 输出JSON结果至文件"
"               /path/to/file.anyother      Output plain text report to file           输出纯文本报告至文件"
"            -p                             Privacy mode - no generate report link     隐私模式：不生成报告链接"
"            -y                             Install dependencies without interupt      自动安装依赖"
"            -D                             Disk mode                                  硬盘模式"
"            -E                             Specify English Output                     指定英文输出"
"            -F                             Fast mode with no benchmarks               快速检测模式不测试成绩"
"            -M                             Run with Interactive Interface             交互界面方式运行"
"            -S 123456                      Skip sections by number                    跳过相应章节"
"            -V                             Verbose mode to show benchmark details     深度模式：展示全部测试细节")
shelp=$(printf "%s\n" "${shelp_lines[@]}")
set_language(){
case "$YY" in
"en")swarn[1]="ERROR: Unsupported parameters!"
swarn[3]="ERROR: Dependent programs are missing. Please run as root or install sudo!"
swarn[9]="ERROR: It is not allowed to skip all funcions!"
swarn[10]="ERROR: Output file already exist!"
swarn[11]="ERROR: Output file is not writable!"
swarn[12]="ERROR: Test directory is not exist!"
swarn[13]="ERROR: Test directory is not readable or writable!"
sinfo[virt]="Detecting Virtualization Information "
sinfo[os]="Detecting OS Information "
sinfo[mb]="Detecting Matherboard Information "
sinfo[cpu]="Detecting CPU Information "
sinfo[cpubench]="Sysbench CPU Running Test "
sinfo[cpumark]="Geekbench5 CPU "
sinfo[gpu]="Detecting Graphic Information "
sinfo[gpumark]="Geekbench5 GPU "
sinfo[mem]="Detecting Memory Information "
sinfo[membench]="Sysbench Memory Running Test "
sinfo[disk]="Detecting Disk Information "
sinfo[fio]="Fio Test "
sinfo[lvirt]=37
sinfo[los]=25
sinfo[lmb]=34
sinfo[lcpu]=26
sinfo[lcpubench]=26
sinfo[lcpumark]=15
sinfo[lgpu]=30
sinfo[lgpumark]=15
sinfo[lmem]=29
sinfo[lmembench]=29
sinfo[ldisk]=27
sinfo[lfio]=9
shead[title]="HARDWARE QUALITY CHECK REPORT: "
shead[ver]="Version: $script_version"
shead[bash]="bash <(curl -sL https://Check.Place) -EH"
shead[git]="https://github.com/xykt/HardwareQuality"
shead[time_raw]=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
shead[time]="Report Time: ${shead[time_raw]}"
shead[ltitle]=31
shead[ptime]=$(printf '%11s' '')
sos[docker]="Docker container"
sos[podman]="Podman container"
sos[lxc]="LXC container"
sos[lxc-libvirt]="LXC (libvirt) container"
sos[systemd-nspawn]="systemd-nspawn container"
sos[openvz]="OpenVZ container"
sos[rkt]="rkt container"
sos[proot]="proot container"
sos[pouch]="Pouch container"
sos[kvm]="KVM virtual machine"
sos[qemu]="QEMU virtual machine"
sos[amazon]="Amazon EC2 (Nitro/KVM)"
sos[vmware]="VMware virtual machine"
sos[microsoft]="Hyper-V virtual machine"
sos[xen]="Xen virtual machine"
sos[oracle]="VirtualBox virtual machine"
sos[parallels]="Parallels virtual machine"
sos[bhve]="bhyve virtual machine"
sos[uml]="User-Mode Linux"
sos[bochs]="Bochs emulator"
sos[zvm]="IBM z/VM"
sos[powervm]="IBM PowerVM"
sos[qnx]="QNX hypervisor"
sos[acrn]="ACRN hypervisor"
sos[apple]="Apple virtualization framework"
sos[sre]="LMHS SRE hypervisor"
sos[google]="Google Compute Engine"
sos[wsl]="Windows Subsystem for Linux (WSL)"
sos[virtual-machine]="Virtual machine"
sos[physical-machine]="Physical machine"
sos[unknown]="Unknown environment"
sos[title]="1. Operating System Information"
sos[virt]="Virt type:             "
sos[arch]="Architecture:          "
sos[os]="OS / Kernel:           "
sos[uptime]="Uptime:                "
sos[load]="Load:                  "
sos[status]="Processes:             "
sos[loc]="Regional setting:      "
sos[d]="days"
sos[h]="hours"
sos[m]="minutes"
sos[q]=", "
sos[user]="Users"
sos[proc]="Procs"
sos[svc]="Run/All services"
smb[title]="2. Motherboard Information"
smb[mb]="MB:       "
smb[bios]="BIOS:     "
smb[chip]="Chipset:  "
smb[audio]="Audio:    "
smb[net]="Ethernet: "
smb[ver]="Ver:"
smb[s]=""
scpu[title]="3. CPU Review"
scpu[cpu]="CPU:      "
scpu[cache]="Cache:    "
scpu[flag]="Features: "
scpu[temp]="Temp:     "
scpu[sysbench]="Sysbench: "
scpu[base]="GB5 Base: "
scpu[single]="Single:   "
scpu[multi]="Multi:    "
scpu[url]="Details:  "
scpu[singlet]="Single Thread"
scpu[multit]="Multi Threads"
scpu[num]=""
scpu[step]="Step "
scpu[gen]=" Gen"
scpu[core]=" Core"
scpu[thread]=" Thread"
scpu[limit1]=" Limit "
scpu[limit2]=" Procs"
scpu[usage]="Usage "
scpu[min]="Idle "
scpu[max]="Load "
scpu[lnum]=0
scpu[lstep]=0
scpu[lgen]=0
scpu[lcore]=0
scpu[lthread]=0
scpu[llimit]=0
scpu[lusage]=0
sgpu[title]="4. GPU Review"
sgpu[gpu]="Graphics: "
sgpu[ft]="Features: "
sgpu[temp]="Temp:     "
sgpu[base]="GB5Base:  "
sgpu[score]="GB5Score: "
sgpu[url]="Details:  "
sgpu[1]="Discrete"
sgpu[0]="Integrated"
sgpu[driver]="Driver"
sgpu[min]="Idle "
sgpu[max]="Load "
smem[title]="5. Memory Review"
smem[mem]="Memory:   "
smem[swap]="Swap:     "
smem[reuse]="Overcmmt: "
smem[nb]="Neighbor: "
smem[sysbench]="Sysbench: "
smem[total]="Total"
smem[used]="Used"
smem[avail]="Available"
smem[balloon]="Balloon"
smem[ksm]="KSM Reuse"
smem[nbnum]="Containers"
smem[read]="Read"
smem[write]="Write"
smem[lat]="Latency"
smem[ltotal]=0
sdisk[title]="6. Disk Review"
sdisk[disk]="Disks:    "
sdisk[dir]="Test Dev: "
sdisk[fio]="Fio Test: "
sdisk[crystal]="Crystal:  "
sdisk[atto]="ATTO:     "
sdisk[read]="Read:     "
sdisk[write]="Write:    "
sdisk[count]="Count "
sdisk[total]="Total "
sdisk[used]="Used "
sdisk[avail]="Available "
sdisk[po]="PwrOn "
sdisk[times]=""
sdisk[lf]="Lf"
sdisk[sp]="Sp"
sdisk[lcount]=0
sdisk[ltotal]=0
sdisk[lused]=0
sdisk[lavail]=0
sdisk[lpo]=0
sdisk[llf]=0
sdisk[lsp]=0
smark[title]="7. HQ Weighted Hardware Benchmark"
smark[item]="Items:    "
smark[mark]="Score:    "
smark[pct]="Ranking:  "
smark[total]="Total"
smark[mem]="Memory"
smark[disk]="Disk"
smark[ltotal]=5
smark[lmem]=6
smark[ldisk]=4
stail[stoday]="Hardware Checks Today: "
stail[stotal]="; Total: "
stail[thanks]=". Thanks for running xy scripts!"
stail[link]="${Font_I}Report Link: $Font_U"
;;
"cn")swarn[1]="错误：不支持的参数！"
swarn[3]="错误：未安装依赖程序，请以root执行此脚本，或者安装sudo命令！"
swarn[9]="错误: 不允许跳过所有功能！"
swarn[10]="错误：输出文件已存在！"
swarn[11]="错误：输出文件不可写！"
swarn[12]="错误：测试目录不存在！"
swarn[13]="错误：测试目录不可读写！"
sinfo[virt]="正在获取虚拟化信息"
sinfo[os]="正在获取操作系统信息"
sinfo[mb]="正在获取主板信息"
sinfo[cpu]="正在获取CPU信息"
sinfo[cpubench]="Sysbench CPU测试 "
sinfo[cpumark]="Geekbench5 CPU "
sinfo[gpu]="正在获取显卡信息"
sinfo[gpumark]="Geekbench5 GPU "
sinfo[mem]="正在获取内存信息"
sinfo[membench]="Sysbench 内存测试 "
sinfo[disk]="正在获取硬盘信息"
sinfo[fio]="Fio测试 "
sinfo[lvirt]=18
sinfo[los]=20
sinfo[lmb]=16
sinfo[lcpu]=15
sinfo[lcpubench]=17
sinfo[lcpumark]=15
sinfo[lgpu]=16
sinfo[lgpumark]=15
sinfo[lmem]=16
sinfo[lmembench]=18
sinfo[ldisk]=16
sinfo[lfio]=8
shead[title]="硬件质量体检报告："
shead[title_lite]="IP质量体检报告(Lite)："
shead[ver]="脚本版本：$script_version"
shead[bash]="bash <(curl -sL https://Check.Place) -H"
shead[git]="https://github.com/xykt/HardwareQuality"
shead[time_raw]=$(TZ="Asia/Shanghai" date +"%Y-%m-%d %H:%M:%S CST")
shead[time]="报告时间：${shead[time_raw]}"
shead[ltitle]=18
shead[ptime]=$(printf '%12s' '')
sos[virt]="容器/虚拟化：          "
sos[arch]="架构：                 "
sos[os]="操作系统/内核：        "
sos[uptime]="运行时间：             "
sos[load]="负载：                 "
sos[status]="进程：                 "
sos[loc]="区域设置：             "
sos[docker]="Docker 容器"
sos[podman]="Podman 容器"
sos[lxc]="LXC 容器"
sos[lxc-libvirt]="LXC(libvirt) 容器"
sos[systemd-nspawn]="systemd-nspawn 容器"
sos[openvz]="OpenVZ 容器"
sos[rkt]="rkt 容器"
sos[proot]="proot 容器"
sos[pouch]="Pouch 容器"
sos[kvm]="KVM 虚拟机"
sos[qemu]="QEMU 虚拟机"
sos[amazon]="Amazon EC2（Nitro/KVM）"
sos[vmware]="VMware 虚拟机"
sos[microsoft]="Hyper-V 虚拟机"
sos[xen]="Xen 虚拟机"
sos[oracle]="VirtualBox 虚拟机"
sos[parallels]="Parallels 虚拟机"
sos[bhve]="bhyve 虚拟机"
sos[uml]="User-Mode Linux"
sos[bochs]="Bochs 模拟器"
sos[zvm]="IBM z/VM"
sos[powervm]="IBM PowerVM"
sos[qnx]="QNX Hypervisor"
sos[acrn]="ACRN Hypervisor"
sos[apple]="Apple Virtualization"
sos[sre]="LMHS SRE Hypervisor"
sos[google]="Google Compute Engine"
sos[wsl]="WSL（Windows Subsystem for Linux）"
sos[virtual-machine]="虚拟机"
sos[physical-machine]="物理机"
sos[unknown]="未知环境"
sos[title]="一、操作系统信息"
sos[d]="天"
sos[h]="小时"
sos[m]="分钟"
sos[q]="，"
sos[user]="用户"
sos[proc]="进程"
sos[svc]="活跃/总服务"
smb[title]="二、主板信息"
smb[mb]="主板：    "
smb[bios]="BIOS：    "
smb[chip]="芯片组：  "
smb[audio]="声卡：    "
smb[net]="网卡：    "
smb[ver]="版本"
smb[s]="个"
scpu[title]="三、CPU测评"
scpu[cpu]="CPU：     "
scpu[cache]="缓存：    "
scpu[flag]="指令集：  "
scpu[temp]="温度：    "
scpu[sysbench]="Sysbench："
scpu[geekbench]="GB5成绩： "
scpu[url]="详细结果："
scpu[singlet]="单线程"
scpu[multit]="多线程"
scpu[base]="GB5基准： "
scpu[single]="GB5单核： "
scpu[multi]="GB5多核： "
scpu[num]="颗"
scpu[step]="步进"
scpu[gen]="代"
scpu[core]="核心"
scpu[thread]="线程"
scpu[limit1]="限制"
scpu[limit2]="进程"
scpu[usage]="利用率"
scpu[min]="待机 "
scpu[max]="负载 "
scpu[lnum]=1
scpu[lstep]=2
scpu[lgen]=1
scpu[lcore]=2
scpu[lthread]=2
scpu[llimit]=4
scpu[lusage]=3
sgpu[title]="四、显卡测评"
sgpu[gpu]="显卡：    "
sgpu[ft]="特性：    "
sgpu[temp]="温度：    "
sgpu[base]="GB5基准： "
sgpu[score]="GB5成绩： "
sgpu[url]="详细结果："
sgpu[1]="独显"
sgpu[0]="集显"
sgpu[driver]="驱动程序"
sgpu[min]="待机 "
sgpu[max]="负载 "
smem[title]="五、内存测评"
smem[mem]="内存：    "
smem[swap]="交换：    "
smem[reuse]="超开指标："
smem[nb]="邻居数量："
smem[sysbench]="Sysbench："
smem[total]="总容量"
smem[used]="已用"
smem[avail]="可用"
smem[balloon]="气球回收"
smem[ksm]="KSM 复用"
smem[nbnum]="个容器"
smem[read]="读取"
smem[write]="写入"
smem[lat]="延迟"
smem[ltotal]=7
sdisk[title]="六、硬盘测评"
sdisk[disk]="硬盘：    "
sdisk[dir]="测试设备："
sdisk[fio]="Fio测试： "
sdisk[crystal]="Crystal： "
sdisk[atto]="ATTO：    "
sdisk[read]="读取：    "
sdisk[write]="写入：    "
sdisk[count]="数量 "
sdisk[total]="总容量 "
sdisk[used]="已用容量 "
sdisk[avail]="可用容量 "
sdisk[po]="通电"
sdisk[times]="次"
sdisk[lf]="寿"
sdisk[sp]="备"
sdisk[lcount]=2
sdisk[ltotal]=3
sdisk[lused]=4
sdisk[lavail]=4
sdisk[lpo]=3
sdisk[llf]=1
sdisk[lsp]=1
smark[title]="七、HQ硬件加权评分"
smark[item]="项目：    "
smark[mark]="分数：    "
smark[pct]="排名：    "
smark[total]="总 分"
smark[mem]="内 存"
smark[disk]="硬 盘"
smark[ltotal]=5
smark[lmem]=5
smark[ldisk]=5
stail[stoday]="今日硬件检测量："
stail[stotal]="；总检测量："
stail[thanks]="。感谢使用xy系列脚本！"
stail[link]="$Font_I报告链接：$Font_U"
;;
*)echo -ne "ERROR: Language not supported!"
esac
}
countRunTimes(){
local RunTimes=$(curl $CurlARG -s --max-time 10 "https://hits.xykt.de/hardware?action=hit" 2>&1)
stail[today]=$(echo "$RunTimes"|jq '.daily')
stail[total]=$(echo "$RunTimes"|jq '.total')
}
show_progress_bar(){
show_progress_bar_ "$@" 1>&2
}
show_progress_bar_(){
local bar="\u280B\u2819\u2839\u2838\u283C\u2834\u2826\u2827\u2807\u280F"
local n=${#bar}
local tmpinfo=""
local tmplen=$(($2))
local last_stage=""
local upload_seen=0
while sleep 0.1;do
if ! kill -0 "$main_pid" 2>/dev/null;then
echo -ne ""
exit
fi
if ((upload_seen==0))&&[[ -n $3 ]];then
while IFS= read -r -t 0.05 line;do
[[ -z $line ]]&&continue
if [[ $3 -eq 1 ]];then
if [[ $line == *"Uploading results"* ]];then
upload_seen=1
break
fi
case "$line" in
*"Running"*)last_stage="${line#"${line%%[![:space:]]*}"}"
esac
elif [[ $3 -eq 2 ]];then
last_stage="$line"
fi
done
fi
if ((upload_seen==0))&&[[ -n $last_stage ]];then
tmpinfo="$last_stage"
else
tmpinfo=""
fi
tmplen=$(($2-${#tmpinfo}))
((tmplen<0))&&tmplen=0
echo -ne "\r$Font_Cyan$Font_B[$IP]# $1$tmpinfo""$Font_Cyan$Font_B$(printf '%*s' "$tmplen" ''|tr ' ' '.') ""${bar:ibar++*6%n:6} $(printf '%02d%%' $ibar_step) $Font_Suffix"
done
}
kill_progress_bar(){
kill "$bar_pid" 2>/dev/null&&echo -ne "\r"
}
install_dependencies(){
local is_dep=1
local is_geekbench5=1
local is_curl_impersonate=1
local is_darwin=0
[[ "$(uname)" == "Darwin" ]]&&is_darwin=1
if ! tar --version >/dev/null 2>&1||! jq --version >/dev/null 2>&1||! curl --version >/dev/null 2>&1||! bc --version >/dev/null 2>&1||(! dmidecode --version >/dev/null 2>&1&&[ "$is_darwin" -eq 0 ])||(! sensors --version >/dev/null 2>&1&&[ "$is_darwin" -eq 0 ])||(! lspci --version >/dev/null 2>&1&&[ "$is_darwin" -eq 0 ])||(! lscpu --version >/dev/null 2>&1&&[ "$is_darwin" -eq 0 ])||! smartctl --version >/dev/null 2>&1||! fio --version >/dev/null 2>&1||(! sysbench --version >/dev/null 2>&1&&[ "${mode_fast:-0}" -eq 0 ])||(! command -v update-ca-certificates >/dev/null 2>&1&&[ "${mode_verbose:-0}" -eq 1 ]);then
is_dep=0
fi
if ! command -v geekbench5 >/dev/null 2>&1&&[[ ${mode_fast:-0} -eq 0 && ${mode_privacy:-0} -eq 0 ]];then
is_geekbench5=0
fi
if ! command -v curl-impersonate >/dev/null 2>&1&&[[ ${mode_fast:-0} -eq 0 && ${mode_privacy:-0} -eq 0 && ${mode_verbose:-0} -eq 1 ]];then
is_curl_impersonate=0
fi
if [[ $is_dep -eq 0 || $is_geekbench5 -eq 0 || $is_curl_impersonate -eq 0 ]];then
echo -e "Lacking necessary dependencies."
[[ $is_dep -eq 0 ]]&&echo -e "Packages $Font_I${Font_Cyan}tar jq curl bc dmidecode sensors pciutils util-linux smartmontools fio$mode_fast_dep$Font_Suffix will be installed using package manager$Font_Suffix."
[[ $is_geekbench5 -eq 0 ]]&&echo -e "Application $Font_I${Font_Cyan}Geekbench5$Font_Suffix will be downloaded from ${Font_B}Geekbench.com$Font_Suffix and installed to folder $Font_U/usr/local/bin$Font_Suffix."
[[ $is_curl_impersonate -eq 0 ]]&&echo -e "Application $Font_I${Font_Cyan}curl-impersonate$Font_Suffix will be installed using ${Font_B}github.com/lexiforest/curl-impersonate$Font_Suffix release ${Font_U}v1.5.6$Font_Suffix to folder $Font_U/usr/local/bin$Font_Suffix."
if [[ $mode_yes -eq 0 ]];then
prompt=$(printf "Continue? (${Font_Green}y$Font_Suffix/${Font_Red}n$Font_Suffix): ")
read -p "$prompt" choice
case "$choice" in
y|Y|yes|Yes|YES)echo "Continue to install dependencies..."
;;
n|N|no|No|NO)echo "Script exited."
exit 0
;;
*)echo "Invalid input, script exited."
exit 1
esac
else
echo -e "Detected parameter $Font_Green-y$Font_Suffix. Continue installation..."
fi
if [[ $is_dep -eq 0 ]];then
if [ "$(uname)" == "Darwin" ];then
install_packages "brew" "brew install" "no_sudo"
elif [ -f /etc/os-release ];then
. /etc/os-release
if [ $(id -u) -ne 0 ]&&! command -v sudo >/dev/null 2>&1;then
ERRORcode=3
fi
case $ID in
ubuntu|debian|linuxmint)install_packages "apt" "apt-get install -y"
;;
rhel|centos|almalinux|rocky|anolis)if
[ "$(echo $VERSION_ID|cut -d '.' -f1)" -ge 8 ]
then
install_packages "dnf" "dnf install -y"
else
install_packages "yum" "yum install -y"
fi
;;
arch|manjaro)install_packages "pacman" "pacman -S --noconfirm"
;;
alpine)install_packages "apk" "apk add"
;;
fedora)install_packages "dnf" "dnf install -y"
;;
alinux)install_packages "yum" "yum install -y"
;;
suse|opensuse*)install_packages "zypper" "zypper install -y"
;;
void)install_packages "xbps" "xbps-install -Sy"
;;
*)echo "Unsupported distribution: $ID"
exit 1
esac
elif [ -n "$PREFIX" ];then
install_packages "pkg" "pkg install"
else
echo "Cannot detect distribution because /etc/os-release is missing."
exit 1
fi
fi
if [[ $is_geekbench5 -eq 0 ]];then
install_geekbench5
fi
if [[ $is_curl_impersonate -eq 0 ]];then
install_curl_impersonate
fi
fi
}
install_packages(){
local package_manager=$1
local install_command=$2
local no_sudo=$3
if [ "$no_sudo" == "no_sudo" ]||[ $(id -u) -eq 0 ];then
local usesudo=""
else
local usesudo="sudo"
fi
case $package_manager in
apt)$usesudo apt update
$usesudo $install_command tar jq curl bc dmidecode lm-sensors pciutils util-linux smartmontools fio ca-certificates $mode_fast_dep
;;
dnf|yum)$usesudo $install_command epel-release
$usesudo $package_manager makecache
$usesudo $install_command tar jq curl bc dmidecode lm-sensors pciutils util-linux smartmontools fio ca-certificates $mode_fast_dep
;;
pacman)$usesudo pacman -Sy
$usesudo $install_command tar jq curl bc dmidecode lm-sensors pciutils util-linux smartmontools fio ca-certificates $mode_fast_dep
;;
apk)$usesudo apk update
$usesudo $install_command tar jq curl bc dmidecode lm-sensors pciutils util-linux smartmontools fio ca-certificates $mode_fast_dep
;;
pkg)$usesudo $package_manager update
$usesudo $package_manager $install_command tar jq curl bc dmidecode lm-sensors pciutils util-linux smartmontools fio ca-certificates $mode_fast_dep
;;
brew)eval "$(/opt/homebrew/bin/brew shellenv)"
$install_command tar jq curl bc smartmontools fio ca-certificates $mode_fast_dep
;;
zypper)$usesudo zypper refresh
$usesudo $install_command tar jq curl bc dmidecode sensors pciutils util-linux smartmontools fio ca-certificates $mode_fast_dep
;;
xbps)$usesudo xbps-install -Sy
$usesudo $install_command tar jq curl bc dmidecode lm-sensors pciutils util-linux smartmontools fio ca-certificates $mode_fast_dep
esac
}
install_geekbench5(){
local GB_VER="5.5.1"
local GB_BASE_URL="https://cdn.geekbench.com"
local tmpdir arch pkg url
local usesudo=""
if [ "$(id -u)" -ne 0 ];then
if command -v sudo >/dev/null 2>&1;then
usesudo="sudo"
else
echo "Error: need root privileges to install Geekbench5."
return 1
fi
fi
case "$(uname -m)" in
x86_64|amd64|i386|i686)arch="i386/amd64"
pkg_arch="Linux"
;;
aarch64|arm64|armv7l|armv6l)arch="ARM"
pkg_arch="LinuxARMPreview"
;;
*)echo "Unsupported architecture: $(uname -m)"
return 1
esac
pkg="Geekbench-$GB_VER-$pkg_arch.tar.gz"
url="$GB_BASE_URL/$pkg"
echo "Downloading Geekbench 5 ($arch) ..."
tmpdir="$(mktemp -d)"||return 1
cleanup_local(){
if [[ -n $tmpdir ]];then
rm -f "$tmpdir/$pkg" 2>/dev/null
rmdir "$tmpdir" 2>/dev/null
fi
}
on_int(){
cleanup_local
echo ""
exit 130
}
on_term(){
cleanup_local
echo ""
exit 143
}
trap cleanup_local RETURN
trap on_int INT
trap on_term TERM
if ! curl -L --fail -o "$tmpdir/$pkg" "$url";then
echo "Failed to download Geekbench5."
return 1
fi
if ! $usesudo tar -xf "$tmpdir/$pkg" -C /usr/local/bin;then
echo "Failed to extract Geekbench5 to /usr/local/bin."
return 1
fi
local dst_dir="/usr/local/bin/Geekbench-$GB_VER-$pkg_arch"
if [ ! -d "$dst_dir" ];then
echo "Geekbench directory not found after extraction."
return 1
fi
case "$(uname -m)" in
aarch64|arm64)rm -f "/usr/local/bin/Geekbench-$GB_VER-$pkg_arch/geekbench_armv7"
;;
armv7l|armv6l)rm -f "/usr/local/bin/Geekbench-$GB_VER-$pkg_arch/geekbench_aarch64"
esac
$usesudo chmod +x "$dst_dir/geekbench5"
if [ ! -e /usr/local/bin/geekbench5 ];then
$usesudo ln -s "$dst_dir/geekbench5" /usr/local/bin/geekbench5
fi
}
install_curl_impersonate(){
local arch
local sys_type
arch=$(uname -m)
case "$arch" in
x86_64)if
[[ "$(getconf LONG_BIT)" == "32" ]]
then
sys_type="i386"
else
sys_type="x86_64"
fi
;;
aarch64|arm64)sys_type="aarch64"
;;
i386|i486|i586|i686)sys_type="i386"
;;
riscv64)sys_type="riscv64"
;;
*)return 1
esac
$usesudo curl -sL -o /usr/local/bin/curl-impersonate "${rawgithub}main/ref/curl-impersonate/curl-impersonate-$sys_type"
$usesudo chmod +x /usr/local/bin/curl-impersonate
}
adaptoslocale(){
local ifunicode=$(printf '\u2800')
[[ ${#ifunicode} -gt 3 ]]&&export LC_CTYPE=en_US.UTF-8 2>/dev/null
}
check_connectivity(){
local url="https://www.google.com/generate_204"
local timeout=2
local http_code
http_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout "$timeout" "$url" 2>/dev/null)
if [[ $http_code == "204" ]];then
rawgithub="https://github.com/xykt/HardwareQuality/raw/"
return 0
else
rawgithub="https://testingcf.jsdelivr.net/gh/xykt/HardwareQuality@"
return 1
fi
}
get_ipv4(){
local response
IPV4=""
local API_NET=("myip.check.place" "ip.sb" "ping0.cc" "icanhazip.com" "api64.ipify.org" "ifconfig.co" "ident.me")
for p in "${API_NET[@]}";do
response=$(curl $CurlARG -s4 --max-time 2 "$p")
if [[ $? -eq 0 && ! $response =~ error && -n $response ]];then
IPV4="$response"
break
fi
done
}
hide_ipv4(){
if [[ -n $1 ]];then
IFS='.' read -r -a ip_parts <<<"$1"
IPhide="${ip_parts[0]}.${ip_parts[1]}.*.*"
else
IPhide=""
fi
}
get_ipv6(){
local response
IPV6=""
local API_NET=("myip.check.place" "ip.sb" "ping0.cc" "icanhazip.com" "api64.ipify.org" "ifconfig.co" "ident.me")
for p in "${API_NET[@]}";do
response=$(curl $CurlARG -s6k --max-time 2 "$p")
if [[ $? -eq 0 && ! $response =~ error && -n $response ]];then
IPV6="$response"
break
fi
done
}
hide_ipv6(){
if [[ -n $1 ]];then
local expanded_ip=$(echo "$1"|sed 's/::/:0000:0000:0000:0000:0000:0000:0000:0000:/g'|cut -d ':' -f1-8)
IFS=':' read -r -a ip_parts <<<"$expanded_ip"
while [ ${#ip_parts[@]} -lt 8 ];do
ip_parts+=(0000)
done
IPhide="${ip_parts[0]:-0}:${ip_parts[1]:-0}:${ip_parts[2]:-0}:*:*:*:*:*"
IPhide=$(echo "$IPhide"|sed 's/:0\{1,\}/:/g'|sed 's/::\+/:/g')
else
IPhide=""
fi
}
calculate_display_width(){
local string="$1"
local length=0
local char
for ((i=0; i<${#string}; i++));do
char=$(echo "$string"|od -An -N1 -tx1 -j $((i))|tr -d ' ')
if [ "$(printf '%d\n' 0x$char)" -gt 127 ];then
length=$((length+2))
i=$((i+1))
else
length=$((length+1))
fi
done
echo "$length"
}
calc_padding(){
local input_text="$1"
local total_width=$2
local title_length=$(calculate_display_width "$input_text")
local left_padding=$(((total_width-title_length)/2))
if [[ $left_padding -gt 0 ]];then
PADDING=$(printf '%*s' $left_padding)
else
PADDING=""
fi
}
kill_test(){
kill "$1" 2>/dev/null
}
detect_virt(){
local dv_os dv_sdv dv_env1 _pn
local dv_virt="physical-machine"
dv_os="$(uname -s 2>/dev/null)"
if [[ $dv_os == "Linux" ]];then
[[ -f /.dockerenv ]]&&{
echo "docker"
return 0
}
[[ -f /run/.containerenv ]]&&{
echo "podman"
return 0
}
if command -v systemd-detect-virt >/dev/null 2>&1;then
dv_sdv="$(systemd-detect-virt 2>/dev/null)"
case "$dv_sdv" in
none|"");;
*)echo "$dv_sdv"
return 0
esac
fi
if [[ -r /proc/1/environ ]];then
dv_env1="$(tr '\0' '\n' </proc/1/environ 2>/dev/null)"
case "$dv_env1" in
*container=lxc*)echo "lxc"
return 0
;;
*container=lxd*)echo "lxd"
return 0
;;
*container=systemd-nspawn*)echo "systemd-nspawn"
return 0
esac
fi
if grep -qw hypervisor /proc/cpuinfo 2>/dev/null;then
if [[ -r /sys/devices/virtual/dmi/id/product_name ]];then
_pn="$(cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null)"
case "$_pn" in
*VMware*)echo "vmware"
return 0
;;
*VirtualBox*)echo "oracle"
return 0
;;
*Parallels*)echo "parallels"
return 0
;;
*HVM*domU*|*Xen*)echo "xen"
return 0
;;
*Amazon*EC2*)echo "amazon"
return 0
;;
*Google*Compute*Engine*)echo "google"
return 0
;;
*KVM*|*Standard\ PC*|*Q35*|*i440FX*)echo "kvm"
return 0
;;
*Microsoft*|*Virtual\ Machine*)echo "microsoft"
return 0
;;
*BHYVE*)echo "bhve"
return 0
;;
*Bochs*)echo "bochs"
return 0
esac
fi
echo "virtual-machine"
return 0
fi
echo "$dv_virt"
return 0
fi
if [[ $dv_os == "Darwin" ]];then
if sysctl -n kern.hv_vmm_present 2>/dev/null|grep -q '^1$';then
echo "virtual-machine"
else
echo "$dv_virt"
fi
return 0
fi
echo "unknown"
return 0
}
classify_virt_kind(){
case "$1" in
docker|podman|lxc|lxd|systemd-nspawn|openvz|rkt|proot|pouch)echo "container"
;;
kvm|qemu|vmware|wsl|microsoft|xen|oracle|parallels|bhve|bochs|amazon|google|virtual-machine)echo "virtual-machine"
;;
physical-machine)echo "physical-machine"
;;
*)echo "unknown"
esac
}
get_virt(){
local temp_info="$Font_Cyan$Font_B${sinfo[virt]}$Font_Suffix"
((ibar_step+=1))
show_progress_bar "$temp_info" $((55-${sinfo[lvirt]}))&
bar_pid="$!"&&disown "$bar_pid"
trap "kill_progress_bar" RETURN
osinfo[virt]="$(detect_virt)"
osinfo[virt_kind]="$(classify_virt_kind "${osinfo[virt]}")"
}
calc_uptime(){
local total_sec
total_sec="$(awk '{print int($1)}' /proc/uptime 2>/dev/null)"
[[ -z $total_sec ]]&&total_sec=0
osinfo[d]=$((total_sec/86400))
osinfo[h]=$(((total_sec%86400)/3600))
osinfo[m]=$(((total_sec%3600)/60))
}
colorize_load(){
local lv="$1"
local cores="$2"
awk -v l="$lv" -v c="$cores" \
-v R="$Font_Red" -v Y="$Font_Yellow" -v G="$Font_Green" -v S="$Font_Suffix" '
    BEGIN {
        if (l < c)
            printf "%s%.2f%s", G, l, S
        else if (l < 2*c)
            printf "%s%.2f%s", Y, l, S
        else
            printf "%s%.2f%s", R, l, S
    }'
}
get_os(){
local temp_info="$Font_Cyan$Font_B${sinfo[os]}$Font_Suffix"
((ibar_step+=2))
show_progress_bar "$temp_info" $((55-${sinfo[los]}))&
bar_pid="$!"&&disown "$bar_pid"
trap "kill_progress_bar" RETURN
osinfo[os]="$(grep '^PRETTY_NAME=' /etc/os-release 2>/dev/null|cut -d= -f2|tr -d '"')"
osinfo[kernel]="$(uname -r)"
osinfo[arch]="$(uname -m)"
calc_uptime
read osinfo[load1] osinfo[load5] osinfo[load15] <<<"$(uptime|awk -F'load average:' '{gsub(/^[[:space:]]+/, "", $2); gsub(/,/, "", $2); print $2}')"
local cpu_cores="$(getconf _NPROCESSORS_ONLN 2>/dev/null)"
[[ -z $cpu_cores || ! $cpu_cores =~ ^[0-9]+$ ]]&&cpu_cores=1
sos[load1]="$(colorize_load "${osinfo[load1]}" "$cpu_cores")"
sos[load5]="$(colorize_load "${osinfo[load5]}" "$cpu_cores")"
sos[load15]="$(colorize_load "${osinfo[load15]}" "$cpu_cores")"
if [[ -z ${osinfo[user]} ]];then
local tmpuc=""
if command -v loginctl >/dev/null 2>&1;then
tmpuc="$(loginctl list-users 2>/dev/null|tail -n +2|wc -l|tr -d ' ')"
[[ $tmpuc -gt 0 ]]&&osinfo[user]="$tmpuc"
elif [[ "$(uname -s)" == "Darwin" ]];then
tmpuc="$(stat -f '%Su' /dev/console 2>/dev/null|wc -l|tr -d ' ')"
[[ $tmpuc -gt 0 ]]&&osinfo[user]="$tmpuc"
else
tmpuc="$(who 2>/dev/null|wc -l|tr -d ' ')"
[[ $tmpuc -gt 0 ]]&&osinfo[user]="$tmpuc"
fi
fi
[[ -z ${osinfo[proc]} ]]&&osinfo[proc]=$(ps -e 2>/dev/null|wc -l|tr -d ' ')
[[ ${osinfo[proc]} -gt 0 ]]&&osinfo[proc]=$((osinfo[proc]-1))
if [[ -z ${osinfo[svcr]} && -z ${osinfo[svct]} ]];then
if [[ ${osinfo[virt]} == "docker" || ${osinfo[virt]} == "podman" ]]&&[[ "$(ps -p 1 -o comm= 2>/dev/null)" != "systemd" ]];then
osinfo[svcr]=""
osinfo[svct]=""
elif command -v systemctl >/dev/null 2>&1;then
osinfo[svcr]=$(systemctl list-units --type=service --state=running 2>/dev/null|grep '\.service'|wc -l|tr -d ' ')
osinfo[svct]=$(systemctl list-unit-files --type=service 2>/dev/null|grep '\.service'|wc -l|tr -d ' ')
elif command -v rc-service >/dev/null 2>&1;then
osinfo[svcr]=$(rc-service -r 2>/dev/null|wc -l|tr -d ' ')
osinfo[svct]=$(rc-service -l 2>/dev/null|wc -l|tr -d ' ')
elif [[ "$(uname -s)" == "Darwin" ]]&&command -v launchctl >/dev/null 2>&1;then
osinfo[svcr]=$(launchctl list 2>/dev/null|tail -n +2|wc -l|tr -d ' ')
osinfo[svct]="${osinfo[svcr]}"
else
osinfo[svcr]=""
osinfo[svct]=""
fi
fi
local osloc=""
if command -v localectl >/dev/null 2>&1;then
osloc="$(timeout 2 localectl status 2>/dev/null|awk -F= '/System Locale/ {print $2}'|head -n1)"
fi
if [[ -z $osloc && -r /etc/locale.conf ]];then
osloc="$(grep -E '^(LANG|LC_CTYPE)=' /etc/locale.conf|head -n1|cut -d= -f2)"
fi
if [[ -z $osloc ]];then
osloc="$(locale 2>/dev/null|awk -F= '/^LANG=/ {print $2}')"
fi
osloc="${osloc%\"}"
osloc="${osloc#\"}"
if [[ -z $osloc || $osloc == "C" || $osloc == "POSIX" ]];then
osinfo[lang]="C"
osinfo[charset]="UTF-8"
else
osinfo[lang]="${osloc%%.*}"
osinfo[charset]="${osloc#*.}"
[[ ${osinfo[charset]} == "$osloc" ]]&&osinfo[charset]="UTF-8"
fi
osinfo[tz]=""
if command -v timedatectl >/dev/null 2>&1;then
local tmptz="$(timeout 2 timedatectl show -p Timezone --value 2>/dev/null)"
if [[ -n $tmptz ]];then
osinfo[tz]="$tmptz "
fi
fi
if [[ -z ${osinfo[tz]} && -r /etc/timezone ]];then
osinfo[tz]="$(cat /etc/timezone) "
fi
if [[ -z ${osinfo[tz]} && -L /etc/localtime ]];then
osinfo[tz]="$(readlink /etc/localtime|sed 's|.*/zoneinfo/||') "
fi
[[ ${osinfo[tz]} == "UTC " ]]&&true
osinfo[tz_abbr]="$(date +%Z 2>/dev/null)"
osinfo[tz_offset]="$(date +%z 2>/dev/null)"
}
get_mb(){
local temp_info="$Font_Cyan$Font_B${sinfo[mb]}$Font_Suffix"
((ibar_step+=2))
show_progress_bar "$temp_info" $((55-${sinfo[lmb]}))&
bar_pid="$!"&&disown "$bar_pid"
trap "kill_progress_bar" RETURN
mbinfo[os]="$(uname -s)"
if [[ ${mbinfo[os]} == "Linux" || ${mbinfo[os]} =~ BSD ]];then
if command -v dmidecode >/dev/null 2>&1&&[[ $EUID -eq 0 ]];then
mbinfo[board_vendor]="$(dmidecode -s baseboard-manufacturer 2>/dev/null)"
mbinfo[board_name]="$(dmidecode -s baseboard-product-name 2>/dev/null)"
mbinfo[board_version]="$(dmidecode -s baseboard-version 2>/dev/null)"
mbinfo[board_serial]="$(dmidecode -s baseboard-serial-number 2>/dev/null)"
mbinfo[bios_vendor]="$(dmidecode -s bios-vendor 2>/dev/null)"
mbinfo[bios_version]="$(dmidecode -s bios-version 2>/dev/null)"
fi
SYSFS="/sys/class/dmi/id"
if [[ -d $SYSFS ]];then
[[ -z ${mbinfo[board_vendor]} ]]&&mbinfo[board_vendor]="$(cat $SYSFS/board_vendor 2>/dev/null)"
[[ -z ${mbinfo[board_name]} ]]&&mbinfo[board_name]="$(cat $SYSFS/board_name 2>/dev/null)"
[[ -z ${mbinfo[board_version]} ]]&&mbinfo[board_version]="$(cat $SYSFS/board_version 2>/dev/null)"
[[ -z ${mbinfo[board_serial]} ]]&&mbinfo[board_serial]="$(cat $SYSFS/board_serial 2>/dev/null)"
[[ -z ${mbinfo[bios_vendor]} ]]&&mbinfo[bios_vendor]="$(cat $SYSFS/bios_vendor 2>/dev/null)"
[[ -z ${mbinfo[bios_version]} ]]&&mbinfo[bios_version]="$(cat $SYSFS/bios_version 2>/dev/null)"
fi
elif [[ ${mbinfo[os]} == "Darwin" ]];then
SP="$(system_profiler SPHardwareDataType 2>/dev/null)"
mbinfo[board_vendor]="Apple Inc."
mbinfo[board_name]="$(echo "$SP"|awk -F": " '/Model Identifier/ {print $2}')"
mbinfo[bios_version]="$(echo "$SP"|awk -F": " '/Boot ROM Version/ {print $2}')"
mbinfo[bios_vendor]="Apple Boot ROM"
mbinfo[board_version]=""
fi
if command -v lspci >/dev/null 2>&1;then
mbinfo[pci_root]="$(lspci|grep -Ei 'Host bridge|Root Complex'|head -n1|sed -E 's/^[^:]*:[^:]*:[[:space:]]*//; s/[[:space:]]*\(rev [^)]+\)//'|sed "s/Advanced Micro Devices, Inc. //g"|sed "s/Corporation //g")"
mbinfo[pch_device]="$(lspci|grep -Ei 'ISA bridge|LPC Controller|SMBus|FCH|PCH'|head -n1|sed -E 's/^[^:]*:[^:]*:[[:space:]]*//; s/[[:space:]]*\(rev [^)]+\)//'|sed "s/Advanced Micro Devices, Inc. //g"|sed "s/Corporation //g")"
mbinfo[audio_devices]="$(lspci|grep -E '^[0-9a-fA-F:.]+[[:space:]]+Audio'|sed -E 's/^[^:]*:[^:]*:[[:space:]]*//; s/[[:space:]]*\(rev [^)]+\)//'|sed "s/Advanced Micro Devices, Inc. //g"|sed "s/Corporation //g"|sed "s/ Series//g")"
mbinfo[net_devices]="$(lspci|grep -E '^[0-9a-fA-F:.]+[[:space:]]+(Ethernet|Network)'|sed -E 's/^[^:]*:[^:]*:[[:space:]]*//; s/[[:space:]]*\(rev [^)]+\)//'|sed "s/Advanced Micro Devices, Inc. //g"|sed "s/Corporation //g"|sed "s/Corporation //g"|sed "s/ Series//g")"
fi
mbinfo[board_version]="$(echo "${mbinfo[board_version]}"|sed -E 's/[[:space:]]*default[[:space:]]+string[[:space:]]*//Ig; s/^[[:space:]]+|[[:space:]]+$//g')"
mbinfo[board_serial]="$(echo "${mbinfo[board_serial]}"|sed -E 's/[[:space:]]*default[[:space:]]+string[[:space:]]*//Ig; s/^[[:space:]]+|[[:space:]]+$//g')"
}
get_cgroup_cpu_and_pids(){
local cpuset quota period pids
if [[ -r /sys/fs/cgroup/cpuset.cpus ]];then
cpuset=$(</sys/fs/cgroup/cpuset.cpus)
elif [[ -r /sys/fs/cgroup/cpuset/cpuset.cpus ]];then
cpuset=$(</sys/fs/cgroup/cpuset/cpuset.cpus)
fi
if [[ -n $cpuset ]];then
local total=0
IFS=',' read -ra parts <<<"$cpuset"
for p in "${parts[@]}";do
if [[ $p == *-* ]];then
total=$((total+${p#*-}-${p%-*}+1))
elif [[ -n $p ]];then
total=$((total+1))
fi
done
echo "$total"
else
if [[ -r /sys/fs/cgroup/cpu.max ]];then
read quota period </sys/fs/cgroup/cpu.max
[[ $quota != "max" && $period -gt 0 ]]&&printf '%.1f\n' "$(awk "BEGIN{print $quota/$period}")"
elif [[ -r /sys/fs/cgroup/cpu/cpu.cfs_quota_us ]];then
quota=$(</sys/fs/cgroup/cpu/cpu.cfs_quota_us)
period=$(</sys/fs/cgroup/cpu/cpu.cfs_period_us)
((quota>0&&period>0))&&printf '%.1f\n' "$(awk "BEGIN{print $quota/$period}")"
fi
fi
if [[ -r /sys/fs/cgroup/pids.max ]];then
pids=$(</sys/fs/cgroup/pids.max)
elif [[ -r /sys/fs/cgroup/pids/pids.max ]];then
pids=$(</sys/fs/cgroup/pids/pids.max)
fi
[[ $pids != "max" ]]&&echo "pids=$pids"
}
get_cpu(){
local temp_info="$Font_Cyan$Font_B${sinfo[cpu]}$Font_Suffix"
((ibar_step+=5))
show_progress_bar "$temp_info" $((55-${sinfo[lcpu]}))&
bar_pid="$!"&&disown "$bar_pid"
trap "kill_progress_bar" RETURN
local lscpu_out proc_cpuinfo
lscpu_out="$(LC_ALL=C lscpu 2>/dev/null)"
proc_cpuinfo="$(</proc/cpuinfo)"
cpuinfo[arch]=$(awk -F: '/Architecture/{print $2}' <<<"$lscpu_out"|xargs)
[[ -z ${cpuinfo[arch]} ]]&&cpuinfo[arch]=$(uname -m)
cpuinfo[name]=$(awk -F: '/^Model name[[:space:]]*:/{print $2}' <<<"$lscpu_out"|xargs)
[[ -z ${cpuinfo[name]} ]]&&cpuinfo[name]=$(awk -F': +' '/model name/{print $2; exit}' <<<"$proc_cpuinfo")
cpuinfo[name]="${cpuinfo[name]//(R)/}"
cpuinfo[name]="${cpuinfo[name]//(TM)/}"
cpuinfo[name]="${cpuinfo[name]//CPU /}"
cpuinfo[name]="${cpuinfo[name]//w\/ /}"
cpuinfo[op_mode]=$(awk -F: '/^CPU op-mode\(s\)[[:space:]]*:/{print $2}' <<<"$lscpu_out"|xargs)
[[ ${cpuinfo[op_mode]} == *"32-bit"* && ${cpuinfo[op_mode]} == *"64-bit"* ]]&&cpuinfo[op_mode]="32/64-bit"
if [[ -z ${cpuinfo[op_mode]} ]];then
case "${cpuinfo[arch]}" in
x86_64)cpuinfo[op_mode]="32/64-bit"
;;
aarch64|ppc64*|riscv64)cpuinfo[op_mode]="64-bit"
;;
i[3-6]86|armv7*|armv6*)cpuinfo[op_mode]="32-bit"
esac
fi
cpuinfo[family]=$(awk -F: '/^CPU family[[:space:]]*:/{print $2}' <<<"$lscpu_out"|xargs)
[[ -z ${cpuinfo[family]} ]]&&cpuinfo[family]=$(awk -F': +' '/cpu family/{print $2; exit}' <<<"$proc_cpuinfo")
cpuinfo[stepping]=$(awk -F: '/^Stepping[[:space:]]*:/{print $2}' <<<"$lscpu_out"|xargs)
[[ -z ${cpuinfo[stepping]} ]]&&cpuinfo[stepping]=$(awk -F': +' '/stepping/{print $2; exit}' <<<"$proc_cpuinfo")
cpuinfo[sockets]=$(awk -F: '/^Socket\(s\)[[:space:]]*:/{print $2}' <<<"$lscpu_out"|xargs)
if [[ -z ${cpuinfo[sockets]} || ${cpuinfo[sockets]} == "0" ]];then
cpuinfo[sockets]=$(awk -F': +' '/physical id/{print $2}' <<<"$proc_cpuinfo"|sort -u|wc -l)
[[ ${cpuinfo[sockets]} -eq 0 ]]&&cpuinfo[sockets]=1
fi
cpuinfo[cores_per_socket]=$(awk -F: '/^Core\(s\) per socket[[:space:]]*:/{print $2}' <<<"$lscpu_out"|xargs)
[[ -z ${cpuinfo[cores_per_socket]} ]]&&cpuinfo[cores_per_socket]=$(awk -F': +' '/cpu cores/{print $2; exit}' <<<"$proc_cpuinfo")
cpuinfo[threads_per_core]=$(awk -F: '/^Thread\(s\) per core[[:space:]]*:/{print $2}' <<<"$lscpu_out"|xargs)
if [[ -z ${cpuinfo[threads_per_core]} ]];then
local logical physical
logical=$(grep -c '^processor' <<<"$proc_cpuinfo")
physical=$((cpuinfo[sockets]*cpuinfo[cores_per_socket]))
[[ $physical -gt 0 ]]&&cpuinfo[threads_per_core]=$((logical/physical))
[[ -z ${cpuinfo[threads_per_core]} ]]&&cpuinfo[threads_per_core]=1
fi
if [[ -n ${cpuinfo[sockets]} && -n ${cpuinfo[cores_per_socket]} ]]&&((cpuinfo[sockets]>0&&cpuinfo[cores_per_socket]>0));then
cpuinfo[cores]=$((cpuinfo[sockets]*cpuinfo[cores_per_socket]))
fi
if [[ -n ${cpuinfo[cores]} && -n ${cpuinfo[threads_per_core]} ]]&&((cpuinfo[cores]>0&&cpuinfo[threads_per_core]>0));then
cpuinfo[threads]=$((cpuinfo[cores]*cpuinfo[threads_per_core]))
fi
local cginfo cgcores
cginfo=$(get_cgroup_cpu_and_pids)
if [[ -n $cginfo ]];then
cgcores=$(grep -v '^pids=' <<<"$cginfo"|head -n1)
[[ -n $cgcores ]]&&cpuinfo[cores]="$cgcores"
cpuinfo[cg_threads]=$(grep '^pids=' <<<"$cginfo"|cut -d= -f2)
fi
cpuinfo[mhz]=$(awk -F: '/^CPU MHz[[:space:]]*:/{print $2}' <<<"$lscpu_out"|xargs)
cpuinfo[min_mhz]=$(awk -F: '/^CPU min MHz[[:space:]]*:/{printf "%d", $2}' <<<"$lscpu_out")
cpuinfo[max_mhz]=$(awk -F: '/^CPU max MHz[[:space:]]*:/{printf "%d", $2}' <<<"$lscpu_out")
[[ -z ${cpuinfo[mhz]} ]]&&cpuinfo[mhz]=$(awk -F': +' '/cpu MHz/{print $2; exit}' <<<"$proc_cpuinfo")
read cpu a b c idle rest </proc/stat
total1=$((a+b+c+idle))
idle1=$idle
sleep 1
read cpu a b c idle rest </proc/stat
total2=$((a+b+c+idle))
idle2=$idle
cpuinfo[usage]=$(awk -v t1="$total1" -v t2="$total2" -v i1="$idle1" -v i2="$idle2" '
        BEGIN {
            usage = (1 - (i2 - i1) / (t2 - t1)) * 100
            printf "%d", usage + 0.5
        }')
cpuinfo[L1d]=$(awk -F: '/^L1d cache[[:space:]]*:/{print $2}' <<<"$lscpu_out"|sed 's/([^)]*)//g'|xargs)
cpuinfo[L1i]=$(awk -F: '/^L1i cache[[:space:]]*:/{print $2}' <<<"$lscpu_out"|sed 's/([^)]*)//g'|xargs)
cpuinfo[L2]=$(awk -F: '/^L2 cache[[:space:]]*:/{print $2}' <<<"$lscpu_out"|sed 's/([^)]*)//g'|xargs)
cpuinfo[L3]=$(awk -F: '/^L3 cache[[:space:]]*:/{print $2}' <<<"$lscpu_out"|sed 's/([^)]*)//g'|xargs)
if [[ -z "${cpuinfo[L1d]}${cpuinfo[L1i]}${cpuinfo[L2]}${cpuinfo[L3]}" ]];then
local cache_kb
cache_kb=$(awk -F': +' '/cache size/{print $2; exit}' <<<"$proc_cpuinfo")
if [[ -n $cache_kb && -n ${cpuinfo[cores_per_socket]} ]];then
local cores total_kb
cores=$((cpuinfo[sockets]*cpuinfo[cores_per_socket]))
total_kb=$((${cache_kb% *}*cores))
cpuinfo[cache_total]="$total_kb KB"
cpuinfo[cache_fallback]=1
fi
fi
cpuinfo[flags]=$(awk -F: '/^Flags[[:space:]]*:/{print $2}' <<<"$lscpu_out")
[[ -z ${cpuinfo[flags]} ]]&&cpuinfo[flags]=$(awk -F': +' '/flags/{print $2; exit}' <<<"$proc_cpuinfo")
if [[ ${cpuinfo[arch]} =~ x86_64|i[3-6]86 ]];then
cpuinfo[vt]=$([[ ${cpuinfo[flags]} =~ vmx|svm ]]&&echo 1)
cpuinfo[aes]=$([[ ${cpuinfo[flags]} =~ aes ]]&&echo 1)
cpuinfo[avx2]=$([[ ${cpuinfo[flags]} =~ avx2 ]]&&echo 1)
cpuinfo[bmi]=$([[ ${cpuinfo[flags]} =~ bmi1|bmi2 ]]&&echo 1)
cpuinfo[ept]=$([[ ${cpuinfo[flags]} =~ ept|npt ]]&&echo 1)
else
cpuinfo[el2]=$([[ ${cpuinfo[flags]} =~ el2 ]]&&echo 1)
cpuinfo[neon]=$([[ ${cpuinfo[flags]} =~ neon|asimd ]]&&echo 1)
cpuinfo[aes_sha]=$([[ ${cpuinfo[flags]} =~ aes|sha ]]&&echo 1)
cpuinfo[atomics]=$([[ ${cpuinfo[flags]} =~ atomics ]]&&echo 1)
cpuinfo[sve]=$([[ ${cpuinfo[flags]} =~ sve ]]&&echo 1)
fi
}
echo_cpu_temp(){
declare -A min_temp
declare -A max_temp
local interval=5
[[ -n $1 ]]&&interval="$1"
while :;do
local found=0
for zone in /sys/class/thermal/thermal_zone*;do
[[ -r "$zone/type" && -r "$zone/temp" ]]||continue
local type
type=$(<"$zone/type")
[[ $type =~ cpu|CPU|pkg|core|soc|x86 ]]||continue
local t
t=$(($(<"$zone/temp")/1000))
[[ $t -le 0 ]]&&continue
((min_temp[0]==0||t<min_temp[0]))&&min_temp[0]=$t
((t>max_temp[0]))&&max_temp[0]=$t
found=1
done
if ((found==0))&&command -v sensors &>/dev/null;then
local tctl
tctl=$(sensors 2>/dev/null|awk '
                /Tctl:/ {
                    gsub(/[^0-9.]/,"",$2)
                    print int($2)
                    exit
                }')
if [[ -n $tctl && $tctl -gt 0 ]];then
((min_temp[0]==0||tctl<min_temp[0]))&&min_temp[0]=$tctl
((tctl>max_temp[0]))&&max_temp[0]=$tctl
found=1
fi
if ((found==0));then
local max_core=0
while read -r v;do
[[ $v -gt $max_core ]]&&max_core="$v"
done < <(sensors 2>/dev/null|awk '
                    /Core [0-9]+:|Package id/ {
                        if (match($0, /\+[0-9.]+°C/)) {
                            t=$0
                            sub(/^[^+]*\+/,"",t)
                            sub(/°C.*/,"",t)
                            print int(t)
                        }
                    }')
if ((max_core>0));then
((min_temp[0]==0||max_core<min_temp[0]))&&min_temp[0]=$max_core
((max_core>max_temp[0]))&&max_temp[0]=$max_core
found=1
fi
fi
fi
local out="["
for i in "${!min_temp[@]}";do
out+="$i=${min_temp[$i]}/${max_temp[$i]} "
done
out="${out% }]"
echo "$out"
sleep "$interval"
done
}
test_cpu_sysbench(){
local fd3_open=0
local test_on=0
local test_pid
cleanup_local(){
[[ -n $test_pid && $test_on -eq 1 ]]&&kill "$test_pid" 2>/dev/null
((fd3_open))&&exec 3<&-
kill_progress_bar
echo -ne "\r"
}
on_int(){
cleanup_local
echo ""
exit 130
}
on_term(){
cleanup_local
echo ""
exit 143
}
trap cleanup_local RETURN
trap on_int INT
trap on_term TERM
local temp_info="$Font_Cyan$Font_B${sinfo[cpubench]}$Font_Suffix"
((ibar_step+=5))
command -v sysbench &>/dev/null||return
show_progress_bar "$temp_info" $((55-${sinfo[lcpubench]}))&
bar_pid="$!"&&disown "$bar_pid"
local last_line=""
exec 3< <(echo_cpu_temp 2)
fd3_open=1
test_on=1
local test_pid=$!
local out eps threads
out="$(sysbench cpu --threads=1 --time=8 --events=0 --cpu-max-prime=10000 run 2>/dev/null)"
ret=$?
if ((ret!=0))||! grep -q "events per second" <<<"$out";then
out="$(sysbench --test=cpu --num-threads=1 --max-time=8 --cpu-max-prime=10000 run 2>/dev/null)"
fi
eps="$(awk -F: '/events per second/ {gsub(/^[ \t]+/, "", $2); print $2}' <<<"$out")"
[[ $eps =~ ^[0-9]+(\.[0-9]+)?$ ]]&&cpuinfo[sysbench_single]="$eps"
threads="${cpuinfo[threads]:-${cpuinfo[cores]}}"
[[ -z $threads || $threads -le 1 ]]&&return
out="$(sysbench cpu --threads="$threads" --time=8 --events=0 --cpu-max-prime=10000 run 2>/dev/null)"
ret=$?
if ((ret!=0))||! grep -q "events per second" <<<"$out";then
out="$(sysbench --test=cpu --num-threads="$threads" --max-time=8 --cpu-max-prime=10000 run 2>/dev/null)"
fi
eps="$(awk -F: '/events per second/ {gsub(/^[ \t]+/, "", $2); print $2}' <<<"$out")"
[[ $eps =~ ^[0-9]+(\.[0-9]+)?$ ]]&&cpuinfo[sysbench_multi]="$eps"
[[ -n $test_pid ]]&&kill "$test_pid" 2>/dev/null&&test_on=0
while read -r -t 1 line <&3;do
last_line="$line"
done
cpuinfo[temp_count]=0
cpuinfo[temp_min]=-1
cpuinfo[temp_max]=-1
for item in ${last_line#[};do
item="${item%]}"
idx="${item%%=*}"
val="${item#*=}"
tmin="${val%/*}"
tmax="${val#*/}"
[[ $tmin =~ ^[0-9]+$ ]]||continue
[[ $tmax =~ ^[0-9]+$ ]]||continue
cpuinfo[temp${idx}_min]=$tmin
cpuinfo[temp${idx}_max]=$tmax
((cpuinfo[temp_count]++))
if ((cpuinfo[temp_min]<0||tmin<cpuinfo[temp_min]));then
cpuinfo[temp_min]=$tmin
fi
if ((cpuinfo[temp_max]<0||tmax>cpuinfo[temp_max]));then
cpuinfo[temp_max]=$tmax
fi
done
}
parse_geekbench_cpu_html(){
local html="$1"
[[ -z $html ]]&&return 1
_gb_key(){
echo "$1"|sed -E '
            s/<[^>]+>//g;
            s/^[[:space:]]+|[[:space:]]+$//g;
            s/[[:space:]]+/_/g
        '
}
local mode=""
local name="" score="" desc="" pct=""
while IFS= read -r line;do
[[ $line =~ \<h3\>Single-Core\ Performance\<\/h3\> ]]&&{
mode="s"
continue
}
[[ $line =~ \<h3\>Multi-Core\ Performance\<\/h3\> ]]&&{
mode="m"
continue
}
[[ -z $mode ]]&&continue
if [[ $line =~ \<td\ class=\'name\'\> ]];then
read -r name_line
name="$(_gb_key "$name_line")"
desc=""
pct=""
continue
fi
if [[ $line =~ \<td\ class=\'score\'\> ]];then
score=""
desc=""
while IFS= read -r l;do
if [[ -z $score && $l =~ ^[[:space:]]*[0-9]+[[:space:]]*$ ]];then
score="$(sed 's/[^0-9]//g' <<<"$l")"
fi
if [[ $l =~ \<span\ class=\'description\'\> ]];then
desc="$(sed -E 's/<[^>]+>//g; s/^[[:space:]]+|[[:space:]]+$//g' <<<"$l")"
fi
[[ $l =~ \<\/td\> ]]&&break
done
continue
fi
if [[ $line =~ benchmark-bar ]];then
if [[ $line =~ width:([0-9]+)% ]];then
pct="${BASH_REMATCH[1]}"
fi
if [[ -n $name && -n $score ]];then
cpuinfo["gb.$mode.i.$name"]="$score"
[[ -n $desc ]]&&cpuinfo["gb.$mode.i.$name.desc"]="$desc"
[[ -n $pct ]]&&cpuinfo["gb.$mode.i.$name.pct"]="$pct"
fi
name="" score="" desc="" pct=""
continue
fi
if [[ $line =~ \<tr\ class=\'stacked-heading\'\> ]];then
read -r _
read -r name_line
read -r _
read -r _
read -r score_line
local gname gscore gkey
gname="$(_gb_key "$name_line")"
gscore="$(sed 's/[^0-9]//g' <<<"$score_line")"
if [[ $gname == "Single-Core_Score" || $gname == "Multi-Core_Score" ]];then
continue
fi
[[ -n $gname && -n $gscore ]]&&cpuinfo["gb.$mode.g.$gname"]="$gscore"
fi
done <<<"$html"
}
test_cpu_gb5(){
local mem_avail_mb swap_free_mb
mem_avail_mb=$(awk '/MemAvailable:/ {print int($2/1024)}' /proc/meminfo)
swap_free_mb=$(awk '/SwapFree:/ {print int($2/1024)}' /proc/meminfo)
[[ $mem_avail_mb =~ ^[0-9]+$ ]]||mem_avail_mb=0
[[ $swap_free_mb =~ ^[0-9]+$ ]]||swap_free_mb=0
local need_swap=0
local swap_file=""
local target_total_mb=1200
if ((mem_avail_mb<950));then
if [[ ${osinfo[virt_kind]} == "container" || ${osinfo[virt_kind]} == "unknown" ]];then
return
fi
if ((mem_avail_mb+swap_free_mb<target_total_mb));then
local create_mb=$((target_total_mb-mem_avail_mb-swap_free_mb))
((create_mb<128))&&create_mb=128
local avail_disk_mb
avail_disk_mb=$(df -Pm "$workdir" 2>/dev/null|awk 'NR==2 {print $4}')
if ! [[ $avail_disk_mb =~ ^[0-9]+$ ]]||((avail_disk_mb<create_mb+100));then
return
fi
swap_file="$workdir/.gb5_tmp.swap"
if fallocate -l "${create_mb}M" "$swap_file" 2>/dev/null||dd if=/dev/zero of="$swap_file" bs=1M count="$create_mb" status=none;then
chmod 600 "$swap_file"&&mkswap "$swap_file" >/dev/null 2>&1&&swapon "$swap_file" >/dev/null 2>&1&&need_swap=1
else
return
fi
fi
fi
local fd3_open=0
local fd4_open=0
local test_on=0
local test_pid
cleanup_local(){
[[ -n $PROG_BAR_PID ]]&&kill "$PROG_BAR_PID" 2>/dev/null
[[ -n $test_pid && $test_on -eq 1 ]]&&kill "$test_pid" 2>/dev/null
[[ $need_swap -eq 1 ]]&&{
swapoff "$swap_file" 2>/dev/null
[[ -n $swap_file ]]&&rm -f "$swap_file"
}
((fd3_open))&&exec 3<&-
((fd4_open))&&exec 4>&-
echo -ne "\r"
}
on_int(){
cleanup_local
echo ""
exit 130
}
on_term(){
cleanup_local
echo ""
exit 143
}
trap cleanup_local RETURN
trap on_int INT
trap on_term TERM
local temp_info="$Font_Cyan$Font_B${sinfo[cpumark]}"
((ibar_step+=10))
coproc PROG_BAR {
show_progress_bar "$temp_info" $((55-${sinfo[lcpumark]})) 1
}
exec 4>&"${PROG_BAR[1]}"
fd4_open=1
test_on=1
local last_line=""
exec 3< <(echo_cpu_temp)
fd3_open=1
local test_pid=$!
cpuinfo[geekbench]=""
if command -v geekbench5 &>/dev/null;then
local url score
url="$(geekbench5 --cpu 2>&1|tee >(cat >&4)|grep -oE 'https://browser\.geekbench\.com/v5/cpu/[0-9]+'|head -n 1)" >/dev/null
if [[ -n $url ]];then
local tmpresu=""
if command -v curl-impersonate >/dev/null 2>&1;then
local attempt
for ((attempt=1; attempt<=5; attempt++));do
tmpresu="$(curl-impersonate -s --compressed --impersonate "chrome146" "$url")"
if [[ -n $tmpresu ]]&&grep -q "<div class='score'>" <<<"$tmpresu";then
break
fi
sleep 1
done
parse_geekbench_cpu_html "$tmpresu"
local scores=($(echo "$tmpresu"|grep -o "<div class='score'>[0-9]\+</div>"|sed 's/[^0-9]//g'))
local single_score="${scores[0]}"
local multi_score="${scores[1]}"
else
tmpresu="$(curl -sL --max-time 10 "$url.csv")"
single_score=$(echo "$tmpresu"|grep '^Single-Core,'|cut -d',' -f2)
multi_score=$(echo "$tmpresu"|grep '^Multi-Core,'|cut -d',' -f2)
fi
cpuinfo[url]="$url"
fi
[[ -n $single_score ]]&&cpuinfo[geekbench_single]="$single_score"
[[ -n $multi_score ]]&&cpuinfo[geekbench_multi]="$multi_score"
fi
[[ -n $test_pid ]]&&kill "$test_pid" 2>/dev/null&&test_on=0
while read -r -t 1 line <&3;do
last_line="$line"
done
cpuinfo[temp_count]=0
cpuinfo[temp_min]=-1
cpuinfo[temp_max]=-1
for item in ${last_line#[};do
item="${item%]}"
idx="${item%%=*}"
val="${item#*=}"
tmin="${val%/*}"
tmax="${val#*/}"
[[ $tmin =~ ^[0-9]+$ ]]||continue
[[ $tmax =~ ^[0-9]+$ ]]||continue
[[ -z ${cpuinfo[temp${idx}_min]} || ${cpuinfo[temp${idx}_min]} -gt $tmin ]]&&cpuinfo[temp${idx}_min]="$tmin"
[[ -z ${cpuinfo[temp${idx}_max]} || ${cpuinfo[temp${idx}_max]} -lt $tmax ]]&&cpuinfo[temp${idx}_max]="$tmax"
((cpuinfo[temp_count]++))
if ((cpuinfo[temp_min]<0||tmin<cpuinfo[temp_min]));then
cpuinfo[temp_min]=$tmin
fi
if ((cpuinfo[temp_max]<0||tmax>cpuinfo[temp_max]));then
cpuinfo[temp_max]=$tmax
fi
done
}
get_gpu(){
local temp_info="$Font_Cyan$Font_B${sinfo[gpu]}$Font_Suffix"
((ibar_step+=20))
show_progress_bar "$temp_info" $((55-${sinfo[lgpu]}))&
bar_pid="$!"&&disown "$bar_pid"
trap "kill_progress_bar" RETURN
gpuinfo=()
gpuinfo[count]=0
gpuinfo[has_dgpu]=0
command -v lspci &>/dev/null||return
local cpu_vendor
local nvidia_idx=0
cpu_vendor="$(awk -F: '/vendor_id/ {print $2; exit}' /proc/cpuinfo 2>/dev/null)"
local -a nv_vram_list=()
local -a nv_freq_list=()
if command -v nvidia-smi &>/dev/null;then
mapfile -t nv_vram_list < <(nvidia-smi --query-gpu=memory.total \
--format=csv,noheader,nounits 2>/dev/null|awk '{print int(($1/1024)+0.5)}')
mapfile -t nv_freq_list < <(nvidia-smi --query-gpu=clocks.max.graphics \
--format=csv,noheader,nounits 2>/dev/null)
fi
for card in /sys/class/drm/card[0-9]*;do
[[ -e "$card/device" ]]||continue
local pci_addr name type vendor idx
pci_addr="$(basename "$(readlink -f "$card/device")")"
name="$(lspci -s "$pci_addr" 2>/dev/null|sed -E 's/.*: *//; s/Advanced Micro Devices, Inc\.//g; s/^[[:space:]]+|[[:space:]]+$//g')"
[[ -z $name ]]&&continue
type=0
if [[ $name == *NVIDIA* ]];then
type=1
gpuinfo[has_dgpu]=1
fi
case "$name" in
*NVIDIA*)vendor="NVIDIA";;
*AMD*|*ATI*|*Radeon*)vendor="AMD";;
*Intel*)vendor="Intel";;
*)if
[[ $type -eq 0 ]]
then
case "$cpu_vendor" in
*Intel*)vendor="Intel"
name="Intel $name"
;;
*AMD*)vendor="AMD"
name="AMD $name"
;;
*)vendor="Unknown"
esac
else
vendor="Unknown"
fi
esac
idx="${gpuinfo[count]}"
gpuinfo[item$idx.type]="$type"
gpuinfo[item$idx.vendor]="$vendor"
gpuinfo[item$idx.name]=$(echo "$name"|sed 's/Corporation //g')
case "$vendor" in
NVIDIA)type=1
gpuinfo[has_dgpu]=1
;;
AMD)if
[[ -r "$card/device/mem_info_vram_total" ]]
then
vram_bytes=$(<"$card/device/mem_info_vram_total")
if ((vram_bytes>0));then
type=1
gpuinfo[has_dgpu]=1
else
type=0
fi
else
type=0
fi
;;
Intel)type=0
esac
local vram_gb=""
local freq_max=""
case "$vendor" in
NVIDIA)vram_gb="${nv_vram_list[$nvidia_idx]}"
freq_max="${nv_freq_list[$nvidia_idx]}"
((nvidia_idx++))
;;
AMD)if
[[ -r "$card/device/mem_info_vram_total" ]]
then
vram_gb=$(($(cat "$card/device/mem_info_vram_total")/1024/1024/1024))
fi
if [[ -r "$card/device/pp_dpm_sclk" ]];then
freq_max="$(grep -oE '[0-9]+Mhz' "$card/device/pp_dpm_sclk"|sed 's/Mhz//'|sort -n|tail -n 1)"
fi
;;
Intel)if
[[ -r "$card/device/mem_info_vram_total" ]]
then
vram_gb=$(($(cat "$card/device/mem_info_vram_total")/1024/1024/1024))
fi
if [[ -r "$card/gt_max_freq_mhz" ]];then
freq_max="$(cat "$card/gt_max_freq_mhz")"
elif [[ -r "$card/device/gt_max_freq_mhz" ]];then
freq_max="$(cat "$card/device/gt_max_freq_mhz")"
fi
esac
gpuinfo[item$idx.vram_gb]="$vram_gb"
gpuinfo[item$idx.freq_max]="$freq_max"
((gpuinfo[count]++))
done
[[ ${gpuinfo[count]} -eq 0 ]]&&return
gpuinfo[driver]=0
[[ -d /sys/module/nvidia || -d /sys/module/amdgpu || -d /sys/module/i915 ]]&&gpuinfo[driver]=1
gpuinfo[opencl]=0
if command -v clinfo &>/dev/null;then
clinfo &>/dev/null&&gpuinfo[opencl]=1
fi
gpuinfo[cuda]=0
if command -v nvidia-smi &>/dev/null;then
nvidia-smi &>/dev/null&&gpuinfo[cuda]=1
fi
}
echo_gpu_temp(){
declare -A min_temp
declare -A max_temp
while :;do
if command -v nvidia-smi &>/dev/null;then
local idx=0
while read -r t;do
[[ -z $t ]]&&continue
((min_temp[$idx]==0||t<min_temp[$idx]))&&min_temp[$idx]=$t
((t>max_temp[$idx]))&&max_temp[$idx]=$t
((idx++))
done < <(nvidia-smi --query-gpu=temperature.gpu \
--format=csv,noheader,nounits 2>/dev/null)
fi
for card in /sys/class/drm/card[0-9]*;do
[[ -r "$card/device/current_link_width" ]]||continue
local idx="${card##*/card}"
for t in "$card"/device/hwmon/hwmon*/temp*_input;do
[[ -r $t ]]||continue
t=$(($(cat "$t")/1000))
((min_temp[$idx]==0||t<min_temp[$idx]))&&min_temp[$idx]=$t
((t>max_temp[$idx]))&&max_temp[$idx]=$t
break
done
done
local out="["
for i in "${!min_temp[@]}";do
out+="$i=${min_temp[$i]}/${max_temp[$i]} "
done
out="${out% }]"
echo "$out"
sleep 5
done
}
parse_geekbench_gpu_html(){
local html="$1"
[[ -z $html ]]&&return 1
_gb_key(){
echo "$1"|sed -E '
            s/<[^>]+>//g;
            s/^[[:space:]]+|[[:space:]]+$//g;
            s/[[:space:]]+/_/g
        '
}
local mode=""
local name="" score="" desc="" pct=""
while IFS= read -r line;do
if [[ $line =~ \<td\ class=\'name\'\> ]];then
read -r name_line
name="$(_gb_key "$name_line")"
desc=""
pct=""
continue
fi
if [[ $line =~ \<td\ class=\'score\'\> ]];then
score=""
desc=""
while IFS= read -r l;do
if [[ -z $score && $l =~ ^[[:space:]]*[0-9]+[[:space:]]*$ ]];then
score="$(sed 's/[^0-9]//g' <<<"$l")"
fi
if [[ $l =~ \<span\ class=\'description\'\> ]];then
desc="$(sed -E 's/<[^>]+>//g; s/^[[:space:]]+|[[:space:]]+$//g' <<<"$l")"
fi
[[ $l =~ \<\/td\> ]]&&break
done
continue
fi
if [[ $line =~ benchmark-bar ]];then
if [[ $line =~ width:([0-9]+)% ]];then
pct="${BASH_REMATCH[1]}"
fi
if [[ -n $name && -n $score ]];then
gpuinfo["gb.$name"]="$score"
[[ -n $desc ]]&&gpuinfo["gb.$name.desc"]="$desc"
[[ -n $pct ]]&&gpuinfo["gb.$name.pct"]="$pct"
fi
name="" score="" desc="" pct=""
continue
fi
done <<<"$html"
}
test_gpu(){
local fd3_open=0
local fd4_open=0
local test_on=0
local test_pid
cleanup_local(){
[[ -n $PROG_BAR_PID ]]&&kill "$PROG_BAR_PID" 2>/dev/null
[[ -n $test_pid && $test_on -eq 1 ]]&&kill "$test_pid" 2>/dev/null
((fd3_open))&&exec 3<&-
((fd4_open))&&exec 4>&-
echo -ne "\r"
}
on_int(){
cleanup_local
echo ""
exit 130
}
on_term(){
cleanup_local
echo ""
exit 143
}
trap cleanup_local RETURN
trap on_int INT
trap on_term TERM
local temp_info="$Font_Cyan$Font_B${sinfo[gpumark]}"
((ibar_step+=5))
coproc PROG_BAR {
show_progress_bar "$temp_info" $((55-${sinfo[lgpumark]})) 1
}
exec 4>&"${PROG_BAR[1]}"
fd4_open=1
test_on=1
local last_line=""
exec 3< <(echo_gpu_temp)
fd3_open=1
local test_pid=$!
gpuinfo[geekbench]=""
if [[ ${gpuinfo[has_dgpu]} == "1" ]]&&command -v geekbench5 &>/dev/null;then
local url score
url="$(geekbench5 --compute 2>&1|tee >(cat >&4)|grep -oE 'https://browser\.geekbench\.com/v5/compute/[0-9]+'|head -n 1)" >/dev/null
if [[ -n $url ]];then
local tmpresu=""
if command -v curl-impersonate >/dev/null 2>&1;then
local attempt
for ((attempt=1; attempt<=5; attempt++));do
tmpresu="$(curl-impersonate -s --compressed --impersonate "chrome146" "$url")"
if [[ -n $tmpresu ]]&&grep -q "<div class='score'>" <<<"$tmpresu";then
break
fi
sleep 1
done
parse_geekbench_gpu_html "$tmpresu"
score="$(echo "$tmpresu"|grep -o "<div class='score'>[0-9]\+</div>"|sed 's/[^0-9]//g'|head -n 1)"
score_type="$(echo "$tmpresu"|grep -o "<div class='note'>[^<]*</div>"|head -n 1|sed -E "s@<div class='note'>([^[:space:]]+).*@\1@")"
else
tmpresu="$(curl -sL --max-time 10 "$url.csv")"
local score_line=$(echo "$tmpresu"|grep -E '^(OpenCL|CUDA|Metal|Vulkan),')
score_type=$(echo "$score_line"|cut -d',' -f1)
score=$(echo "$score_line"|cut -d',' -f2)
fi
gpuinfo[url]="$url"
fi
[[ -n $score ]]&&gpuinfo[geekbench]="$score"
[[ -n $score_type ]]&&gpuinfo[gb_type]="$score_type"
fi
[[ -n $test_pid ]]&&kill "$test_pid" 2>/dev/null&&test_on=0
while read -r -t 1 line <&3;do
last_line="$line"
done
gpuinfo[temp_count]=0
gpuinfo[temp_min]=-1
gpuinfo[temp_max]=-1
for item in ${last_line#[};do
item="${item%]}"
idx="${item%%=*}"
val="${item#*=}"
tmin="${val%/*}"
tmax="${val#*/}"
[[ $tmin =~ ^[0-9]+$ ]]||continue
[[ $tmax =~ ^[0-9]+$ ]]||continue
gpuinfo[temp${idx}_min]=$tmin
gpuinfo[temp${idx}_max]=$tmax
((gpuinfo[temp_count]++))
if ((gpuinfo[temp_min]<0||tmin<gpuinfo[temp_min]));then
gpuinfo[temp_min]=$tmin
fi
if ((gpuinfo[temp_max]<0||tmax>gpuinfo[temp_max]));then
gpuinfo[temp_max]=$tmax
fi
done
}
get_mem(){
local temp_info="$Font_Cyan$Font_B${sinfo[mem]}$Font_Suffix"
((ibar_step+=15))
show_progress_bar "$temp_info" $((55-${sinfo[lmem]}))&
bar_pid="$!"&&disown "$bar_pid"
trap "kill_progress_bar" RETURN
local idx=0
local total_mb=0
meminfo[count]=0
if command -v lscpu >/dev/null 2>&1;then
ch=$(lscpu 2>/dev/null|awk -F: '
        tolower($1) ~ /channel/ {
            gsub(/^[ \t]+|[ \t]+$/, "", $2)
            print $2
        }'|head -n1)
if [[ $ch =~ ^[0-9]+$ ]];then
meminfo[mem_channels]="$ch"
fi
fi
if command -v dmidecode >/dev/null 2>&1&&[[ $EUID -eq 0 ]]&&[[ ${osinfo[virt]} == "physical-machine" ]];then
while IFS= read -r line;do
case "$line" in
"Memory Device")cur="mem$idx"
((idx++))
;;
*"Size:"*)if
[[ $line =~ ^[[:space:]]*Size:[[:space:]]+([0-9]+)[[:space:]]+(MB|GB)$ ]]
then
size="${BASH_REMATCH[1]}"
unit="${BASH_REMATCH[2]}"
[[ $size == "No" || $size == "None" ]]&&continue
meminfo[$cur.size]="$size$unit"
[[ $unit == "MB" ]]&&((total_mb+=size))
[[ $unit == "GB" ]]&&((total_mb+=size*1024))
fi
;;
*"Bank Locator:"*)val="${line#*: }"
val="${val#"${val%%[![:space:]]*}"}"
val="${val%"${val##*[![:space:]]}"}"
val="$(echo "$val"|tr 'a-z' 'A-Z')"
val="$(echo "$val"|sed -E '
                            s/CPU/p/g;
                            s/NODE/n/g;
                            s/CHANNEL/ch/g;
                            s/DIMM/d/g
                        ')"
val="$(echo "$val"|sed -E 's/^[[:space:]]*P([^A-Z])/p\1/')"
val="$(echo "$val"|sed -E 's/\b([A-Z])([A-Z]+)\b/\L\1/g')"
val="$(echo "$val"|sed -E 's/[ _-]//g')"
meminfo[$cur.slot]="$val"
ch="${val%%d*}"
if [[ -n $ch ]];then
if [[ -z ${meminfo[mem_channels]} ]];then
if [[ -z ${meminfo[_channels_seen]} ]];then
meminfo[_channels_seen]="$ch"
else
meminfo[_channels_seen]="${meminfo[_channels_seen]} $ch"
fi
fi
fi
;;
*"Type:"*)val="${line#*: }"
val="${val#"${val%%[![:space:]]*}"}"
val="${val%"${val##*[![:space:]]}"}"
meminfo[$cur.type]="$val"
;;
*"Manufacturer:"*)val="${line#*: }"
val="${val#"${val%%[![:space:]]*}"}"
val="${val%"${val##*[![:space:]]}"}"
meminfo[$cur.vendor]="$val"
;;
*"Serial Number:"*)val="${line#*: }"
val="${val#"${val%%[![:space:]]*}"}"
val="${val%"${val##*[![:space:]]}"}"
meminfo[$cur.serial]="$val"
;;
*"Part Number:"*)val="${line#*: }"
val="${val#"${val%%[![:space:]]*}"}"
val="${val%"${val##*[![:space:]]}"}"
meminfo[$cur.part]="$val"
;;
*"Configured Memory Speed:"*):
;;
*"Speed:"*)val="${line#*: }"
val="${val#"${val%%[![:space:]]*}"}"
val="${val%"${val##*[![:space:]]}"}"
meminfo[$cur.speed]="$(echo "$val"|grep -oE '[0-9]+'|head -n1)"
esac
done < <(dmidecode -t memory 2>/dev/null)
meminfo[count]="$idx"
fi
if [[ -z ${meminfo[mem_channels]} && -n ${meminfo[_channels_seen]} ]];then
meminfo[mem_channels]=$(echo "${meminfo[_channels_seen]}"|tr ' ' '\n'|sort -u|wc -l)
fi
if [[ -r /proc/meminfo ]];then
while read -r key val _;do
case "$key" in
MemTotal:)meminfo[mem_total_kb]="$val";;
MemAvailable:)meminfo[mem_avail_kb]="$val";;
SwapTotal:)meminfo[swap_total_kb]="$val";;
SwapFree:)meminfo[swap_avail_kb]="$val"
esac
done </proc/meminfo
meminfo[mem_used_kb]=$((meminfo[mem_total_kb]-meminfo[mem_avail_kb]))
meminfo[total]=$(awk -v t="${meminfo[mem_total_kb]}" '
            BEGIN {
                if (t < 1024*1024)
                    printf "%.0f MB", t/1024
                else
                    printf "%.1f GB", t/1024/1024
            }')
meminfo[used]=$(awk -v u="${meminfo[mem_used_kb]}" -v t="${meminfo[mem_total_kb]}" '
            BEGIN {
                if (t < 1024*1024)
                    printf "%.0f MB", u/1024
                else
                    printf "%.1f GB", u/1024/1024
            }')
meminfo[avail]=$(awk -v a="${meminfo[mem_avail_kb]}" -v t="${meminfo[mem_total_kb]}" '
            BEGIN {
                if (t < 1024*1024)
                    printf "%.0f MB", a/1024
                else
                    printf "%.1f GB", a/1024/1024
            }')
if ((meminfo[mem_total_kb]>0));then
meminfo[mem_used_pct]=$(awk -v u="${meminfo[mem_used_kb]}" -v t="${meminfo[mem_total_kb]}" 'BEGIN{printf "%.0f", u*100/t}')
meminfo[mem_avail_pct]=$((100-meminfo[mem_used_pct]))
fi
if ((meminfo[swap_total_kb]>0));then
meminfo[swap_used_kb]=$((meminfo[swap_total_kb]-meminfo[swap_avail_kb]))
meminfo[swap_total]=$(awk -v t="${meminfo[swap_total_kb]}" '
                BEGIN {
                    if (t < 1024*1024)
                        printf "%.0f MB", t/1024
                    else
                        printf "%.1f GB", t/1024/1024
                }')
meminfo[swap_used]=$(awk -v u="${meminfo[swap_used_kb]}" -v t="${meminfo[swap_total_kb]}" '
                BEGIN {
                    if (t < 1024*1024)
                        printf "%.0f MB", u/1024
                    else
                        printf "%.1f GB", u/1024/1024
                }')
meminfo[swap_avail]=$(awk -v a="${meminfo[swap_avail_kb]}" -v t="${meminfo[swap_total_kb]}" '
                BEGIN {
                    if (t < 1024*1024)
                        printf "%.0f MB", a/1024
                    else
                        printf "%.1f GB", a/1024/1024
                }')
fi
fi
if ((meminfo[swap_total_kb]>0));then
meminfo[swap_used_pct]=$(awk -v u="${meminfo[swap_used_kb]}" -v t="${meminfo[swap_total_kb]}" 'BEGIN{printf "%.0f", u*100/t}')
meminfo[swap_avail_pct]=$((100-meminfo[swap_used_pct]))
fi
if [[ -z ${meminfo[balloon]} && -z ${meminfo[neighbor]} ]];then
case "${osinfo[virt]}" in
kvm)if
lsmod 2>/dev/null|grep -q '^virtio_balloon'
then
meminfo[balloon]=1
else
meminfo[balloon]=0
fi
if [[ -r /sys/kernel/mm/ksm/run ]]&&[[ "$(cat /sys/kernel/mm/ksm/run)" == "1" ]];then
meminfo[ksm]=1
else
meminfo[ksm]=0
fi
;;
lxc)meminfo[neighbor]=$(ls /sys/devices/virtual/block 2>/dev/null|grep -c '^dm')
esac
fi
}
test_mem(){
local temp_info="$Font_Cyan$Font_B${sinfo[membench]}$Font_Suffix"
((ibar_step+=5))
show_progress_bar "$temp_info" $((55-${sinfo[lmembench]}))&
bar_pid="$!"&&disown "$bar_pid"
trap "kill_progress_bar" RETURN
command -v sysbench >/dev/null 2>&1||return
local r_mib w_mib out
out="$(sysbench memory \
--memory-block-size=1M \
--memory-total-size=1000G \
--memory-oper=write \
--memory-access-mode=seq \
--time=5 run 2>/dev/null)"
w_mib="$(awk -F'[()]' '/MiB\/sec/ {print $2}' <<<"$out"|awk '{print $1}')"
if [[ -z $w_mib ]];then
out="$(sysbench --test=memory \
--memory-block-size=1M \
--memory-total-size=1000G \
--memory-oper=write \
--memory-access-mode=seq \
run 2>/dev/null)"
w_mib="$(awk -F'[()]' '/MiB\/sec/ {print $2}' <<<"$out"|awk '{print $1}')"
fi
out="$(sysbench memory \
--memory-block-size=1M \
--memory-total-size=1000G \
--memory-oper=read \
--memory-access-mode=seq \
--time=5 run 2>/dev/null)"
r_mib="$(awk -F'[()]' '/MiB\/sec/ {print $2}' <<<"$out"|awk '{print $1}')"
if [[ -z $r_mib ]];then
out="$(sysbench --test=memory \
--memory-block-size=1M \
--memory-total-size=1000G \
--memory-oper=read \
--memory-access-mode=seq \
run 2>/dev/null)"
r_mib="$(awk -F'[()]' '/MiB\/sec/ {print $2}' <<<"$out"|awk '{print $1}')"
fi
[[ -n $w_mib ]]&&meminfo[write]=$(awk -v v="$w_mib" 'BEGIN{printf "%.1f", v*1.048576}')
[[ -n $r_mib ]]&&meminfo[read]=$(awk -v v="$r_mib" 'BEGIN{printf "%.1f", v*1.048576}')
local avg_lat_ns
out="$(sysbench memory \
--memory-block-size=64 \
--memory-total-size=1000G \
--memory-oper=read \
--memory-access-mode=rnd \
--time=5 run 2>/dev/null)"
avg_lat_ns="$(awk '
        /total time:/   { t=$3 }
        /total number of events:/ { n=$5 }
        END {
            if (t>0 && n>0)
                printf "%.0f", (t/n)*1e9
        }' <<<"$out")"
if [[ -z $avg_lat_ns ]];then
out="$(sysbench --test=memory \
--memory-block-size=64 \
--memory-total-size=1000G \
--memory-oper=read \
--memory-access-mode=rnd \
run 2>/dev/null)"
avg_lat_ns="$(awk '
            /avg:/ {
                gsub(/[^0-9.]/,"",$2)
                printf "%.0f", $2*1000
            }' <<<"$out")"
fi
[[ -n $avg_lat_ns ]]&&meminfo[lat]="$avg_lat_ns"
}
fmt_bytes(){
local v="$1"
[[ -z $v || $v -le 0 ]]&&return
if command -v numfmt >/dev/null 2>&1;then
numfmt --to=iec "$v"
else
awk -v b="$v" '
            BEGIN {
                split("B KB MB GB TB PB EB", u, " ")
                i=1
                while (b>=1024 && i<length(u)) {
                    b/=1024
                    i++
                }
                if (b>=10)
                    printf "%.0f%s", b, u[i]
                else
                    printf "%.1f%s", b, u[i]
            }
        '
fi
}
fmt_rw(){
local b="$1"
[[ -z $b ]]&&return
awk -v b="$b" '
        BEGIN {
            # b <= 0 或非法，直接不输出
            if (b+0 <= 0) exit

            tb = 1024*1024*1024*1024
            gb = 1024*1024*1024

            if (b >= tb)
                printf "%dTB", int(b/tb + 0.5)
            else
                printf "%dGB", int(b/gb + 0.5)
        }
    '
}
parse_sata_rw(){
local id="$1"
local smart_all="$2"
awk -v id="$id" '
        $1==id {
            name=$2
            raw=$NF
            unit=1
            # 尝试从名称中拆出单位（不使用 match 的 array）
            n=0; u=""
            # 只处理带 "_" 的情况
            if (index(name, "_") > 0) {
                split(name, p, "_")
                last=p[length(p)]
                # last 可能是 32MiB / 1GiB / 512KB
                num=""
                suf=""
                for (i=1; i<=length(last); i++) {
                    c=substr(last, i, 1)
                    if (c >= "0" && c <= "9")
                        num = num c
                    else {
                        suf = substr(last, i)
                        break
                    }
                }
                if (num != "" && suf != "") {
                    if (suf=="KB" || suf=="KiB") unit = num * 1024
                    else if (suf=="MB" || suf=="MiB") unit = num * 1024 * 1024
                    else if (suf=="GB" || suf=="GiB") unit = num * 1024 * 1024 * 1024
                }
            }
            print raw * unit
        }
    ' <<<"$smart_all"
}
get_md_mount(){
local md="$1"
local mp=""
mp="$(findmnt -n -o TARGET "/dev/$md" 2>/dev/null)"
[[ -n $mp ]]&&{
echo "$mp"
return
}
mp="$(lsblk -o NAME,PKNAME,TYPE,MOUNTPOINT -r 2>/dev/null|awk -v md="$md" '$2==md && $4!="" {print $4}'|sort -u|paste -sd "," -)"
[[ -n $mp ]]&&echo "$mp"
}
get_disk(){
local temp_info="$Font_Cyan$Font_B${sinfo[disk]}$Font_Suffix"
((ibar_step+=10))
show_progress_bar "$temp_info" $((55-${sinfo[ldisk]}))&
bar_pid="$!"&&disown "$bar_pid"
trap "kill_progress_bar" RETURN
local total used avail p_used p_avail
local name rota size_b type smart_out
local idx=0
read -r total used avail p_used p_avail < <(df -B1 -P 2>/dev/null|awk '
            BEGIN {
                skip["tmpfs"]
                skip["devtmpfs"]
                skip["udev"]
                skip["overlay"]
                skip["shm"]
                skip["cgroup"]
                skip["cgroup2"]
                skip["proc"]
                skip["sysfs"]
                skip["debugfs"]
                skip["tracefs"]
                skip["securityfs"]
                skip["pstore"]
                skip["autofs"]
                skip["mqueue"]
                skip["hugetlbfs"]
                skip["configfs"]
                skip["rpc_pipefs"]
                skip["binfmt_misc"]
            }
            NR > 1 {
                fs = $1
                # fuse.* 单独处理
                if (fs in skip || fs ~ /^fuse\./)
                    next
                size  = $2 + 0
                used  = $3 + 0
                avail = $4 + 0
            
                if (!(fs in seen)) {
                    seen[fs] = 1
                    T += size
                    U += used
                    A += avail
                }
            }
            END {
                if (T > 0)
                    printf "%.0f %.0f %.0f %d %d\n",
                           T, U, A,
                           int(U*100/T),
                           int(A*100/T)
            }
        ')
if [[ -z $total || $total -le 0 ]];then
read -r total used avail p_used < <(df -B1 / 2>/dev/null|awk 'NR==2{print $2,$3,$4,int($3*100/$2)}')
p_avail=$((100-p_used))
fi
diskinfo[total]=$total
diskinfo[used]=$used
diskinfo[avail]=$avail
diskinfo[p_used]=$p_used
diskinfo[p_avail]=$p_avail
while read -r name rota size_b;do
((idx++))
local dev="/dev/$name"
local show_name="$name"
if [[ $name =~ ^(nvme[0-9]+)n[0-9]+$ ]];then
show_name="${BASH_REMATCH[1]}"
fi
diskinfo["disk$idx.name"]="$show_name"
diskinfo["disk$idx.dev"]="$dev"
if [[ $name == nvme* ]];then
type="NVMe"
elif [[ $rota == "1" ]];then
type="HDD"
else
type="SSD"
fi
diskinfo["disk$idx.type"]="$type"
smart_out=$(smartctl -i "$dev" 2>/dev/null)
diskinfo["disk$idx.model"]=$(awk '
                /Device Model|Model Number/ {
                    line = $0
                    sub(/^.*:[[:space:]]*/, "", line)
                    n = split(line, a, /[[:space:]]+/)
                    if (n >= 2)
                        print a[1], a[2]
                            else
                        print line
                }
            ' <<<"$smart_out")
diskinfo["disk$idx.serial"]=$(awk -F: '/Serial Number/{print $2}' <<<"$smart_out"|xargs)
diskinfo["disk$idx.firmware"]=$(awk -F: '/Firmware Version/{print $2}' <<<"$smart_out"|xargs)
if [[ $type == "NVMe" ]];then
diskinfo["disk$idx.capacity"]=$(sed -n 's/.*Total NVM Capacity:.*\[\(.*\)\].*/\1/p' <<<"$smart_out"|tr -d ' ')
else
diskinfo["disk$idx.capacity"]=$(sed -n 's/.*User Capacity:.*\[\(.*\)\].*/\1/p' <<<"$smart_out"|tr -d ' ')
fi
if [[ $type == "HDD" ]];then
diskinfo["disk$idx.rpm"]=$(sed -n 's/.*Rotation Rate:[[:space:]]*\([0-9]\+\).*/\1rpm/p' <<<"$smart_out")
fi
if [[ $type != "NVMe" ]];then
diskinfo["disk$idx.form"]=$(sed -n 's/.*Form Factor:[[:space:]]*\([0-9.]\+\)[[:space:]]*inches/\1"/p' <<< \
"$smart_out")
fi
smart_all=$(smartctl -A "$dev" 2>/dev/null)
smart_j=$(smartctl -H -j "$dev" 2>/dev/null)
if grep -q '"passed":[[:space:]]*true' <<<"$smart_j";then
diskinfo["disk$idx.smart_pass"]="PASSED"
elif grep -q '"passed":[[:space:]]*false' <<<"$smart_j";then
diskinfo["disk$idx.smart_pass"]="FAILED"
fi
diskinfo["disk$idx.pcycle"]=$(awk '$1==12{print $NF}' <<<"$smart_all")
diskinfo["disk$idx.poh"]=$(awk '$1==9{print $NF}' <<<"$smart_all")
diskinfo["disk$idx.temp"]=$(awk '
                ($1==190 || $1==194) {
                    for (i=NF; i>0; i--) {
                        if ($i ~ /^[0-9]+$/) {
                            print $i
                            exit
                        }
                    }
                }
            ' <<<"$smart_all")
if [[ $type == "HDD" ]];then
for id in 1 5 187 196 197 198;do
diskinfo["disk$idx.smart_$id"]=$(awk '$1=='"$id"'{print $NF}' <<<"$smart_all")
done
fi
if [[ $type == "SSD" ]];then
diskinfo["disk$idx.write_raw"]=$(parse_sata_rw 241 "$smart_all")
diskinfo["disk$idx.read_raw"]=$(parse_sata_rw 242 "$smart_all")
diskinfo["disk$idx.life"]=$(awk '$1==169{print $NF}' <<<"$smart_all")
fi
if [[ $type == "NVMe" ]];then
diskinfo["disk$idx.pcycle"]=$(sed -n 's/.*Power Cycles:[[:space:]]*\([0-9,]\+\).*/\1/p' <<<"$smart_all"|tr -d ',')
diskinfo["disk$idx.poh"]=$(sed -n 's/.*Power On Hours:[[:space:]]*\([0-9,]\+\).*/\1/p' <<<"$smart_all"|tr -d ',')
diskinfo["disk$idx.temp"]=$(sed -n 's/.*Temperature:[[:space:]]*\([0-9]\+\)[[:space:]]*Celsius.*/\1/p' <<<"$smart_all")
if [[ -z ${diskinfo[disk$idx.temp]} ]];then
diskinfo["disk$idx.temp"]=$(sed -n 's/.*Temperature Sensor 1:[[:space:]]*\([0-9]\+\)[[:space:]]*Celsius.*/\1/p' <<<"$smart_all")
fi
diskinfo["disk$idx.read_tb"]=$(sed -n 's/.*Data Units Read:.*\[\([^]]\+\)\].*/\1/p' <<<"$smart_all"|awk '
                    {
                        v=$1; u=$2
                        if (v+0 == v)
                            printf "%d%s", int(v+0.5), u
                    }
                ')
diskinfo["disk$idx.write_tb"]=$(sed -n 's/.*Data Units Written:.*\[\([^]]\+\)\].*/\1/p' <<<"$smart_all"|awk '
                    {
                        v=$1; u=$2
                        if (v+0 == v)
                            printf "%d%s", int(v+0.5), u
                    }
                ')
diskinfo["disk$idx.read_raw"]=$(sed -n 's/.*Data Units Read:[[:space:]]*\([0-9,]\+\).*/\1/p' <<<"$smart_all"|tr -d ',')
diskinfo["disk$idx.write_raw"]=$(sed -n 's/.*Data Units Written:[[:space:]]*\([0-9,]\+\).*/\1/p' <<<"$smart_all"|tr -d ',')
used=$(sed -n 's/.*Percentage Used:[[:space:]]*\([0-9]\+\)%.*/\1/p' <<<"$smart_all")
if [[ -n $used ]];then
diskinfo["disk$idx.life"]=$((100-used))
fi
diskinfo["disk$idx.spare"]=$(sed -n 's/.*Available Spare:[[:space:]]*\([0-9]\+\)%.*/\1/p' <<<"$smart_all")
fi
done < <(lsblk -dn -o NAME,ROTA,SIZE,TYPE -b|awk '$4=="disk" && $3>0 {print $1,$2,$3}')
diskinfo[count]=$idx
if [[ -z ${diskinfo[raid_count]} ]];then
local ridx=0
if [[ -r /proc/mdstat ]];then
while read -r line;do
if [[ $line =~ ^(md[0-9]+)[[:space:]]*:[[:space:]]*active[[:space:]]+([a-z0-9]+)[[:space:]]+(.*)$ ]];then
((ridx++))
local rname="${BASH_REMATCH[1]}"
local rlevel="${BASH_REMATCH[2]}"
local rdevs="${BASH_REMATCH[3]}"
rlevel="${rlevel^^}"
rdevs="$(awk '{for(i=1;i<=NF;i++) if ($i ~ /\[[0-9]+\]/) printf "%s ", $i}' <<<"$rdevs")"
rdevs="${rdevs% }"
diskinfo["raid$ridx.name"]="$rname"
diskinfo["raid$ridx.level"]="$rlevel"
diskinfo["raid$ridx.devs"]="$rdevs"
diskinfo["raid$ridx.mount"]="$(get_md_mount "$rname")"
fi
done </proc/mdstat
fi
diskinfo[raid_count]="$ridx"
fi
}
detect_testdev_type(){
local dev="$1"
dev="$(readlink -f "$dev" 2>/dev/null)"
if [[ $dev == /dev/md* ]];then
local lvl
lvl=$(awk -v md="$(basename "$dev")" '
                $1 == md {
                    for (i=1;i<=NF;i++)
                        if ($i ~ /^raid[0-9]+$/) {
                            print toupper($i)
                            exit
                        }
                }
            ' /proc/mdstat)
[[ -n $lvl ]]&&echo "$lvl"||echo "RAID"
return
fi
if [[ $dev == /dev/mapper/* || $dev == /dev/dm-* ]];then
echo "LVM"
return
fi
if lsblk -no TYPE "$dev" 2>/dev/null|grep -qE 'disk|part';then
echo "DISK"
return
fi
echo ""
}
get_testdev_members_from_diskinfo(){
local dev="$1"
local i
for ((i=1; i<=diskinfo[raid_count]; i++));do
if [[ ${diskinfo[raid$i.name]} == "$dev" ]];then
echo "${diskinfo[raid$i.devs]}"
return
fi
done
}
get_testdev_mount_from_diskinfo(){
local dev="$1"
local i
for ((i=1; i<=diskinfo[raid_count]; i++));do
if [[ ${diskinfo[raid$i.name]} == "$dev" ]];then
echo "${diskinfo[raid$i.mount]}"
return
fi
done
}
mask_path(){
local path="$1"
local IFS='/'
local out=""
local part
[[ $path == "/" ]]&&{
echo "/"
return
}
for part in $path;do
if [[ -z $part ]];then
out+="/"
continue
fi
local len=${#part}
if ((len<=2));then
out+="$part/"
else
local stars
stars=$(printf '%*s' $((len-2)) ''|tr ' ' '*')
out+="${part:0:1}$stars${part: -1}/"
fi
done
echo "${out%/}"
}
fio_probe_size(){
local tf="$1"
local size="$2"
local min_b="$3"
while ((size>=min_b));do
fio --name=prealloc \
--filename="$tf" \
--rw=write \
--bs=1M \
--iodepth=1 \
--numjobs=1 \
--direct=1 \
--size="$size" \
--fallocate=posix \
--overwrite=1 \
--end_fsync=1 \
--group_reporting >/dev/null 2>&1&&{
echo "$size"
return 0
}
rm -f "$tf"
size=$((size/2))
done
return 1
}
test_disk(){
local fd4_open=0
cleanup_local(){
((fd4_open))&&exec 4>&-
[[ -n $PROG_BAR_PID ]]&&kill "$PROG_BAR_PID" 2>/dev/null
[[ -n $tf && -f $tf ]]&&rm -f "$tf"
echo -ne "\r"
}
on_int(){
cleanup_local
echo ""
exit 130
}
on_term(){
cleanup_local
echo ""
exit 143
}
trap cleanup_local RETURN
trap on_int INT
trap on_term TERM
local temp_info="$Font_Cyan$Font_B${sinfo[fio]}"
((ibar_step+=5))
coproc PROG_BAR {
show_progress_bar "$temp_info" $((55-${sinfo[lfio]})) 2
}
exec 4>&"${PROG_BAR[1]}"
fd4_open=1
command -v fio >/dev/null 2>&1||return
if [[ -z ${diskinfo[testdir]} ]];then
diskinfo[testdir]="$workdir"
diskinfo[testdev]=$(df --output=source "$workdir"|awk 'NR==2')
diskinfo[testdev_type]=$(detect_testdev_type "${diskinfo[testdev]}")
diskinfo[testdev]="${diskinfo[testdev]#/dev/}"
if [[ ${diskinfo[testdev_type]} == RAID* ]];then
diskinfo[testdev_members]=$(get_testdev_members_from_diskinfo "${diskinfo[testdev]}")
diskinfo[testdev_mount]=$(get_testdev_mount_from_diskinfo "${diskinfo[testdev]}")
fi
fi
[[ $fullinfo -eq 0 ]]&&diskinfo[testdir]="$(mask_path "${diskinfo[testdir]}")"
local min_b=$((256*1024*1024))
local max_b=$((2*1024*1024*1024))
local tf=""
local i
for i in {1..100};do
tf="$workdir/.hardware.sh_fio_test_$i.tmp"
[[ ! -e $tf ]]&&break
done
[[ -z $tf ]]&&return
local df_free
df_free=$(df -B1 "$workdir"|awk 'NR==2{printf "%.0f", $4}')
[[ $df_free =~ ^[0-9]+$ ]]||return
((df_free<min_b))&&return
try_b=$((df_free*7/10))
((try_b<min_b))&&try_b="$min_b"
((try_b>max_b))&&try_b="$max_b"
echo "Preparing Testing File" >&4
local size_b
size_b=$(fio_probe_size "$tf" "$try_b" "$min_b")||return
if [[ $mode_disk -eq 0 && mode_verbose -eq 0 ]];then
local tests=(
"4K_q1   randread   4K   1"
"4K_q32  randread   4K   32"
"1M_q1   read       1M   1"
"1M_q8   read       1M   8"
"4K_q1   randwrite  4K   1"
"4K_q32  randwrite  4K   32"
"1M_q1   write      1M   1"
"1M_q8   write      1M   8")
else
local tests=(
"4K_q1   randread   4K   1"
"4K_q32  randread   4K   32"
"1M_q1   read       1M   1"
"1M_q8   read       1M   8"
"4K_q1   randwrite  4K   1"
"4K_q32  randwrite  4K   32"
"1M_q1   write      1M   1"
"1M_q8   write      1M   8"
"512B_q4   read   512B   4"
"1K_q4     read   1K     4"
"2K_q4     read   2K     4"
"4K_q4     read   4K     4"
"8K_q4     read   8K     4"
"16K_q4    read   16K    4"
"32K_q4    read   32K    4"
"64K_q4    read   64K    4"
"128K_q4   read   128K   4"
"256K_q4   read   256K   4"
"512K_q4   read   512K   4"
"1M_q4     read   1M     4"
"2M_q4     read   2M     4"
"4M_q4     read   4M     4"
"8M_q4     read   8M     4"
"16M_q4    read   16M    4"
"32M_q4    read   32M    4"
"64M_q4    read   64M    4"
"512B_q4   write  512B   4"
"1K_q4     write  1K     4"
"2K_q4     write  2K     4"
"4K_q4     write  4K     4"
"8K_q4     write  8K     4"
"16K_q4    write  16K    4"
"32K_q4    write  32K    4"
"64K_q4    write  64K    4"
"128K_q4   write  128K   4"
"256K_q4   write  256K   4"
"512K_q4   write  512K   4"
"1M_q4     write  1M     4"
"2M_q4     write  2M     4"
"4M_q4     write  4M     4"
"8M_q4     write  8M     4"
"16M_q4    write  16M    4"
"32M_q4    write  32M    4"
"64M_q4    write  64M    4")
fi
local fio_base=(
--filename="$tf"
--ioengine=libaio
--direct=1
--numjobs=1
--runtime=10
--size="$size_b"
--gtod_reduce=1
--group_reporting
--minimal)
local t name rw bs q out bw_kb iops
for t in "${tests[@]}";do
read -r name rw bs q <<<"$t"
echo "$name $rw" >&4
if [[ $rw == *read ]];then
out=$(fio \
--name="$name" \
--rw="$rw" \
--bs="$bs" \
--iodepth="$q" \
--time_based \
"${fio_base[@]}" 2>/dev/null)
else
out=$(fio \
--name="$name" \
--rw="$rw" \
--bs="$bs" \
--iodepth="$q" \
--overwrite=1 \
"${fio_base[@]}" 2>/dev/null)
fi
if [[ $rw == *read ]];then
bw_kb=$(awk -F';' '{print $7}' <<<"$out")
iops=$(awk -F';' '{print $8}' <<<"$out")
else
bw_kb=$(awk -F';' '{print $48}' <<<"$out")
iops=$(awk -F';' '{print $49}' <<<"$out")
fi
[[ -z $bw_kb || $bw_kb -le 0 ]]&&continue
diskinfo["fio.$rw.$name.bw"]="$bw_kb"
diskinfo["fio.$rw.$name.iops"]="$iops"
done
}
show_head(){
echo -ne "\r$(printf '%80s'|tr ' ' '+')\n"
if [[ $mode_lite -eq 0 ]];then
if [ $fullinfo -eq 1 ];then
calc_padding "$(printf '%*s' "${shead[ltitle]}" '')$IP" 80
echo -ne "\r$PADDING$Font_B${shead[title]}$Font_Cyan$IP$Font_Suffix\n"
else
calc_padding "$(printf '%*s' "${shead[ltitle]}" '')$IPhide" 80
echo -ne "\r$PADDING$Font_B${shead[title]}$Font_Cyan$IPhide$Font_Suffix\n"
fi
else
if [ $fullinfo -eq 1 ];then
calc_padding "$(printf '%*s' "${shead[ltitle_lite]}" '')$IP" 80
echo -ne "\r$PADDING$Font_B${shead[title_lite]}$Font_Cyan$IP$Font_Suffix\n"
else
calc_padding "$(printf '%*s' "${shead[ltitle_lite]}" '')$IPhide" 80
echo -ne "\r$PADDING$Font_B${shead[title_lite]}$Font_Cyan$IPhide$Font_Suffix\n"
fi
fi
calc_padding "${shead[git]}" 80
echo -ne "\r$PADDING$Font_U${shead[git]}$Font_Suffix\n"
calc_padding "${shead[bash]}" 80
echo -ne "\r$PADDING${shead[bash]}\n"
echo -ne "\r${shead[ptime]}${shead[time]}  ${shead[ver]}\n"
echo -ne "\r$(printf '%80s'|tr ' ' '+')\n"
}
mark_cpu(){
local GB5M="${cpuinfo[geekbench_multi]:-0}"
local GB5S="${cpuinfo[geekbench_single]:-0}"
local T="${cpuinfo[cg_threads]:-0}"
local A=42000
local B=6000
local C=3
local D=21000
local gb5_multi_norm
local gb5_single_norm
local base_score
gb5_multi_norm=$(bc -l <<EOF
$A * (1 - e(-$GB5M / $B)) + $C * $GB5M
EOF
)
gb5_single_norm=$(bc -l <<EOF
$D * (1 - e(-$GB5S / $B))
EOF
)
base_score=$(bc -l <<EOF
$gb5_multi_norm + $gb5_single_norm
EOF
)
local factor=1.0
((cpuinfo[vt]))&&factor=$(bc -l <<<"$factor * 1.03")
((cpuinfo[aes]))&&factor=$(bc -l <<<"$factor * 1.04")
((cpuinfo[avx2]))&&factor=$(bc -l <<<"$factor * 1.05")
((cpuinfo[bmi]))&&factor=$(bc -l <<<"$factor * 1.02")
((cpuinfo[ept]))&&factor=$(bc -l <<<"$factor * 1.02")
((cpuinfo[el2]))&&factor=$(bc -l <<<"$factor * 1.03")
((cpuinfo[neon]))&&factor=$(bc -l <<<"$factor * 1.02")
((cpuinfo[aes_sha]))&&factor=$(bc -l <<<"$factor * 1.04")
((cpuinfo[atomics]))&&factor=$(bc -l <<<"$factor * 1.02")
((cpuinfo[sve]))&&factor=$(bc -l <<<"$factor * 1.05")
local penalty
local cgroup_factor
if ((T<=0));then
penalty=0
elif ((T>=500));then
penalty=0.2
else
penalty=$(bc -l <<EOF
x = (500 - $T) / 450
p = 0.20 + 0.50 * e(1.3 * l(x))
if (p > 0.70) p = 0.70
p
EOF
)
fi
cgroup_factor=$(bc -l <<<"1 - $penalty")
local final_score
final_score=$(bc -l <<EOF
$base_score * $factor * $cgroup_factor
EOF
)
printf "%.0f\n" "$final_score"
}
mark_gpu(){
local GB5_GPU="${gpuinfo[geekbench]:-0}"
local GPU_base
local VRAM_sum=0
local GPU_count=0
GPU_base=$(bc -l <<<"$GB5_GPU * 0.8")
local i=0
while :;do
local vram_key="item$i.vram_gb"
[[ -z ${gpuinfo[$vram_key]+x} ]]&&break
[[ -n ${gpuinfo[$vram_key]} ]]&&VRAM_sum=$(bc -l <<<"$VRAM_sum + ${gpuinfo[$vram_key]}")
((GPU_count++))
((i++))
done
if ((GPU_count==0));then
printf "%.0f\n" "$GPU_base"
return
fi
local VRAM_avg
VRAM_avg=$(bc -l <<<"$VRAM_sum / $GPU_count")
local VRAM_factor
VRAM_factor=$(bc -l <<EOF
x = $VRAM_avg / 12
f = 1 + 0.15 * (l(x) / l(2))
if (f < 0.70) f = 0.70
if (f > 1.30) f = 1.30
f
EOF
)
local GPU_score
GPU_score=$(bc -l <<<"$GPU_base * $VRAM_factor")
printf "%.0f\n" "$GPU_score"
}
mark_mem(){
local READ_MBPS="${meminfo[read]:-0}"
local WRITE_MBPS="${meminfo[write]:-0}"
local LAT_NS="${meminfo[lat]:-0}"
local MEM_KB="${meminfo[mem_total_kb]:-0}"
local BALLOON="${meminfo[balloon]:-0}"
local KSM="${meminfo[ksm]:-0}"
local BASE=50000
local MEM_GB
MEM_GB=$(bc -l <<<"$MEM_KB / 1024 / 1024")
local Capacity_factor
Capacity_factor=$(bc -l <<EOF
x = $MEM_GB / 16 + 1
if (x <= 0) {
    f = 0
} else {
    f = e(0.6 * l(l(x) / l(2)))
}
f
EOF
)
local BW_factor
BW_factor=$(bc -l <<EOF
if ($READ_MBPS <= 0 || $WRITE_MBPS <= 0) {
    f = 0
} else {
    bw = sqrt(($READ_MBPS / 25000) * ($WRITE_MBPS / 25000))
    f = e(0.75 * l(bw))
}
f
EOF
)
local Latency_factor
if (($(bc -l <<<"$LAT_NS > 0")));then
Latency_factor=$(bc -l <<<"100 / $LAT_NS")
else
Latency_factor=0
fi
local Memory_perf_factor
Memory_perf_factor=$(bc -l <<<"0.6 * $BW_factor + 0.4 * $Latency_factor")
local Memory_score
Memory_score=$(bc -l <<<"$BASE * $Capacity_factor * $Memory_perf_factor")
local penalty_factor=1.0
((BALLOON))&&penalty_factor=$(bc -l <<<"$penalty_factor * 0.80")
((KSM))&&penalty_factor=$(bc -l <<<"$penalty_factor * 0.50")
Memory_score=$(bc -l <<<"$Memory_score * $penalty_factor")
printf "%.0f\n" "$Memory_score"
}
calc_capacity(){
local gb="$1"
bc -l <<<"
x = $gb / 1024 + 1
if (x <= 1) {
    0
} else {
    base = e(0.6 * l(l(x) / l(2)))
    bonus = 1 + 0.25 * (l(x) / l(2))
    base * bonus
}"
}
mark_disk(){
local BASE=80000
local DISK_B="${diskinfo[total]:-0}"
local R_SEQ="${diskinfo[fio.read.1M_q8.bw]:-0}"
local W_SEQ="${diskinfo[fio.write.1M_q8.bw]:-0}"
local RR_Q32="${diskinfo[fio.randread.4K_q32.iops]:-0}"
local RW_Q32="${diskinfo[fio.randwrite.4K_q32.iops]:-0}"
local RR_Q1="${diskinfo[fio.randread.4K_q1.iops]:-0}"
local has_hdd=0
local has_ssd=0
local has_nvme=0
local HDD_GB=0
local SSD_GB=0
local NVME_GB=0
local i=0
while :;do
local type_key="disk$i.type"
local cap_key="disk$i.capacity"
[[ -z ${diskinfo[$type_key]+x} ]]&&break
local dtype="${diskinfo[$type_key]}"
local cap="${diskinfo[$cap_key]}"
local val=$(echo "$cap"|grep -oE '[0-9.]+')
local unit=$(echo "$cap"|grep -oE '[A-Za-z]+')
local gb=0
case "$unit" in
MB)gb=$(bc -l <<<"$val/1024");;
GB)gb="$val";;
TB)gb=$(bc -l <<<"$val*1024");;
PB)gb=$(bc -l <<<"$val*1024*1024")
esac
case "$dtype" in
HDD)has_hdd=1
HDD_GB=$(bc -l <<<"$HDD_GB+$gb")
;;
NVMe)has_nvme=1
NVME_GB=$(bc -l <<<"$NVME_GB+$gb")
;;
*)has_ssd=1
SSD_GB=$(bc -l <<<"$SSD_GB+$gb")
esac
((i++))
done
if ((!has_hdd||(!has_ssd&&!has_nvme)));then
local DISK_GB
DISK_GB=$(bc -l <<<"$DISK_B / 1024 / 1024 / 1024")
local Disk_capacity_factor
Disk_capacity_factor=$(bc -l <<EOF
x = $DISK_GB / 1024 + 1
if (x <= 1) {
    f = 0
} else {
    base = e(0.6 * l(l(x) / l(2)))
    bonus = 1 + 0.25 * (l(x) / l(2))
    f = base * bonus
}
f
EOF
)
local Seq_factor
if (($(bc -l <<<"($R_SEQ>0)*($W_SEQ>0)")));then
Seq_factor=$(bc -l <<<"e(0.3*l(sqrt($R_SEQ*$W_SEQ)/500000))")
else
Seq_factor=0
fi
local Rand_factor
if (($(bc -l <<<"($RR_Q32>0)*($RW_Q32>0)")));then
Rand_factor=$(bc -l <<<"e(0.3*l(sqrt($RR_Q32*$RW_Q32)/50000))")
else
Rand_factor=0
fi
local Latency_factor
if (($(bc -l <<<"$RR_Q1>0")));then
Latency_factor=$(bc -l <<<"e(0.3*l($RR_Q1/8000))")
else
Latency_factor=0
fi
local Disk_perf_factor
Disk_perf_factor=$(bc -l <<<"0.4*$Seq_factor + 0.4*$Rand_factor + 0.2*$Latency_factor")
local Disk_score
Disk_score=$(bc -l <<<"$BASE*0.20*$Disk_capacity_factor*$Disk_perf_factor")
printf "%.0f\n" "$Disk_score"
return
fi
local Seq_factor Rand_factor Latency_factor
if (($(bc -l <<<"($R_SEQ>0)*($W_SEQ>0)")));then
Seq_factor=$(bc -l <<<"e(0.3*l(sqrt($R_SEQ*$W_SEQ)/500000))")
else
Seq_factor=0.8
fi
if (($(bc -l <<<"($RR_Q32>0)*($RW_Q32>0)")));then
Rand_factor=$(bc -l <<<"e(0.3*l(sqrt($RR_Q32*$RW_Q32)/50000))")
else
Rand_factor=0.8
fi
if (($(bc -l <<<"$RR_Q1>0")));then
Latency_factor=$(bc -l <<<"e(0.3*l($RR_Q1/8000))")
else
Latency_factor=0.8
fi
local Disk_perf_factor
Disk_perf_factor=$(bc -l <<<"0.4*$Seq_factor + 0.4*$Rand_factor + 0.2*$Latency_factor")
local HDD_perf SSD_perf NVME_perf
if (($(bc -l <<<"$Disk_perf_factor < 0.85")));then
HDD_perf="$Disk_perf_factor"
SSD_perf=1
NVME_perf=1.5
elif (($(bc -l <<<"$Disk_perf_factor > 1.3")));then
HDD_perf=0.6
SSD_perf=1
NVME_perf="$Disk_perf_factor"
else
HDD_perf=0.6
SSD_perf="$Disk_perf_factor"
NVME_perf=1.5
fi
local HDD_cap SSD_cap NVME_cap
HDD_cap=$(calc_capacity "$HDD_GB")
SSD_cap=$(calc_capacity "$SSD_GB")
NVME_cap=$(calc_capacity "$NVME_GB")
local HDD_score SSD_score NVME_score
HDD_score=$(bc -l <<<"$BASE*0.20*$HDD_cap*$HDD_perf")
SSD_score=$(bc -l <<<"$BASE*0.20*$SSD_cap*$SSD_perf")
NVME_score=$(bc -l <<<"$BASE*0.20*$NVME_cap*$NVME_perf")
local Disk_score
Disk_score=$(bc -l <<<"$HDD_score + $SSD_score + $NVME_score")
printf "%.0f\n" "$Disk_score"
}
get_mark(){
if [[ $mode_skip != *"3"* && -n ${cpuinfo[geekbench_multi]} ]];then
markinfo[cpu]=$(mark_cpu)
fi
if [[ $mode_skip != *"4"* && -n ${gpuinfo[geekbench]} ]];then
markinfo[gpu]=$(mark_gpu)
fi
if [[ $mode_skip != *"5"* && -n ${meminfo[mem_total_kb]} ]];then
markinfo[mem]=$(mark_mem)
fi
if [[ $mode_skip != *"6"* && -n ${diskinfo[total]} ]];then
markinfo[disk]=$(mark_disk)
fi
local total=0
local count=0
for k in cpu gpu mem disk;do
if [[ -n ${markinfo[$k]} ]];then
total=$(bc <<<"$total + ${markinfo[$k]}")
((count++))
fi
done
markinfo[total]="$total"
markinfo[count]="$count"
local payload="{"
local first=1
for k in cpu gpu mem disk total;do
if [[ -n ${markinfo[$k]} ]];then
[[ $first -eq 0 ]]&&payload+=","
payload+="\"${k}_score\":${markinfo[$k]}"
first=0
fi
done
payload+="}"
local resp
resp=$(curl -fsS --max-time 10 -H "Content-Type: application/json" -d "$payload" https://mark.check.place 2>/dev/null)||return
for k in cpu gpu mem disk total;do
if [[ -n ${markinfo[$k]} ]];then
local pct
pct=$(jq -r ".$k.percentile // empty" <<<"$resp")
[[ -n $pct ]]&&markinfo["${k}_pct"]="$pct"
fi
done
}
show_os(){
echo -ne "\r${sos[title]}\n"
echo -ne "\r$Font_Cyan${sos[virt]}$Font_Green${sos[${osinfo[virt]}]}$Font_Suffix\n"
echo -ne "\r$Font_Cyan${sos[arch]}$Font_Green${osinfo[arch]}$Font_Suffix\n"
echo -ne "\r$Font_Cyan${sos[os]}$Font_Green${osinfo[os]} ${osinfo[kernel]}$Font_Suffix\n"
echo -ne "\r$Font_Cyan${sos[uptime]}$Font_Green${osinfo[d]} ${sos[d]} ${osinfo[h]} ${sos[h]} ${osinfo[m]} ${sos[m]}$Font_Suffix\n"
echo -ne "\r$Font_Cyan${sos[load]}${sos[load1]}$Font_Green, ${sos[load5]}$Font_Green, ${sos[load15]}$Font_Suffix\n"
local svc_part=""
[[ -n ${osinfo[svcr]} && -n ${osinfo[svct]} ]]&&svc_part="${sos[q]}${osinfo[svcr]}/${osinfo[svct]} ${sos[svc]}"
local user_part=""
[[ -n ${osinfo[user]} ]]&&user_part="${osinfo[user]} ${sos[user]}${sos[q]}"
echo -ne "\r$Font_Cyan${sos[status]}$Font_Green$user_part${osinfo[proc]} ${sos[proc]}$svc_part$Font_Suffix\n"
echo -ne "\r$Font_Cyan${sos[loc]}$Font_Green${osinfo[lang]}, ${osinfo[charset]}, ${osinfo[tz]}${osinfo[tz_abbr]} ${osinfo[tz_offset]}$Font_Suffix\n"
}
show_mb(){
local mbline
local has_output=0
echo -ne "\r${smb[title]}\n"
mbline=""
[[ -n ${mbinfo[board_vendor]} ]]&&mbline+="${mbinfo[board_vendor]}"
[[ -n ${mbinfo[board_name]} ]]&&{
[[ -n $mbline ]]&&mbline+=", "
mbline+="${mbinfo[board_name]}"
}
[[ -n ${mbinfo[board_version]} ]]&&{
[[ -n $mbline ]]&&mbline+=", "
mbline+="${smb[ver]}${mbinfo[board_version]}"
}
[[ -n ${mbinfo[board_serial]} ]]&&{
[[ -n $mbline ]]&&mbline+=", "
mbline+="SN:${mbinfo[board_serial]}"
}
if [[ -n $mbline ]];then
echo -ne "\r$Font_Cyan${smb[mb]}$Font_Black$Font_B$Font_U$Back_White$mbline$Font_Suffix\n"
has_output=1
fi
mbline=""
[[ -n ${mbinfo[bios_vendor]} ]]&&mbline+="${mbinfo[bios_vendor]}"
[[ -n ${mbinfo[bios_version]} ]]&&{
[[ -n $mbline ]]&&mbline+=", "
mbline+="${smb[ver]}${mbinfo[bios_version]}"
}
if [[ -n $mbline ]];then
echo -ne "\r$Font_Cyan${smb[bios]}$Font_Green$mbline$Font_Suffix\n"
has_output=1
fi
if [[ -n ${mbinfo[pch_device]} || -n ${mbinfo[pci_root]} ]];then
local pch_clean=""
local root_clean=""
[[ -n ${mbinfo[pch_device]} ]]&&pch_clean="$(echo "${mbinfo[pch_device]}"|sed -E 's/^[^:]*:[^:]*:[[:space:]]*//; s/[[:space:]]*\(rev [^)]+\)//')"
[[ -n ${mbinfo[pci_root]} ]]&&root_clean="$(echo "${mbinfo[pci_root]}"|sed -E 's/^[^:]*:[^:]*:[[:space:]]*//; s/[[:space:]]*\(rev [^)]+\)//')"
if [[ -n $pch_clean ]];then
echo -ne "\r$Font_Cyan${smb[chip]}$Font_Green$pch_clean$Font_Suffix\n"
elif [[ -n $root_clean ]];then
echo -ne "\r$Font_Cyan${smb[chip]}$Font_Green$root_clean$Font_Suffix\n"
fi
if [[ -n $pch_clean && -n $root_clean ]];then
echo -ne "\r          $Font_Green$root_clean$Font_Suffix\n"
fi
has_output=1
fi
if [[ -n ${mbinfo[audio_devices]} ]];then
declare -A audio_map=()
local first=1
while IFS= read -r line;do
clean="$(echo "$line"|sed -E 's/^[^:]*:[^:]*:[[:space:]]*//; s/[[:space:]]*\(rev [^)]+\)//')"
[[ -n $clean ]]&&((audio_map["$clean"]++))
done <<<"${mbinfo[audio_devices]}"
for dev in "${!audio_map[@]}";do
count=""
[[ ${audio_map[$dev]} -gt 1 ]]&&count=" × ${audio_map[$dev]}${smb[s]}"
if [[ $first -eq 1 ]];then
echo -ne "\r$Font_Cyan${smb[audio]}$Font_Green$dev$count$Font_Suffix\n"
first=0
else
echo -ne "\r          $Font_Green$dev$count$Font_Suffix\n"
fi
has_output=1
done
fi
if [[ -n ${mbinfo[net_devices]} ]];then
declare -A net_map=()
local first=1
while IFS= read -r line;do
clean="$(echo "$line"|sed -E 's/^[^:]*:[^:]*:[[:space:]]*//; s/[[:space:]]*\(rev [^)]+\)//')"
[[ -n $clean ]]&&((net_map["$clean"]++))
done <<<"${mbinfo[net_devices]}"
for dev in "${!net_map[@]}";do
count=""
[[ ${net_map[$dev]} -gt 1 ]]&&count=" × ${net_map[$dev]}${smb[s]}"
if [[ $first -eq 1 ]];then
echo -ne "\r$Font_Cyan${smb[net]}$Font_Green$dev$count$Font_Suffix\n"
first=0
else
echo -ne "\r          $Font_Green$dev$count$Font_Suffix\n"
fi
has_output=1
done
fi
}
align_lines(){
local cpuline1="$1"
local cpuline2="$2"
local -i cpulen1="$3"
local -i cpulen2="$4"
if [[ -z $cpuline1 || -z $cpuline2 ]];then
[[ -n $cpuline1 ]]&&echo -ne "\r$Font_Cyan${scpu[cpu]}$Font_B$Font_U$Back_White$Font_Black$cpuline1$Font_Suffix\n"
[[ -n $cpuline2 ]]&&echo -ne "\r$Font_Cyan${scpu[cpu]}$Font_B$Font_U$Back_White$Font_Black$cpuline2$Font_Suffix\n"
return
fi
local w1 w2 target diff
w1=$(($(echo -n "$cpuline1"|wc -c)+cpulen2))
w2=$(($(echo -n "$cpuline2"|wc -c)+cpulen1+4))
if ((w1<w2));then
diff=$((w2-w1))
cpuline1+="$Font_Suffix$Back_White$(printf '%*s' "$diff")"
elif ((w1>w2));then
diff=$((w1-w2))
cpuline2+="$Font_Suffix$Back_White$(printf '%*s' "$diff")"
fi
echo -ne "\r$Font_Cyan${scpu[cpu]}$Font_B$Font_U$Back_White$Font_Black$cpuline1$Font_Suffix\n"
echo -ne "\r          $Font_B$Back_White$Font_Black ╚═ $cpuline2$Font_Suffix\n"
}
score_bar(){
local score="$1"
local low_min="$2"
local mid_low="$3"
local mid_high="$4"
local high_max="$5"
local seg_width=20
local pos=1
if ((score<=low_min));then
pos=1
elif ((score<mid_low));then
pos=$((1+(score-low_min)*seg_width/(mid_low-low_min)))
elif ((score<mid_high));then
pos=$((21+(score-mid_low)*seg_width/(mid_high-mid_low)))
elif ((score<high_max));then
pos=$((41+(score-mid_high)*seg_width/(high_max-mid_high)))
else
pos=60
fi
((pos<1))&&pos=1
((pos>60))&&pos=60
local bar=""
local n
if ((pos>=1));then
n=$((pos<20?pos:20))
if ((n>0));then
bar+="$Back_Red$(printf "%${n}s")$Font_Suffix"
fi
fi
if ((pos>20));then
n=$((pos-20<20?pos-20:20))
bar+="$Back_Yellow$(printf "%${n}s")$Font_Suffix"
fi
if ((pos>40));then
n=$((pos-40<20?pos-40:20))
bar+="$Back_Green$(printf "%${n}s")$Font_Suffix"
fi
local color bg
if ((pos<=20));then
color="$Font_Red"
bg="$Back_Red"
elif ((pos<=40));then
color="$Font_Yellow"
bg="$Back_Yellow"
else
color="$Font_Green"
bg="$Back_Green"
fi
bar+="\b$bg$Font_White$Font_B|$Font_Suffix"
echo -ne "$bar$Font_B$color$score$Font_Suffix"
}
cpu_gb_bar(){
local text="$1"
local pct="$2"
local width=$((pct*20/100))
((width<1))&&width=1
((width>20))&&width=20
text=$(printf "%20s" "$text")
local left="${text:0:width}"
local right="${text:width}"
local out=""
if ((width>0));then
out+="$Back_Cyan$Font_White$left$Font_Suffix"
fi
if ((width<20));then
out+="$Font_Cyan$right$Font_Suffix"
fi
printf '%s' "$out"
}
show_geekbench_cpu_table(){
local key name disp_name
local s_score m_score s_desc s_pct m_desc m_pct
local line
local s_pct_max=0 scaled_s_pct
declare -A seen
for key in "${!cpuinfo[@]}";do
[[ $key =~ ^gb\.[sm]\.[gi]\.(.+)$ ]]||continue
name="${BASH_REMATCH[1]}"
name="${name%%.*}"
seen["$name"]=1
done
for name in "${!seen[@]}";do
if [[ -n ${cpuinfo[gb.s.i.$name.pct]} ]];then
((cpuinfo[gb.s.i.$name.pct]>s_pct_max))&&s_pct_max="${cpuinfo[gb.s.i.$name.pct]}"
fi
done
for name in $(printf "%s\n" "${!seen[@]}"|sort);do
if [[ -n ${cpuinfo[gb.s.g.$name]} || -n ${cpuinfo[gb.m.g.$name]} ]];then
s_score="${cpuinfo[gb.s.g.$name]}"
m_score="${cpuinfo[gb.m.g.$name]}"
disp_name="${name//_/ }"
line=""
line+="$Font_Cyan$(printf "%-22s" "$disp_name")"
line+="$Font_Green$Font_B$(printf "%7s" "$s_score")$Font_Suffix"
line+="$Font_Cyan    Single-Core Score||"
line+="$Font_Green$Font_B$(printf "%7s" "$m_score")$Font_Suffix"
line+="$Font_Cyan     Multi-Core Score$Font_Suffix"
echo -ne "\r$line\n"
fi
done
for name in $(printf "%s\n" "${!seen[@]}"|sort);do
if [[ -z ${cpuinfo[gb.s.g.$name]} && -z ${cpuinfo[gb.m.g.$name]} ]];then
s_score="${cpuinfo[gb.s.i.$name]}"
m_score="${cpuinfo[gb.m.i.$name]}"
s_desc="${cpuinfo[gb.s.i.$name.desc]}"
m_desc="${cpuinfo[gb.m.i.$name.desc]}"
s_pct="${cpuinfo[gb.s.i.$name.pct]:-0}"
m_pct="${cpuinfo[gb.m.i.$name.pct]:-0}"
disp_name="${name//_/ }"
if ((s_pct_max>0));then
scaled_s_pct=$((s_pct*100/s_pct_max))
else
scaled_s_pct=0
fi
line=""
line+="$Font_Cyan$(printf "%-22s" "$disp_name")"
line+="$Font_Green$Font_B$(printf "%7s" "$s_score")"
line+=" $Font_Suffix$(cpu_gb_bar "$s_desc" "$scaled_s_pct")"
line+="$Font_Cyan||"
line+="$Font_Green$Font_B$(printf "%7s" "$m_score")"
line+=" $Font_Suffix$(cpu_gb_bar "$m_desc" "$m_pct")"
echo -ne "\r$line\n"
fi
done
}
show_cpu(){
local cpuline cpuline1 cpuline2 cpulen1 cpulen2
echo -ne "\r${scpu[title]}\n"
cpulen1=0
cpuline1="${cpuinfo[name]}"
if [[ -n ${cpuinfo[stepping]} ]];then
cpuline1+=" ${scpu[step]}${cpuinfo[stepping]}"
((cpulen1+=scpu[lstep]))
fi
if [[ -n ${cpuinfo[family]} ]];then
cpuline1+=" (${cpuinfo[family]}${scpu[gen]})"
((cpulen1+=scpu[lgen]))
fi
[[ -n ${cpuinfo[op_mode]} ]]&&cpuline1+=" ${cpuinfo[op_mode]}"
if [[ ${cpuinfo[sockets]} -gt 1 ]];then
cpuline1+=" × ${cpuinfo[sockets]}${scpu[num]}"
((cpulen1+=scpu[lnum]+1))
fi
cpuline2=""
cpulen2=0
if [[ -n ${cpuinfo[cores]} && ${cpuinfo[cores]} -gt 0 ]];then
cpuline2+="${cpuinfo[cores]}${scpu[core]}"
((cpulen2+=scpu[lcore]))
fi
if [[ -n ${cpuinfo[cg_threads]} ]];then
cpuline2+=", ${scpu[limit1]}${cpuinfo[cg_threads]}${scpu[limit2]}"
((cpulen2+=scpu[llimit]))
fi
if [[ -n ${cpuinfo[threads]} && ${cpuinfo[threads]} -gt 0 && ${osinfo[virt_kind]} != "container" ]];then
[[ -n $cpuline2 ]]&&cpuline2+=", "
cpuline2+="${cpuinfo[threads]}${scpu[thread]}"
((cpulen2+=scpu[lthread]))
fi
if [[ -n ${cpuinfo[mhz]} ]];then
[[ -n $cpuline2 ]]&&cpuline2+=", "
cpuline2+="${cpuinfo[mhz]}MHz"
fi
[[ -n "${cpuinfo[min_mhz]}${cpuinfo[max_mhz]}" ]]&&cpuline2+=" (${cpuinfo[min_mhz]}MHz ~ ${cpuinfo[max_mhz]}MHz)"
if [[ -n ${cpuinfo[usage]} ]];then
cpuline2+=", ${scpu[usage]}${cpuinfo[usage]}%"
((cpulen2+=scpu[lusage]))
fi
align_lines "$cpuline1" "$cpuline2" "$cpulen1" "$cpulen2"
if [[ ${cpuinfo[cache_fallback]} == "1" && -n ${cpuinfo[cache_total]} ]];then
echo -ne "\r$Font_Cyan${scpu[cache]}$Font_Green${cpuinfo[cache_total]}$Font_Suffix\n"
elif [[ -n "${cpuinfo[L1d]}${cpuinfo[L1i]}${cpuinfo[L2]}${cpuinfo[L3]}" ]];then
cpuline="$Font_Cyan${scpu[cache]}$Font_Green"
[[ -n ${cpuinfo[L1d]} ]]&&cpuline+="L1d ${cpuinfo[L1d]},"
[[ -n ${cpuinfo[L1i]} ]]&&cpuline+=" L1i ${cpuinfo[L1i]},"
[[ -n ${cpuinfo[L2]} ]]&&cpuline+=" L2 ${cpuinfo[L2]},"
[[ -n ${cpuinfo[L3]} ]]&&cpuline+=" L3 ${cpuinfo[L3]}"
cpuline="${cpuline%,}"
cpuline="${cpuline#"${cpuline%%[![:space:]]*}"}"
echo -ne "\r$cpuline$Font_Suffix\n"
fi
if [[ ${cpuinfo[arch]} =~ x86_64|i[3-6]86 ]];then
echo -ne "\r$Font_Cyan${scpu[flag]}$Font_Suffix"
echo -ne "$([[ ${cpuinfo[vt]} ]]&&echo "$Back_Green ✔"||echo "$Back_Red ✘") VT-x/AMD-V $Font_Suffix"
echo -ne "  $([[ ${cpuinfo[aes]} ]]&&echo "$Back_Green ✔"||echo "$Back_Red ✘") AES-NI $Font_Suffix"
echo -ne "  $([[ ${cpuinfo[avx2]} ]]&&echo "$Back_Green ✔"||echo "$Back_Red ✘") AVX2 $Font_Suffix"
echo -ne "  $([[ ${cpuinfo[bmi]} ]]&&echo "$Back_Green ✔"||echo "$Back_Red ✘") BMI1/2 $Font_Suffix"
echo -ne "  $([[ ${cpuinfo[ept]} ]]&&echo "$Back_Green ✔"||echo "$Back_Red ✘") EPT/NPT $Font_Suffix\n"
else
echo -ne "\r$Font_Cyan${scpu[flag]}$Font_Suffix"
echo -ne "$([[ ${cpuinfo[el2]} ]]&&echo "$Back_Green ✔"||echo "$Back_Red ✘") EL2 $Font_Suffix"
echo -ne "  $([[ ${cpuinfo[neon]} ]]&&echo "$Back_Green ✔"||echo "$Back_Red ✘") NEON $Font_Suffix"
echo -ne "  $([[ ${cpuinfo[aes_sha]} ]]&&echo "$Back_Green ✔"||echo "$Back_Red ✘") AES/SHA $Font_Suffix"
echo -ne "  $([[ ${cpuinfo[atomics]} ]]&&echo "$Back_Green ✔"||echo "$Back_Red ✘") Atomics $Font_Suffix"
echo -ne "  $([[ ${cpuinfo[sve]} ]]&&echo "$Back_Green ✔"||echo "$Back_Red ✘") SVE $Font_Suffix\n"
fi
if [[ -n ${cpuinfo[temp_count]} && ${cpuinfo[temp_count]} -gt 0 ]]&&[[ (-n ${cpuinfo[sysbench_single]} && -n ${cpuinfo[sysbench_multi]}) || (-n ${cpuinfo[geekbench_single]} && -n ${cpuinfo[geekbench_multi]}) ]];then
local min_list=""
local max_list=""
for ((i=0; i<cpuinfo[temp_count]; i++));do
[[ -n ${cpuinfo[temp${i}_min]} ]]&&{
[[ -n $min_list ]]&&min_list+="$Font_Green/ "
min_list+="$(temp_color "${cpuinfo[temp${i}_min]}")${cpuinfo[temp${i}_min]}℃ $Font_Suffix"
}
[[ -n ${cpuinfo[temp${i}_max]} ]]&&{
[[ -n $max_list ]]&&max_list+="$Font_Green/ "
max_list+="$(temp_color "${cpuinfo[temp${i}_max]}")${cpuinfo[temp${i}_max]}℃ $Font_Suffix"
}
done
if [[ -n $min_list || -n $max_list ]];then
echo -ne "\r$Font_Cyan${scpu[temp]}$Font_Green${scpu[min]}$min_list     $Font_Green${scpu[max]}$max_list$Font_Suffix\n"
fi
fi
if [[ -n ${cpuinfo[sysbench_single]} || -n ${cpuinfo[sysbench_multi]} ]];then
echo -ne "\r$Font_Cyan${scpu[sysbench]}$Font_Green"
[[ -n ${cpuinfo[sysbench_single]} ]]&&echo -ne "${scpu[singlet]} ${cpuinfo[sysbench_single]}     "
[[ -n ${cpuinfo[sysbench_multi]} ]]&&echo -ne "${scpu[multit]} ${cpuinfo[sysbench_multi]}"
echo -ne "$Font_Suffix\n"
fi
if [[ -n ${cpuinfo[geekbench_single]} && -n ${cpuinfo[geekbench_multi]} ]];then
echo -ne "\r$Font_Cyan${scpu[base]}$Font_Suffix$Font_I${Back_Red}J1900 N5105 N100 670${Back_Yellow}0K 9900K 5900X 12900${Back_Green}K 14900K 7713 7995WX$Font_Suffix\n"
local scoretest="$(score_bar ${cpuinfo[geekbench_single]} 0 4500 18000 80000)"
echo -ne "\r$Font_Cyan${scpu[single]}$Font_Suffix$scoretest$Font_Suffix\n"
scoretest="$(score_bar ${cpuinfo[geekbench_multi]} 0 4500 18000 80000)"
echo -ne "\r$Font_Cyan${scpu[multi]}$Font_Suffix$scoretest$Font_Suffix\n"
fi
[[ mode_verbose -eq 1 ]]&&show_geekbench_cpu_table
if [[ -n ${cpuinfo[url]} ]];then
echo -ne "\r$Font_Cyan${scpu[url]}$Font_Green$Font_U${cpuinfo[url]}$Font_Suffix\n"
fi
}
temp_color(){
local t="$1"
if ((t<60));then
echo -ne "$Font_Green"
elif ((t<80));then
echo -ne "$Font_Yellow"
else
echo -ne "$Font_Red"
fi
}
gpu_gb_bar(){
local text="$1"
local pct="$2"
local width=$((pct*50/100))
((width<1))&&width=1
((width>50))&&width=50
text=$(printf "%50s" "$text")
local left="${text:0:width}"
local right="${text:width}"
local out=""
if ((width>0));then
out+="$Back_Cyan$Font_White$left$Font_Suffix"
fi
if ((width<50));then
out+="$Font_Cyan$right$Font_Suffix"
fi
printf '%s' "$out"
}
show_geekbench_gpu_table(){
local key name disp_name
local s_score m_score s_desc s_pct m_desc m_pct
local line
local s_pct_max=0 scaled_s_pct
declare -A seen
for key in "${!gpuinfo[@]}";do
[[ $key =~ ^gb\.(.+)$ ]]||continue
name="${BASH_REMATCH[1]}"
name="${name%%.*}"
seen["$name"]=1
done
for name in $(printf "%s\n" "${!seen[@]}"|sort);do
if [[ -z ${gpuinfo[gb.s.g.$name]} && -z ${gpuinfo[gb.m.g.$name]} ]];then
s_score="${gpuinfo[gb.$name]}"
s_desc="${gpuinfo[gb.$name.desc]}"
s_pct="${gpuinfo[gb.$name.pct]:-0}"
disp_name="${name//_/ }"
line=""
line+="$Font_Cyan$(printf "%-22s" "$disp_name")"
line+="$Font_Green$Font_B$(printf "%7s" "$s_score")"
line+=" $Font_Suffix$(gpu_gb_bar "$s_desc" "$s_pct")"
echo -ne "\r$line\n"
fi
done
}
show_gpu(){
[[ ${gpuinfo[count]:-0} -eq 0 ]]&&return
echo -ne "\r${sgpu[title]}\n"
local -A frqmemout
for ((i=0; i<gpuinfo[count]; i++));do
local parts=()
if [[ -n ${gpuinfo[item$i.freq_max]} ]];then
parts+=("${gpuinfo[item$i.freq_max]}MHz")
fi
if [[ -n ${gpuinfo[item$i.vram_gb]} ]];then
parts+=("${gpuinfo[item$i.vram_gb]}GB")
fi
if ((${#parts[@]}>0));then
frqmemout[$i]=$(IFS=" "
echo "${parts[*]}")
else
frqmemout[$i]=""
fi
done
local -A gpulen
local -A gpuline
local gpumax=0
local gpudiff=""
for ((i=0; i<gpuinfo[count]; i++));do
gpuline[$i]="[${sgpu[${gpuinfo[item$i.type]}]}]}]${gpuinfo[item$i.name]} ${frqmemout[$i]}"
gpulen[$i]=$(($(echo -n "${gpuline[$i]}"|wc -c)))
((gpulen[$i]>gpumax))&&gpumax=$((gpulen[$i]))
done
for ((i=0; i<gpuinfo[count]; i++));do
gpudiff=$(printf '%*s' "$((gpumax-gpulen[$i]))")
if [[ $i -eq 0 ]];then
echo -ne "\r$Font_Cyan${sgpu[gpu]}$Font_B$Back_White$Font_Black[${sgpu[${gpuinfo[item$i.type]}]}]$Font_U${gpuinfo[item$i.name]} ${frqmemout[$i]}$Font_Suffix$Back_White$gpudiff$Font_Suffix\n"
else
echo -ne "\r          $Font_B$Back_White$Font_Black[${sgpu[${gpuinfo[item$i.type]}]}]$Font_U${gpuinfo[item$i.name]} ${frqmemout[$i]}$Font_Suffix$Back_White$gpudiff$Font_Suffix\n"
fi
done
[[ ${gpuinfo[has_dgpu]} != "1" ]]&&return
[[ ${gpuinfo[driver]} == "1" ]]&&drv_flag="$Back_Green ✔"||drv_flag="$Back_Red ✘"
[[ ${gpuinfo[opencl]} == "1" ]]&&cl_flag="$Back_Green ✔"||cl_flag="$Back_Red ✘"
[[ ${gpuinfo[cuda]} == "1" ]]&&cuda_flag="$Back_Green ✔"||cuda_flag="$Back_Red ✘"
echo -ne "\r$Font_Cyan${sgpu[ft]}$Font_Suffix$drv_flag ${sgpu[driver]} $Font_Suffix   $cl_flag OpenCL $Font_Suffix   $cuda_flag CUDA $Font_Suffix\n"
if [[ -n ${gpuinfo[geekbench]} ]];then
if [[ -n ${gpuinfo[temp_count]} && ${gpuinfo[temp_count]} -gt 0 ]];then
local min_list=""
local max_list=""
for ((i=0; i<gpuinfo[temp_count]; i++));do
[[ -n ${gpuinfo[temp${i}_min]} ]]&&{
[[ -n $min_list ]]&&min_list+="$Font_Green/ "
min_list+="$(temp_color "${gpuinfo[temp${i}_min]}")${gpuinfo[temp${i}_min]}℃ $Font_Suffix"
}
[[ -n ${gpuinfo[temp${i}_max]} ]]&&{
[[ -n $max_list ]]&&max_list+="$Font_Green/ "
max_list+="$(temp_color "${gpuinfo[temp${i}_max]}")${gpuinfo[temp${i}_max]}℃ $Font_Suffix"
}
done
if [[ -n $min_list || -n $max_list ]];then
echo -ne "\r$Font_Cyan${sgpu[temp]}$Font_Green${sgpu[min]}$min_list     $Font_Green${sgpu[max]}$max_list$Font_Suffix\n"
fi
fi
local scoretest="$(score_bar ${gpuinfo[geekbench]} 0 40000 100000 500000)"
echo -ne "\r$Font_Cyan${sgpu[base]}$Font_Suffix$Font_I${Back_Red}HD3000 GTX750 GTX970$Back_Yellow GTX1660 RTX2060 RTX${Back_Green}3070 RTX4080 RTX5090$Font_Suffix $Font_Green(${gpuinfo[gb_type]})$Font_Suffix\n"
echo -ne "\r$Font_Cyan${sgpu[score]}$Font_Suffix$scoretest$Font_Suffix\n"
fi
[[ mode_verbose -eq 1 ]]&&show_geekbench_gpu_table
if [[ -n ${gpuinfo[url]} ]];then
echo -ne "\r$Font_Cyan${sgpu[url]}$Font_Green$Font_U${gpuinfo[url]}$Font_Suffix\n"
fi
}
show_mem(){
echo -ne "\r${smem[title]}\n"
local last=-1
local -A memlen
local -A memline
memline[f]="${smem[total]} ${meminfo[total]},  ${smem[used]} ${meminfo[used]}(${meminfo[mem_used_pct]}%),  ${smem[avail]} ${meminfo[avail]}(${meminfo[mem_avail_pct]}%)"
memlen[f]=$(($(echo -n "${memline[f]}"|wc -c)-smem[ltotal]))
local memmax=$((memlen[f]))
for ((i=0; i<${meminfo[count]}; i++));do
p="mem$i"
[[ -z ${meminfo[$p.size]} ]]&&continue
memline[$i]="[${meminfo[$p.slot]}]${meminfo[$p.vendor]} ${meminfo[$p.size]} ${meminfo[$p.type]} ${meminfo[$p.speed]} ${meminfo[$p.part]} SN:${meminfo[$p.serial]}"
memlen[$i]=$(($(echo -n "${memline[$i]}"|wc -c)+4))
((memlen[$i]>memmax))&&memmax=$((memlen[$i]))
done
for ((i=0; i<${meminfo[count]}; i++));do
[[ -n ${meminfo[mem$i.size]} ]]&&last=$i
done
local memdiff=$(printf '%*s' "$((memmax-memlen[f]))")
if [[ -n ${meminfo[total]} ]];then
echo -ne "\r$Font_Cyan${smem[mem]}$Font_B$Font_U$Back_White$Font_Black${smem[total]} ${meminfo[total]},  ${smem[used]} ${meminfo[used]}(${meminfo[mem_used_pct]}%),  ${smem[avail]} ${meminfo[avail]}(${meminfo[mem_avail_pct]}%)$Font_Suffix$Back_White$memdiff$Font_Suffix\n"
fi
for ((i=0; i<${meminfo[count]}; i++));do
p="mem$i"
[[ -z ${meminfo[$p.size]} ]]&&continue
memdiff=$(printf '%*s' "$((memmax-memlen[$i]))")
if [[ $i -eq $last ]];then
prefix="          $Font_B$Back_White$Font_Black ╚═ "
else
prefix="          $Font_B$Back_White$Font_Black ╠═ "
fi
echo -ne "\r$prefix[${meminfo[$p.slot]}]${meminfo[$p.vendor]} ${meminfo[$p.size]} ${meminfo[$p.type]} ${meminfo[$p.speed]} ${meminfo[$p.part]} SN:${meminfo[$p.serial]}$memdiff$Font_Suffix\n"
done
if [[ -n ${meminfo[swap_total]} ]];then
echo -ne "\r$Font_Cyan${smem[swap]}$Font_Green${smem[total]} ${meminfo[swap_total]},  ${smem[used]} ${meminfo[swap_used]}(${meminfo[swap_used_pct]}%),  ${smem[avail]} ${meminfo[swap_avail]}(${meminfo[swap_avail_pct]}%)$Font_Suffix\n"
fi
if [[ ${osinfo[virt]} == "kvm" ]];then
local balloon_flag ksm_flag
[[ ${meminfo[balloon]} == "1" ]]&&balloon_flag="$Back_Red ✔"||balloon_flag="$Back_Green ✘"
[[ ${meminfo[ksm]} == "1" ]]&&ksm_flag="$Back_Red ✔"||ksm_flag="$Back_Green ✘"
echo -ne "\r$Font_Cyan${smem[reuse]}$Font_Suffix$balloon_flag ${smem[balloon]} $Font_Suffix   $ksm_flag ${smem[ksm]} $Font_Suffix\n"
fi
if [[ ${osinfo[virt]} == "lxc" ]]&&[[ -n ${meminfo[neighbor]} ]]&&((meminfo[neighbor]>0));then
if ((meminfo[neighbor]<=200));then
ncolor="$Font_Green"
elif ((meminfo[neighbor]<=500));then
ncolor="$Font_Yellow"
else
ncolor="$Font_Red"
fi
echo -ne "\r$Font_Cyan${smem[nb]}$ncolor${meminfo[neighbor]} ${smem[nbnum]}$Font_Suffix\n"
fi
local out=""
if [[ -n ${meminfo[read]} ]];then
if (($(awk "BEGIN{print (${meminfo[read]} < 15000)}")));then
c="$Font_Red"
elif (($(awk "BEGIN{print (${meminfo[read]} < 30000)}")));then
c="$Font_Yellow"
else
c="$Font_Green"
fi
out+="$c${smem[read]} ${meminfo[read]} MB/s$Font_Suffix    "
fi
if [[ -n ${meminfo[write]} ]];then
if (($(awk "BEGIN{print (${meminfo[write]} < 15000)}")));then
c="$Font_Red"
elif (($(awk "BEGIN{print (${meminfo[write]} < 30000)}")));then
c="$Font_Yellow"
else
c="$Font_Green"
fi
out+="$c${smem[write]} ${meminfo[write]} MB/s$Font_Suffix    "
fi
if [[ -n ${meminfo[lat]} ]];then
if ((meminfo[lat]>200));then
c="$Font_Red"
elif ((meminfo[lat]>100));then
c="$Font_Yellow"
else
c="$Font_Green"
fi
out+="$c${smem[lat]} ${meminfo[lat]} ns$Font_Suffix"
fi
[[ -n $out ]]&&echo -ne "\r$Font_Cyan${smem[sysbench]}$out\n"
}
cap_to_bytes(){
local s="$1"
[[ -z $s ]]&&return
awk '
        BEGIN {
            v = s
        }
    ' s="$s" '
        {
            if ($0 ~ /TB$/) {
                sub(/TB$/, "", $0)
                printf "%.0f", $0 * 1024 * 1024 * 1024 * 1024
            } else if ($0 ~ /GB$/) {
                sub(/GB$/, "", $0)
                printf "%.0f", $0 * 1024 * 1024 * 1024
            }
        }
    '
}
rw_to_bytes(){
local s="$1"
[[ -z $s ]]&&return
awk '
        {
            if ($0 ~ /TB$/) {
                sub(/TB$/, "", $0)
                printf "%.0f", $0 * 1024 * 1024 * 1024 * 1024
            } else if ($0 ~ /GB$/) {
                sub(/GB$/, "", $0)
                printf "%.0f", $0 * 1024 * 1024 * 1024
            }
        }
    ' <<<"$s"
}
fio_bar_width(){
local mb="$1"
local min=1
local max=10000
awk -v v="$mb" -v min="$min" -v max="$max" '
        BEGIN {
            if (v <= min) { print 1; exit }
            if (v >= max) { print 16; exit }
            # 对数映射
            w = (log(v) - log(min)) / (log(max) - log(min)) * 16
            if (w < 1) w = 1
            if (w > 16) w = 16
            printf "%d", int(w + 0.5)
        }
    '
}
fio_bar_width_mode(){
local mb="$1"
local min=1
local max=20000
awk -v v="$mb" -v min="$min" -v max="$max" '
        BEGIN {
            if (v <= min) { print 1; exit }
            if (v >= max) { print 34; exit }
            w = (log(v) - log(min)) / (log(max) - log(min)) * 34
            if (w < 1) w = 1
            if (w > 34) w = 34
            printf "%d", int(w + 0.5)
        }
    '
}
fio_bar_color(){
local mb="$1"
local scenario="$2"
case "$scenario" in
rnd4K_q1)(($(awk "BEGIN{print ($mb < 5)}")))&&echo "$Back_Red"&&return
(($(awk "BEGIN{print ($mb < 50)}")))&&echo "$Back_Yellow"&&return
echo "$Back_Green"
;;
rnd4K_q32)(($(awk "BEGIN{print ($mb < 20)}")))&&echo "$Back_Red"&&return
(($(awk "BEGIN{print ($mb < 500)}")))&&echo "$Back_Yellow"&&return
echo "$Back_Green"
;;
seq1M_q1)(($(awk "BEGIN{print ($mb < 100)}")))&&echo "$Back_Red"&&return
(($(awk "BEGIN{print ($mb < 1000)}")))&&echo "$Back_Yellow"&&return
echo "$Back_Green"
;;
seq1M_q8)(($(awk "BEGIN{print ($mb < 150)}")))&&echo "$Back_Red"&&return
(($(awk "BEGIN{print ($mb < 2000)}")))&&echo "$Back_Yellow"&&return
echo "$Back_Green"
;;
*)echo "$Back_Black"
esac
}
fio_bar_color_mode(){
local mb="$1"
local scenario="$2"
case "$scenario" in
512B_q4)(($(awk "BEGIN{print ($mb < 10)}")))&&echo "$Back_Red"&&return
(($(awk "BEGIN{print ($mb < 25)}")))&&echo "$Back_Yellow"&&return
echo "$Back_Green"
;;
1K_q4)(($(awk "BEGIN{print ($mb < 20)}")))&&echo "$Back_Red"&&return
(($(awk "BEGIN{print ($mb < 50)}")))&&echo "$Back_Yellow"&&return
echo "$Back_Green"
;;
2K_q4)(($(awk "BEGIN{print ($mb < 40)}")))&&echo "$Back_Red"&&return
(($(awk "BEGIN{print ($mb < 100)}")))&&echo "$Back_Yellow"&&return
echo "$Back_Green"
;;
4K_q4)(($(awk "BEGIN{print ($mb < 90)}")))&&echo "$Back_Red"&&return
(($(awk "BEGIN{print ($mb < 180)}")))&&echo "$Back_Yellow"&&return
echo "$Back_Green"
;;
8K_q4)(($(awk "BEGIN{print ($mb < 120)}")))&&echo "$Back_Red"&&return
(($(awk "BEGIN{print ($mb < 300)}")))&&echo "$Back_Yellow"&&return
echo "$Back_Green"
;;
16K_q4)(($(awk "BEGIN{print ($mb < 150)}")))&&echo "$Back_Red"&&return
(($(awk "BEGIN{print ($mb < 500)}")))&&echo "$Back_Yellow"&&return
echo "$Back_Green"
;;
32K_q4)(($(awk "BEGIN{print ($mb < 150)}")))&&echo "$Back_Red"&&return
(($(awk "BEGIN{print ($mb < 700)}")))&&echo "$Back_Yellow"&&return
echo "$Back_Green"
;;
64K_q4)(($(awk "BEGIN{print ($mb < 150)}")))&&echo "$Back_Red"&&return
(($(awk "BEGIN{print ($mb < 900)}")))&&echo "$Back_Yellow"&&return
echo "$Back_Green"
;;
128K_q4)(($(awk "BEGIN{print ($mb < 150)}")))&&echo "$Back_Red"&&return
(($(awk "BEGIN{print ($mb < 1200)}")))&&echo "$Back_Yellow"&&return
echo "$Back_Green"
;;
256K_q4|512K_q4|1M_q4|2M_q4|4M_q4|8M_q4|16M_q4|32M_q4|64M_q4)(($(awk "BEGIN{print ($mb < 150)}")))&&echo "$Back_Red"&&return
(($(awk "BEGIN{print ($mb < 2000)}")))&&echo "$Back_Yellow"&&return
echo "$Back_Green"
;;
*)echo "$Back_Black"
esac
}
fio_font_color(){
local mb="$1"
local scenario="$2"
case "$scenario" in
rnd4K_q1)(($(awk "BEGIN{print ($mb < 5)}")))&&echo "$Font_Red"&&return
(($(awk "BEGIN{print ($mb < 50)}")))&&echo "$Font_Yellow"&&return
echo "$Font_Green"
;;
rnd4K_q32)(($(awk "BEGIN{print ($mb < 20)}")))&&echo "$Font_Red"&&return
(($(awk "BEGIN{print ($mb < 500)}")))&&echo "$Font_Yellow"&&return
echo "$Font_Green"
;;
seq1M_q1)(($(awk "BEGIN{print ($mb < 100)}")))&&echo "$Font_Red"&&return
(($(awk "BEGIN{print ($mb < 1000)}")))&&echo "$Font_Yellow"&&return
echo "$Font_Green"
;;
seq1M_q8)(($(awk "BEGIN{print ($mb < 150)}")))&&echo "$Font_Red"&&return
(($(awk "BEGIN{print ($mb < 2000)}")))&&echo "$Font_Yellow"&&return
echo "$Font_Green"
;;
*)echo "$Font_Green"
esac
}
fio_font_color_mode(){
local mb="$1"
local scenario="$2"
case "$scenario" in
512B_q4)(($(awk "BEGIN{print ($mb < 10)}")))&&echo "$Font_Red"&&return
(($(awk "BEGIN{print ($mb < 25)}")))&&echo "$Font_Yellow"&&return
echo "$Font_Green"
;;
1K_q4)(($(awk "BEGIN{print ($mb < 20)}")))&&echo "$Font_Red"&&return
(($(awk "BEGIN{print ($mb < 50)}")))&&echo "$Font_Yellow"&&return
echo "$Font_Green"
;;
2K_q4)(($(awk "BEGIN{print ($mb < 40)}")))&&echo "$Font_Red"&&return
(($(awk "BEGIN{print ($mb < 100)}")))&&echo "$Font_Yellow"&&return
echo "$Font_Green"
;;
4K_q4)(($(awk "BEGIN{print ($mb < 90)}")))&&echo "$Font_Red"&&return
(($(awk "BEGIN{print ($mb < 180)}")))&&echo "$Font_Yellow"&&return
echo "$Font_Green"
;;
8K_q4)(($(awk "BEGIN{print ($mb < 120)}")))&&echo "$Font_Red"&&return
(($(awk "BEGIN{print ($mb < 300)}")))&&echo "$Font_Yellow"&&return
echo "$Font_Green"
;;
16K_q4)(($(awk "BEGIN{print ($mb < 150)}")))&&echo "$Font_Red"&&return
(($(awk "BEGIN{print ($mb < 500)}")))&&echo "$Font_Yellow"&&return
echo "$Font_Green"
;;
32K_q4)(($(awk "BEGIN{print ($mb < 150)}")))&&echo "$Font_Red"&&return
(($(awk "BEGIN{print ($mb < 700)}")))&&echo "$Font_Yellow"&&return
echo "$Font_Green"
;;
64K_q4)(($(awk "BEGIN{print ($mb < 150)}")))&&echo "$Font_Red"&&return
(($(awk "BEGIN{print ($mb < 900)}")))&&echo "$Font_Yellow"&&return
echo "$Font_Green"
;;
128K_q4)(($(awk "BEGIN{print ($mb < 150)}")))&&echo "$Font_Red"&&return
(($(awk "BEGIN{print ($mb < 1200)}")))&&echo "$Font_Yellow"&&return
echo "$Font_Green"
;;
256K_q4|512K_q4|1M_q4|2M_q4|4M_q4|8M_q4|16M_q4|32M_q4|64M_q4)(($(awk "BEGIN{print ($mb < 150)}")))&&echo "$Font_Red"&&return
(($(awk "BEGIN{print ($mb < 2000)}")))&&echo "$Font_Yellow"&&return
echo "$Font_Green"
;;
*)echo "$Font_Green"
esac
}
fio_paint_bar(){
local text="$1"
local mb="$2"
local scenario="$3"
local width color
width="$(fio_bar_width "$mb")"
color="$(fio_bar_color "$mb" "$scenario")"
fcolor="$(fio_font_color "$mb" "$scenario")"
printf "%b%s%b%s" \
"$color" \
"${text:0:width}" \
"$Font_Suffix$fcolor" \
"${text:width}$Font_Suffix"
}
fio_paint_bar_mode(){
local text="$1"
local mb="$2"
local scenario="$3"
local width color fcolor
width="$(fio_bar_width_mode "$mb")"
color="$(fio_bar_color_mode "$mb" "$scenario")"
fcolor="$(fio_font_color_mode "$mb" "$scenario")"
printf "%b%s%b%s" \
"$color" \
"${text:0:width}" \
"$Font_Suffix$fcolor" \
"${text:width}$Font_Suffix"
}
fmt_fio_cell(){
local bw_kb="$1"
local iops="$2"
local scenario="$3"
local bw_s iops_s bw_mb
[[ -z $bw_kb || -z $iops ]]&&{
echo "                "
return
}
bw_mb=$(awk -v kb="$bw_kb" 'BEGIN{printf "%.6f", kb/1024}')
if ((bw_kb<1024));then
bw_s="${bw_kb}KB/s"
else
bw_mb=$(awk -v kb="$bw_kb" 'BEGIN{printf "%.6f", kb/1024}')
if (($(awk -v v="$bw_mb" 'BEGIN{print (v < 10)}')));then
bw_s="$(awk -v v="$bw_mb" 'BEGIN{printf "%.2fMB/s", v}')"
elif (($(awk -v v="$bw_mb" 'BEGIN{print (v < 100)}')));then
bw_s="$(awk -v v="$bw_mb" 'BEGIN{printf "%.1fMB/s", v}')"
else
bw_s="$(awk -v v="$bw_mb" 'BEGIN{printf "%.0fMB/s", v}')"
fi
fi
if ((iops<1000));then
iops_s="$iops"
elif ((iops<10000));then
iops_s="$(awk -v v="$iops" 'BEGIN{printf "%.1fk", v/1000}')"
elif ((iops<1000000));then
iops_s="$(((iops+500)/1000))k"
elif ((iops<10000000));then
iops_s="$(awk -v v="$iops" 'BEGIN{printf "%.1fm", v/1000000}')"
else
iops_s="$(((iops+500000)/1000000))m"
fi
local cell
cell="$(printf "%-11s%5s" "$bw_s" "$iops_s")"
fio_paint_bar "$cell" "$bw_mb" "$scenario"
}
fmt_fio_cell_mode(){
local bw_kb="$1"
local iops="$2"
local scenario="$3"
local bw_mb bw_s iops_s cell
[[ -z $bw_kb || -z $iops ]]&&{
printf "%-34s" ""
return
}
bw_mb=$(awk -v kb="$bw_kb" 'BEGIN{printf "%.6f", kb/1024}')
if ((bw_kb<1024));then
bw_s="${bw_kb}KB/s"
elif (($(awk "BEGIN{print ($bw_mb < 10)}")));then
bw_s="$(awk -v v="$bw_mb" 'BEGIN{printf "%.2fMB/s", v}')"
elif (($(awk "BEGIN{print ($bw_mb < 100)}")));then
bw_s="$(awk -v v="$bw_mb" 'BEGIN{printf "%.1fMB/s", v}')"
else
bw_s="$(awk -v v="$bw_mb" 'BEGIN{printf "%.0fMB/s", v}')"
fi
if ((iops<1000));then
iops_s="$iops"
elif ((iops<10000));then
iops_s="$(awk -v v="$iops" 'BEGIN{printf "%.1fk", v/1000}')"
elif ((iops<1000000));then
iops_s="$(((iops+500)/1000))k"
else
iops_s="$(awk -v v="$iops" 'BEGIN{printf "%.1fm", v/1000000}')"
fi
cell="$(printf "%-16s%18s" "$bw_s" "$iops_s")"
fio_paint_bar_mode "$cell" "$bw_mb" "$scenario"
}
show_disk(){
echo -ne "\r${sdisk[title]}\n"
local -A disklen
local -A diskline
local -A smartlen
local -A smartline
disklen[f]=0
diskline[f]=""
if [[ -n ${diskinfo[count]} && ${diskinfo[count]} -gt 0 ]];then
diskline[f]="${sdisk[count]}${diskinfo[count]}"
disklen[f]=$((disklen[f]-sdisk[lcount]))
fi
if [[ -n ${diskinfo[total]} && ${diskinfo[total]} -gt 0 ]];then
[[ -n ${diskline[f]} ]]&&diskline[f]+=",  "
diskline[f]+="${sdisk[total]}$(fmt_bytes "${diskinfo[total]}")"
disklen[f]=$((disklen[f]-sdisk[ltotal]))
fi
if [[ -n ${diskinfo[used]} && ${diskinfo[used]} -gt 0 && -n ${diskinfo[p_used]} ]];then
[[ -n ${diskline[f]} ]]&&diskline[f]+=",  "
diskline[f]+="${sdisk[used]}$(fmt_bytes "${diskinfo[used]}")(${diskinfo[p_used]}%)"
disklen[f]=$((disklen[f]-sdisk[lused]))
fi
if [[ -n ${diskinfo[avail]} && ${diskinfo[avail]} -gt 0 && -n ${diskinfo[p_avail]} ]];then
[[ -n ${diskline[f]} ]]&&diskline[f]+=",  "
diskline[f]+="${sdisk[avail]}$(fmt_bytes "${diskinfo[avail]}")(${diskinfo[p_avail]}%)"
disklen[f]=$((disklen[f]-sdisk[lavail]))
fi
disklen[f]=$((disklen[f]+$(echo -n "${diskline[f]}"|wc -c)))
local diskmax=$((disklen[f]))
local i
for ((i=1; i<=diskinfo[count]; i++));do
local name type
[[ -z ${diskinfo[disk$i.capacity]} || -z ${diskinfo[disk$i.name]} || -z ${diskinfo[disk$i.type]} || -z ${diskinfo[disk$i.model]} ]]&&continue
name="${diskinfo[disk$i.name]}"
type="${diskinfo[disk$i.type]}"
diskline[$i]="[$name"
[[ $type != "NVMe" ]]&&diskline[$i]+=" $type"
diskline[$i]+="]"
[[ -n ${diskinfo[disk$i.model]} ]]&&diskline[$i]+="${diskinfo[disk$i.model]}"
[[ -n ${diskinfo[disk$i.serial]} ]]&&diskline[$i]+=" SN:${diskinfo[disk$i.serial]}"
[[ -n ${diskinfo[disk$i.capacity]} ]]&&diskline[$i]+=" ${diskinfo[disk$i.capacity]}"
[[ -n ${diskinfo[disk$i.rpm]} ]]&&diskline[$i]+=" ${diskinfo[disk$i.rpm]}"
[[ -n ${diskinfo[disk$i.form]} ]]&&diskline[$i]+=" ${diskinfo[disk$i.form]}"
disklen[$i]=$(($(echo -n "${diskline[$i]}"|wc -c)+4))
((disklen[$i]>diskmax))&&diskmax=$((disklen[$i]))
smartline[$i]=""
smartlen[$i]=0
if [[ -n ${diskinfo[disk$i.pcycle]} ]];then
local pc_color="$Font_Green"
((pc>=10000))&&pc_color="$Font_Yellow"
smartline[$i]+="$pc_color${sdisk[po]}${diskinfo[disk$i.pcycle]}${sdisk[times]}$Font_Black "
smartlen[$i]=$((smartlen[$i]-sdisk[lpo]-10))
fi
if [[ -n ${diskinfo[disk$i.poh]} ]];then
local poh="${diskinfo[disk$i.poh]}"
if ((poh<=30000));then
smartline[$i]+="$Font_Green${poh}h$Font_Black "
else
smartline[$i]+="$Font_Yellow${poh}h$Font_Black "
fi
smartlen[$i]=$((smartlen[$i]-10))
fi
if [[ -n ${diskinfo[disk$i.temp]} ]];then
local t="${diskinfo[disk$i.temp]}"
local tc="$Font_Green"
case "${diskinfo[disk$i.type]}" in
HDD)((t>50))&&tc="$Font_Red"
((t>=40&&t<=50))&&tc="$Font_Yellow"
;;
SSD)((t>65))&&tc="$Font_Red"
((t>=50&&t<=65))&&tc="$Font_Yellow"
;;
NVMe)((t>75))&&tc="$Font_Red"
((t>=60&&t<=75))&&tc="$Font_Yellow"
esac
smartline[$i]+="$tc$t℃ $Font_Black "
smartlen[$i]=$((smartlen[$i]-12))
fi
if [[ ${diskinfo[disk$i.type]} == "HDD" ]];then
for id in 1 5 187 196 197 198;do
v="${diskinfo[disk$i.smart_$id]}"
[[ -z $v ]]&&continue
if [[ $v == "0" ]];then
smartline[$i]+="$Font_Green✔$(printf "%02X" "$id")$Font_Black "
else
smartline[$i]+="$Font_Red✘$(printf "%02X" "$id")$Font_Black "
fi
smartlen[$i]=$((smartlen[$i]-12))
done
elif [[ ${diskinfo[disk$i.type]} == "SSD" ]];then
if [[ -n ${diskinfo[disk$i.read_raw]} && -n ${diskinfo[disk$i.write_raw]} ]];then
local r_disp="$(fmt_rw "${diskinfo[disk$i.read_raw]}")"
local w_disp="$(fmt_rw "${diskinfo[disk$i.write_raw]}")"
local cap_b="$(cap_to_bytes "${diskinfo[disk$i.capacity]}")"
local w_b="${diskinfo[disk$i.write_raw]}"
local wc="$Font_Green"
if [[ -n $cap_b && -n $w_b ]];then
((w_b>cap_b*1000))&&wc="$Font_Yellow"
fi
smartline[$i]+="${wc}R/W:$r_disp/$w_disp$Font_Black "
smartlen[$i]=$((smartlen[$i]-10))
fi
if [[ -n ${diskinfo[disk$i.life]} ]];then
local life="${diskinfo[disk$i.life]}"
local lc="$Font_Green"
((life<30))&&lc="$Font_Red"
((life>=30&&life<80))&&lc="$Font_Yellow"
smartline[$i]+="$lc${sdisk[lf]}$life%$Font_Black "
smartlen[$i]=$((smartlen[$i]-sdisk[llf]-10))
fi
elif [[ ${diskinfo[disk$i.type]} == "NVMe" ]];then
local nvme_parts=()
if [[ -n ${diskinfo[disk$i.read_tb]} && -n ${diskinfo[disk$i.write_tb]} ]];then
local cap_b="$(cap_to_bytes "${diskinfo[disk$i.capacity]}")"
local w_b="$(rw_to_bytes "${diskinfo[disk$i.write_tb]}")"
local wc="$Font_Green"
if [[ -n $cap_b && -n $w_b ]];then
((w_b>cap_b*1000))&&wc="$Font_Yellow"
fi
nvme_parts+=("${wc}R/W:${diskinfo[disk$i.read_tb]}/${diskinfo[disk$i.write_tb]}$Font_Black")
smartlen[$i]=$((smartlen[$i]-10))
fi
if [[ -n ${diskinfo[disk$i.life]} ]];then
local life="${diskinfo[disk$i.life]:-0}"
local lc="$Font_Green"
if ((life<30));then
lc="$Font_Red"
elif ((life<80));then
lc="$Font_Yellow"
fi
nvme_parts+=("$lc${sdisk[lf]}$life%$Font_Black")
smartlen[$i]=$((smartlen[$i]-sdisk[llf]-10))
fi
if [[ -n ${diskinfo[disk$i.spare]} ]];then
local spare="${diskinfo[disk$i.spare]:-0}"
local sc="$Font_Green"
if ((spare<90));then
sc="$Font_Red"
elif ((spare<100));then
sc="$Font_Yellow"
fi
nvme_parts+=("$sc${sdisk[sp]}$spare%$Font_Black")
smartlen[$i]=$((smartlen[$i]-sdisk[lsp]-10))
fi
if ((${#nvme_parts[@]}));then
smartline[$i]+="${nvme_parts[*]} "
fi
fi
case "${diskinfo[disk$i.smart_pass]}" in
PASSED)smartline[$i]+="$Back_Green$Font_White PASSED $Font_Suffix$Back_White"
smartlen[$i]=$((smartlen[$i]-19))
;;
FAILED)smartline[$i]+="$Back_Red$Font_White FAILED $Font_Suffix$Back_White"
smartlen[$i]=$((smartlen[$i]-19))
esac
smartline[$i]="${smartline[$i]%, }"
smartlen[$i]=$((smartlen[$i]+$(echo -en "${smartline[$i]}"|wc -c)+8))
((smartlen[$i]>diskmax))&&diskmax=$((smartlen[$i]))
done
local diskdiff=$(printf '%*s' "$((diskmax-disklen[f]))")
echo -ne "\r$Font_Cyan${sdisk[disk]}$Font_Suffix$Back_White$Font_Black$Font_B$Font_U${diskline[f]}$Font_Suffix$Back_White$diskdiff$Font_Suffix\n"
for ((i=1; i<=diskinfo[count]; i++));do
[[ -z ${diskinfo[disk$i.capacity]} || -z ${diskinfo[disk$i.name]} || -z ${diskinfo[disk$i.type]} || -z ${diskinfo[disk$i.model]} ]]&&continue
if ((i==diskinfo[count]));then
diskline[$i]="          $Font_B$Back_White$Font_Black ╚═ ${diskline[$i]}"
else
diskline[$i]="          $Font_B$Back_White$Font_Black ╠═ ${diskline[$i]}"
fi
diskdiff=$(printf '%*s' "$((diskmax-disklen[$i]))")
echo -ne "\r${diskline[$i]}$diskdiff$Font_Suffix\n"
diskdiff=$(printf '%*s' "$((diskmax-smartlen[$i]))")
if [[ -n ${smartline[$i]} ]];then
if ((i==diskinfo[count]));then
echo -ne "\r          $Font_B$Back_White$Font_Black     ╚═ ${smartline[$i]}$diskdiff$Font_Suffix\n"
else
echo -ne "\r          $Font_B$Back_White$Font_Black ║   ╚═ ${smartline[$i]}$diskdiff$Font_Suffix\n"
fi
fi
done
if [[ ${diskinfo[raid_count]:-0} -gt 0 ]];then
local r
for ((r=1; r<=diskinfo[raid_count]; r++));do
local rname rlevel rdevs rmount
rname="${diskinfo[raid$r.name]}"
rlevel="${diskinfo[raid$r.level]}"
rdevs="${diskinfo[raid$r.devs]}"
rmount="${diskinfo[raid$r.mount]}"
[[ -n $rmount ]]&&rmount="($rmount)"||rmount=""
if ((r==1));then
echo -ne "\r${Font_Cyan}RAID:     $Font_Green$rname -> $rlevel$rmount $rdevs$Font_Suffix\n"
else
echo -ne "\r          $Font_Green$rname -> $rlevel$rmount $rdevs$Font_Suffix\n"
fi
done
fi
if [[ $mode_disk -eq 0 && mode_verbose -eq 0 ]];then
if [[ -n ${diskinfo[fio.randread.4K_q1.bw]} ]];then
if [[ -n ${diskinfo[testdir]} ]];then
local extra=""
if [[ -n ${diskinfo[testdev]} ]];then
extra="${diskinfo[testdev]}(${diskinfo[testdir]})"
if [[ -n ${diskinfo[testdev_type]} ]];then
extra+=" -> ${diskinfo[testdev_type]}"
[[ -n ${diskinfo[testdev_mount]} ]]&&extra+="(${diskinfo[testdev_mount]})"
[[ -n ${diskinfo[testdev_members]} ]]&&extra+=" ${diskinfo[testdev_members]}"
fi
fi
[[ -z $extra ]]&&extra="${diskinfo[testdir]}"
echo -ne "\r$Font_Cyan${sdisk[dir]}$Font_Green$extra$Font_Suffix\n"
fi
echo -ne "\r$Font_Cyan${sdisk[fio]}RND4K/Q1    IOPS||RND4K/Q32   IOPS||SEQ1M/Q1    IOPS||SEQ1M/Q8    IOPS$Font_Suffix\n"
local c1 c2 c3 c4
c1="$(fmt_fio_cell "${diskinfo[fio.randread.4K_q1.bw]}" "${diskinfo[fio.randread.4K_q1.iops]}" rnd4K_q1)"
c2="$(fmt_fio_cell "${diskinfo[fio.randread.4K_q32.bw]}" "${diskinfo[fio.randread.4K_q32.iops]}" rnd4K_q32)"
c3="$(fmt_fio_cell "${diskinfo[fio.read.1M_q1.bw]}" "${diskinfo[fio.read.1M_q1.iops]}" seq1M_q1)"
c4="$(fmt_fio_cell "${diskinfo[fio.read.1M_q8.bw]}" "${diskinfo[fio.read.1M_q8.iops]}" seq1M_q8)"
echo -ne "\r$Font_Cyan${sdisk[read]}$Font_Suffix$c1$Font_Cyan||$Font_Suffix$c2$Font_Cyan||$Font_Suffix$c3$Font_Cyan||$Font_Suffix$c4\n"
c1="$(fmt_fio_cell "${diskinfo[fio.randwrite.4K_q1.bw]}" "${diskinfo[fio.randwrite.4K_q1.iops]}" rnd4K_q1)"
c2="$(fmt_fio_cell "${diskinfo[fio.randwrite.4K_q32.bw]}" "${diskinfo[fio.randwrite.4K_q32.iops]}" rnd4K_q32)"
c3="$(fmt_fio_cell "${diskinfo[fio.write.1M_q1.bw]}" "${diskinfo[fio.write.1M_q1.iops]}" seq1M_q1)"
c4="$(fmt_fio_cell "${diskinfo[fio.write.1M_q8.bw]}" "${diskinfo[fio.write.1M_q8.iops]}" seq1M_q8)"
echo -ne "\r$Font_Cyan${sdisk[write]}$Font_Suffix$c1$Font_Cyan||$Font_Suffix$c2$Font_Cyan||$Font_Suffix$c3$Font_Cyan||$Font_Suffix$c4\n"
fi
else
if [[ -n ${diskinfo[fio.randread.4K_q1.bw]} ]];then
if [[ -n ${diskinfo[testdir]} ]];then
local extra=""
if [[ -n ${diskinfo[testdev]} ]];then
extra="${diskinfo[testdev]}(${diskinfo[testdir]})"
if [[ -n ${diskinfo[testdev_type]} ]];then
extra+=" -> ${diskinfo[testdev_type]}"
[[ -n ${diskinfo[testdev_mount]} ]]&&extra+="(${diskinfo[testdev_mount]})"
[[ -n ${diskinfo[testdev_members]} ]]&&extra+=" ${diskinfo[testdev_members]}"
fi
fi
[[ -z $extra ]]&&extra="${diskinfo[testdir]}"
echo -ne "\r$Font_Cyan${sdisk[dir]}$Font_Green$extra$Font_Suffix\n"
fi
echo -ne "\r$Font_Cyan${sdisk[crystal]}RND4K/Q1    IOPS||RND4K/Q32   IOPS||SEQ1M/Q1    IOPS||SEQ1M/Q8    IOPS$Font_Suffix\n"
local c1 c2 c3 c4
c1="$(fmt_fio_cell "${diskinfo[fio.randread.4K_q1.bw]}" "${diskinfo[fio.randread.4K_q1.iops]}" rnd4K_q1)"
c2="$(fmt_fio_cell "${diskinfo[fio.randread.4K_q32.bw]}" "${diskinfo[fio.randread.4K_q32.iops]}" rnd4K_q32)"
c3="$(fmt_fio_cell "${diskinfo[fio.read.1M_q1.bw]}" "${diskinfo[fio.read.1M_q1.iops]}" seq1M_q1)"
c4="$(fmt_fio_cell "${diskinfo[fio.read.1M_q8.bw]}" "${diskinfo[fio.read.1M_q8.iops]}" seq1M_q8)"
echo -ne "\r$Font_Cyan${sdisk[read]}$Font_Suffix$c1$Font_Cyan||$Font_Suffix$c2$Font_Cyan||$Font_Suffix$c3$Font_Cyan||$Font_Suffix$c4\n"
c1="$(fmt_fio_cell "${diskinfo[fio.randwrite.4K_q1.bw]}" "${diskinfo[fio.randwrite.4K_q1.iops]}" rnd4K_q1)"
c2="$(fmt_fio_cell "${diskinfo[fio.randwrite.4K_q32.bw]}" "${diskinfo[fio.randwrite.4K_q32.iops]}" rnd4K_q32)"
c3="$(fmt_fio_cell "${diskinfo[fio.write.1M_q1.bw]}" "${diskinfo[fio.write.1M_q1.iops]}" seq1M_q1)"
c4="$(fmt_fio_cell "${diskinfo[fio.write.1M_q8.bw]}" "${diskinfo[fio.write.1M_q8.iops]}" seq1M_q8)"
echo -ne "\r$Font_Cyan${sdisk[write]}$Font_Suffix$c1$Font_Cyan||$Font_Suffix$c2$Font_Cyan||$Font_Suffix$c3$Font_Cyan||$Font_Suffix$c4\n"
fi
if [[ -n ${diskinfo[fio.read.512B_q4.bw]} ]];then
echo -ne "\r$Font_Cyan${sdisk[atto]}READ                          IOPS||WRITE                         IOPS$Font_Suffix\n"
local r w
for bs in \
512B 1K 2K 4K 8K 16K 32K 64K \
128K 256K 512K 1M 2M 4M 8M 16M 32M 64M;do
r="$(fmt_fio_cell_mode \
"${diskinfo[fio.read.${bs}_q4.bw]}" \
"${diskinfo[fio.read.${bs}_q4.iops]}" \
"${bs}_q4")"
w="$(fmt_fio_cell_mode \
"${diskinfo[fio.write.${bs}_q4.bw]}" \
"${diskinfo[fio.write.${bs}_q4.iops]}" \
"${bs}_q4")"
echo -ne "\r$Font_Cyan$(printf "%-10s" "$bs")$Font_Suffix$r$Font_Cyan||$Font_Suffix$w\n"
done
fi
fi
}
show_mark(){
[[ ${markinfo[total]:-0} == 0 ]]&&return
_center9(){
local s="$1"
local w=9
local len=${#s}
[[ -n $2 ]]&&len=$2
((len>=w))&&{
echo -n "$s"
return
}
local pad=$(((w-len)/2))
local rest=$((w-len-pad))
echo -n "$(printf "%*s" "$pad" "")$s$(printf "%*s" "$rest" "")"
}
local BOX="$Back_Cyan$Font_White$Font_B"
local OP="$Font_Cyan$Font_B"
local RST="$Font_Suffix"
echo -ne "\r${smark[title]}\n"
echo -ne "\r$Font_Cyan${smark[item]}"
echo -ne "$(_center9 "${smark[total]}" "${smark[ltotal]}")"
echo -ne "     "
echo -ne "$(_center9 "CPU")"
echo -ne "     "
echo -ne "$(_center9 "GPU")"
echo -ne "     "
echo -ne "$(_center9 "${smark[mem]}" "${smark[lmem]}")"
echo -ne "     "
echo -ne "$(_center9 "${smark[disk]}" "${smark[ldisk]}")$RST\n"
echo -ne "\r$Font_Cyan${smark[mark]}$RST"
echo -ne "$BOX$(_center9 "${markinfo[total]:-N/A}")$RST"
echo -ne "  $OP=$RST  "
echo -ne "$BOX$(_center9 "${markinfo[cpu]:-N/A}")$RST"
echo -ne "  $OP+$RST  "
echo -ne "$BOX$(_center9 "${markinfo[gpu]:-N/A}")$RST"
echo -ne "  $OP+$RST  "
echo -ne "$BOX$(_center9 "${markinfo[mem]:-N/A}")$RST"
echo -ne "  $OP+$RST  "
echo -ne "$BOX$(_center9 "${markinfo[disk]:-N/A}")$RST\n"
_fmt_pct(){
local v="${1:-N/A}"
[[ $v != "N/A" ]]&&v="$v%"
echo "$v"
}
echo -ne "\r$Font_Cyan${smark[pct]}$RST"
echo -ne "$Font_Green$Font_B$(_center9 "$(_fmt_pct "${markinfo[total_pct]}")")"
echo -ne "     "
echo -ne "$(_center9 "$(_fmt_pct "${markinfo[cpu_pct]}")")"
echo -ne "     "
echo -ne "$(_center9 "$(_fmt_pct "${markinfo[gpu_pct]}")")"
echo -ne "     "
echo -ne "$(_center9 "$(_fmt_pct "${markinfo[mem_pct]}")")"
echo -ne "     "
echo -ne "$(_center9 "$(_fmt_pct "${markinfo[disk_pct]}")")$RST\n"
}
show_tail(){
echo -ne "\r$(printf '%80s'|tr ' ' '=')\n"
echo -ne "\r$Font_I${stail[stoday]}${stail[today]}${stail[stotal]}${stail[total]}${stail[thanks]} $Font_Suffix\n"
echo -e ""
}
get_opts(){
local args=()
while [[ $# -gt 0 ]];do
case "$1" in
-[dloS])args+=("$1")
if [[ $# -gt 1 && $2 != -* ]];then
args+=("$2")
shift
fi
shift
;;
-[dloS]*)ERRORcode=1
shift
;;
-[fhjnpyDEMV]*)local opt="$1"
shift
for ((i=1; i<${#opt}; i++));do
args+=("-${opt:i:1}")
done
;;
--*|-*[!-]*)args+=("$1")
shift
;;
-*)ERRORcode=1
shift
;;
*)shift
esac
done
set -- "${args[@]}"
while [[ $# -gt 0 ]];do
case "$1" in
-d)shift
[[ $1 == -* ]]&&ERRORcode=1&&break
workdir="${1%/}"
[[ ! -d $workdir ]]&&{
ERRORcode=12
break
}
[[ ! -r $workdir || ! -w $workdir ]]&&{
ERRORcode=13
break
}
shift
;;
-f)fullinfo=1
shift
;;
-h)show_help
shift
;;
-j)mode_json=1
shift
;;
-l)shift
[[ $1 == -* ]]&&ERRORcode=1&&break
YY=$(echo "$1"|tr '[:upper:]' '[:lower:]')
shift
;;
-n)mode_no=1
shift
;;
-o)shift
[[ $1 == -* ]]&&{
ERRORcode=1
break
}
mode_output=1
outputfile="$1"
[[ -z $outputfile ]]&&{
ERRORcode=1
break
}
[[ -e $outputfile ]]&&{
ERRORcode=10
break
}
touch "$outputfile" 2>/dev/null||{
ERRORcode=11
break
}
shift
;;
-p)mode_privacy=1
shift
;;
-y)mode_yes=1
shift
;;
-D)mode_disk=1
shift
;;
-E)YY="en"
shift
;;
-F)mode_fast=1
mode_fast_dep=""
shift
;;
-M)mode_menu=1
shift
;;
-S)shift
if [[ $# -gt 0 ]];then
mode_skip="$1"
shift
else
ERRORcode=1
fi
;;
-V)mode_verbose=1
shift
;;
-*)ERRORcode=1
shift
;;
*)shift
esac
done
if [[ $mode_menu -eq 1 ]];then
if [[ $YY == "cn" ]];then
eval "bash <(curl -sL https://Check.Place) -H"
else
eval "bash <(curl -sL https://Check.Place) -EH"
fi
exit 0
fi
[[ $mode_disk -eq 1 ]]&&mode_skip+="2345"
[[ $mode_disk -eq 1 && $mode_skip == *"6"* ]]&&ERRORcode=9
[[ $mode_disk -eq 1 && $mode_fast -eq 1 ]]&&ERRORcode=9
[[ $mode_skip == *"1"* && $mode_skip == *"2"* && $mode_skip == *"3"* && $mode_skip == *"4"* && $mode_skip == *"5"* && $mode_skip == *"6"* ]]&&ERRORcode=9
}
show_help(){
echo -ne "\r$shelp\n"
exit 0
}
show_ad(){
RANDOM=$(date +%s)
local -a ads=()
local i=1
while :;do
local content
content=$(curl -fsL --max-time 5 "${rawgithub}main/ref/ad$i.ans")||break
ads+=("$content")
((i++))
done
ADLines=0
local adCount=${#ads[@]}
[[ $adCount -eq 0 ]]&&return
local -a indices=()
for ((i=1; i<=adCount; i++));do indices+=("$i");done
for ((i=adCount-1; i>0; i--));do
local j=$((RANDOM%(i+1)))
local tmp=${indices[i]}
indices[i]=${indices[j]}
indices[j]=$tmp
done
local -a aad
aad[0]=$(curl -sL --max-time 5 "${rawgithub}main/ref/sponsor.ans")
for ((i=0; i<adCount; i++));do
aad[${indices[i]}]="${ads[i]}"
done
local rows cols
if ! read rows cols < <(stty size 2>/dev/null);then cols=0;fi
print_pair(){
local left="$1" right="$2"
local -a L R
mapfile -t L <<<"$left"
mapfile -t R <<<"$right"
local i
for ((i=0; i<12; i++));do
printf "%-72s$Font_Suffix     %-72s\n" "${L[i]}" "${R[i]}" 1>&2
done
ADLines=$((ADLines+12))
}
print_block(){
echo "$1" 1>&2
ADLines=$((ADLines+12))
}
if [[ $cols -ge 150 ]];then
if ((adCount==0));then
print_block "${aad[0]}"
elif ((adCount%2==1));then
print_pair "${aad[0]}" "${aad[1]}"
local k
for ((k=2; k<=adCount; k+=2));do
print_pair "${aad[$k]}" "${aad[$((k+1))]}"
done
else
print_block "${aad[0]}"
local k
for ((k=1; k<=adCount; k+=2));do
print_pair "${aad[$k]}" "${aad[$((k+1))]}"
done
fi
else
echo "${aad[0]}" 1>&2
for ((i=1; i<=adCount; i++));do
echo "${aad[$i]}" 1>&2
done
ADLines=$(((adCount+1)*12))
fi
}
save_json(){
_hwjson="$hwjson"
hwjson="$(jq \
--arg ip "${IP:-null}" \
--arg ip_hide "${IPhide:-null}" \
--arg cmd "${shead[bash]:-null}" \
--arg git "${shead[git]:-null}" \
--arg time "${shead[time_raw]:-null}" \
--arg ver "${script_version:-null}" \
--argjson fullinfo "${fullinfo:-0}" \
'
      .Head = {
            IP: (
              if $fullinfo == 1
              then $ip
              else $ip_hide
              end
            ),
            Command: $cmd,
            GitHub:  $git,
            Time:    $time,
            Version: $ver
      }
    ' <<<"$_hwjson")"
_hwjson="$hwjson"
hwjson="$(jq \
--arg os_name "${osinfo[os]:-}" \
--arg kernel "${osinfo[kernel]:-}" \
--arg arch "${osinfo[arch]:-}" \
--arg uptime "${osinfo[uptime]:-}" \
--arg virt_type "${osinfo[virt]:-}" \
--arg virt_kind "${osinfo[virt_kind]:-}" \
--arg load1 "${osinfo[load1]:-}" \
--arg load5 "${osinfo[load5]:-}" \
--arg load15 "${osinfo[load15]:-}" \
--arg users_online "${osinfo[user]:-}" \
--arg proc_total "${osinfo[proc]:-}" \
--arg svcr "${osinfo[svcr]:-}" \
--arg svct "${osinfo[svct]:-}" \
--arg lang "${osinfo[lang]:-}" \
--arg charset "${osinfo[charset]:-}" \
--arg tz_name "${osinfo[tz]:-}" \
--arg tz_abbr "${osinfo[tz_abbr]:-}" \
--arg tz_offset "${osinfo[tz_offset]:-}" \
'
    .OS = {
      name:          ($os_name        // ""),
      kernel:        ($kernel         // ""),
      architecture:  ($arch           // ""),
      uptime:        ($uptime         // ""),
      virtualization: {
        type: ($virt_type // ""),
        kind: ($virt_kind // "")
      },
      load_average: {
        load_1:  ($load1  // ""),
        load_5:  ($load5  // ""),
        load_15: ($load15 // "")
      },
      users: {
        online: ($users_online // "")
      },
      processes: {
        total: ($proc_total // "")
      },
      services: {
        running: ($svcr // ""),
        total:   ($svct // "")
      },
      locale: {
        language: ($lang    // ""),
        charset:  ($charset // "")
      },
      timezone: {
        name:   ($tz_name   // ""),
        abbr:   ($tz_abbr   // ""),
        offset: ($tz_offset // "")
      }
    }
    ' <<<"$_hwjson")"
_hwjson="$hwjson"
hwjson="$(jq \
--arg os "${mbinfo[os]:-}" \
--arg board_vendor "${mbinfo[board_vendor]:-}" \
--arg board_name "${mbinfo[board_name]:-}" \
--arg board_version "${mbinfo[board_version]:-}" \
--arg board_serial "${mbinfo[board_serial]:-}" \
--arg bios_vendor "${mbinfo[bios_vendor]:-}" \
--arg bios_version "${mbinfo[bios_version]:-}" \
--arg pci_root "${mbinfo[pci_root]:-}" \
--arg pch_device "${mbinfo[pch_device]:-}" \
--arg audio_raw "${mbinfo[audio_devices]:-}" \
--arg net_raw "${mbinfo[net_devices]:-}" \
'
    # ---------- helper: newline → array ----------
    def split_lines($s):
      if ($s | length) > 0 then
        ($s | split("\n") | map(select(length > 0)))
      else
        []
      end;
    .Motherboard = {
      board: {
        vendor:  ($board_vendor  // ""),
        name:    ($board_name    // ""),
        version: ($board_version // ""),
        serial:  ($board_serial  // "")
      },
      bios: {
        vendor:  ($bios_vendor  // ""),
        version: ($bios_version // "")
      },
      chipset: {
        pci_root: ($pci_root   // ""),
        pch:      ($pch_device // "")
      },
      devices: {
        audio:   split_lines($audio_raw),
        network: split_lines($net_raw)
      },
      platform: {
        os: ($os // "")
      }
    }
    ' <<<"$_hwjson")"
cpu_packages_json="[]"
for ((i=0; i<cpuinfo[temp_count]; i++));do
min="${cpuinfo[temp${i}_min]:-}"
max="${cpuinfo[temp${i}_max]:-}"
if [[ $min =~ ^[0-9]+$ || $max =~ ^[0-9]+$ ]];then
cpu_packages_json="$(jq -n \
--argjson arr "$cpu_packages_json" \
--arg id "$i" \
--arg min "$min" \
--arg max "$max" \
'
              $arr + [{
                id: ($id | tonumber),
                min: ($min | tonumber?),
                max: ($max | tonumber?)
              }]
              ')"
fi
done
gb_detail_json='{
      "single": { "groups": {}, "items": {} },
      "multi":  { "groups": {}, "items": {} }
    }'
for k in "${!cpuinfo[@]}";do
[[ $k != gb.* ]]&&continue
IFS='.' read -r _ mode kind name sub <<<"$k"
case "$mode" in
s)mode_json="single";;
m)mode_json="multi";;
*)continue
esac
case "$kind" in
g)gb_detail_json="$(jq \
--arg mode "$mode_json" \
--arg name "$name" \
--arg v "${cpuinfo[$k]}" \
'
                    .[$mode].groups[$name] = ($v | tonumber?)
                    ' <<<"$gb_detail_json")"
;;
i)if
[[ -z $sub ]]
then
gb_detail_json="$(jq \
--arg mode "$mode_json" \
--arg name "$name" \
--arg v "${cpuinfo[$k]}" \
'
                        .[$mode].items[$name].score = ($v | tonumber?)
                        ' <<<"$gb_detail_json")"
elif [[ $sub == "desc" ]];then
gb_detail_json="$(jq \
--arg mode "$mode_json" \
--arg name "$name" \
--arg v "${cpuinfo[$k]}" \
'
                        .[$mode].items[$name].desc = $v
                        ' <<<"$gb_detail_json")"
elif [[ $sub == "pct" ]];then
gb_detail_json="$(jq \
--arg mode "$mode_json" \
--arg name "$name" \
--arg v "${cpuinfo[$k]}" \
'
                        .[$mode].items[$name].pct = ($v | tonumber?)
                        ' <<<"$gb_detail_json")"
fi
esac
done
_hwjson="$hwjson"
hwjson="$(jq \
--argjson packages "$cpu_packages_json" \
--arg arch "${cpuinfo[arch]:-}" \
--arg model "${cpuinfo[name]:-}" \
--arg op_mode "${cpuinfo[op_mode]:-}" \
--arg family "${cpuinfo[family]:-}" \
--arg stepping "${cpuinfo[stepping]:-}" \
--arg sockets "${cpuinfo[sockets]:-}" \
--arg cores_ps "${cpuinfo[cores_per_socket]:-}" \
--arg tpc "${cpuinfo[threads_per_core]:-}" \
--arg cores "${cpuinfo[cores]:-}" \
--arg threads "${cpuinfo[threads]:-}" \
--arg cg_threads "${cpuinfo[cg_threads]:-}" \
--arg mhz_cur "${cpuinfo[mhz]:-}" \
--arg mhz_min "${cpuinfo[min_mhz]:-}" \
--arg mhz_max "${cpuinfo[max_mhz]:-}" \
--arg usage "${cpuinfo[usage]:-}" \
--arg l1d "${cpuinfo[L1d]:-}" \
--arg l1i "${cpuinfo[L1i]:-}" \
--arg l2 "${cpuinfo[L2]:-}" \
--arg l3 "${cpuinfo[L3]:-}" \
--arg cache_total "${cpuinfo[cache_total]:-}" \
--arg cache_fb "${cpuinfo[cache_fallback]:-}" \
--arg vt "${cpuinfo[vt]:-}" \
--arg aes "${cpuinfo[aes]:-}" \
--arg avx2 "${cpuinfo[avx2]:-}" \
--arg bmi "${cpuinfo[bmi]:-}" \
--arg ept "${cpuinfo[ept]:-}" \
--arg neon "${cpuinfo[neon]:-}" \
--arg sve "${cpuinfo[sve]:-}" \
--arg atomics "${cpuinfo[atomics]:-}" \
--arg sb_single "${cpuinfo[sysbench_single]:-}" \
--arg sb_multi "${cpuinfo[sysbench_multi]:-}" \
--arg gb_url "${cpuinfo[url]:-}" \
--arg gb_single "${cpuinfo[geekbench_single]:-}" \
--arg gb_multi "${cpuinfo[geekbench_multi]:-}" \
--argjson gb_detail "$gb_detail_json" \
--arg temp_cnt "${cpuinfo[temp_count]:-}" \
--arg temp_min "${cpuinfo[temp_min]:-}" \
--arg temp_max "${cpuinfo[temp_max]:-}" \
--arg flags_raw "${cpuinfo[flags]:-}" \
'
    ########################################
    # helpers (NULL SAFE)
    ########################################
    def num($v):
      if ($v // "" | tostring | test("^[0-9]+(\\.[0-9]+)?$"))
      then ($v | tonumber)
      else null
      end;
    def bool($v):
      ($v == "1");
    def split_flags($s):
      if ($s | length) > 0 then
        ($s | split(" ") | map(select(length > 0)))
      else
        []
      end;
    ########################################
    # CPU
    ########################################
    .CPU = {
      architecture: $arch,
      model:        $model,
      op_mode:      $op_mode,
      family:       $family,
      stepping:     $stepping,
      topology: {
        sockets:           num($sockets),
        cores_per_socket:  num($cores_ps),
        threads_per_core:  num($tpc),
        cores:             num($cores),
        threads:           num($threads),
        cgroup_threads:    num($cg_threads)
      },
      frequency_mhz: {
        current: num($mhz_cur),
        min:     num($mhz_min),
        max:     num($mhz_max)
      },
      usage_percent: num($usage),
      cache: {
        l1d:            $l1d,
        l1i:            $l1i,
        l2:             $l2,
        l3:             $l3,
        total_fallback: $cache_total,
        fallback_used:  ($cache_fb == "1")
      },
      features: {
        virtualization: bool($vt),
        aes:            bool($aes),
        avx2:           bool($avx2),
        bmi:            bool($bmi),
        ept:            bool($ept),
        neon:           bool($neon),
        sve:            bool($sve),
        atomics:        bool($atomics)
      },
      benchmarks: {
        sysbench: {
          single: num($sb_single),
          multi:  num($sb_multi)
        },
      geekbench5: {
        url:    $gb_url,
        single: num($gb_single),
        multi:  num($gb_multi),
        detail: $gb_detail
      }
      },
      temperature: {
        packages_detected: num($temp_cnt),
        min:               num($temp_min),
        max:               num($temp_max),
        packages:          $packages
      },
      flags: split_flags($flags_raw)
    }
    ' <<<"$_hwjson")"
gpu_devices_json="[]"
gpu_dgpu_ids=()
for ((i=0; i<gpuinfo[count]; i++));do
type="integrated"
if [[ ${gpuinfo[item$i.type]} == "1" ]];then
type="discrete"
gpu_dgpu_ids+=("$i")
fi
gpu_devices_json="$(jq -n \
--argjson arr "$gpu_devices_json" \
--arg id "$i" \
--arg type "$type" \
--arg vendor "${gpuinfo[item$i.vendor]:-}" \
--arg name "${gpuinfo[item$i.name]:-}" \
--arg vram "${gpuinfo[item$i.vram_gb]:-}" \
--arg freq "${gpuinfo[item$i.freq_max]:-}" \
'
          $arr + [{
            id: ($id|tonumber),
            type: $type,
            vendor: $vendor,
            name: $name,
            vram_gb: (if ($vram|test("^[0-9]+$")) then ($vram|tonumber) else null end),
            max_frequency_mhz: (if ($freq|test("^[0-9]+$")) then ($freq|tonumber) else null end)
          }]
          ')"
done
gpu_temps_json="[]"
for ((i=0; i<gpuinfo[temp_count]; i++));do
min="${gpuinfo[temp${i}_min]:-}"
max="${gpuinfo[temp${i}_max]:-}"
[[ $min =~ ^[0-9]+$ || $max =~ ^[0-9]+$ ]]||continue
gpu_id="${gpu_dgpu_ids[$i]}"
[[ -n $gpu_id ]]||continue
gpu_temps_json="$(jq -n \
--argjson arr "$gpu_temps_json" \
--arg id "$gpu_id" \
--arg min "$min" \
--arg max "$max" \
'
          $arr + [{
            id: ($id|tonumber),
            min: ($min|tonumber?),
            max: ($max|tonumber?)
          }]
          ')"
done
gpu_gb_detail_json="{}"
for k in "${!gpuinfo[@]}";do
[[ $k != gb.* ]]&&continue
rest="${k#gb.}"
name="${rest%%.*}"
sub="${rest#*.}"
[[ $sub == "$rest" ]]&&sub="score"
case "$sub" in
score)gpu_gb_detail_json="$(jq --arg name "$name" \
--arg v "${gpuinfo[$k]}" \
'
                     .[$name].score = ($v | tonumber?)
                     ' <<<"$gpu_gb_detail_json")"
;;
desc)gpu_gb_detail_json="$(jq --arg name "$name" \
--arg v "${gpuinfo[$k]}" \
'
                     .[$name].desc = $v
                     ' <<<"$gpu_gb_detail_json")"
;;
pct)gpu_gb_detail_json="$(jq --arg name "$name" \
--arg v "${gpuinfo[$k]}" \
'
                     .[$name].pct = ($v | tonumber?)
                     ' <<<"$gpu_gb_detail_json")"
esac
done
_hwjson="$hwjson"
hwjson="$(jq \
--argjson devices "$gpu_devices_json" \
--argjson temps "$gpu_temps_json" \
--arg count "${gpuinfo[count]:-0}" \
--arg has_dgpu "${gpuinfo[has_dgpu]:-0}" \
--arg driver "${gpuinfo[driver]:-0}" \
--arg opencl "${gpuinfo[opencl]:-0}" \
--arg cuda "${gpuinfo[cuda]:-0}" \
--arg gb_url "${gpuinfo[url]:-}" \
--arg gb_score "${gpuinfo[geekbench]:-}" \
--argjson gb_detail "$gpu_gb_detail_json" \
--arg gb_api "${gpuinfo[gb_type]:-}" \
--arg temp_min "${gpuinfo[temp_min]:-}" \
--arg temp_max "${gpuinfo[temp_max]:-}" \
'
    def num($v):
      if ($v // "" | tostring | test("^[0-9]+$")) then $v|tonumber else null end;
    def bool($v): ($v == "1");
    .GPU = {
      summary: {
        count:         num($count),
        has_dgpu:      bool($has_dgpu),
        driver_loaded: bool($driver),
        opencl:        bool($opencl),
        cuda:          bool($cuda)
      },
      devices: $devices,
      benchmarks: {
        geekbench5: {
          url:    $gb_url,
          score:  num($gb_score),
          api:    $gb_api,
          detail: $gb_detail
        }
      },
      temperature: {
        devices_detected: ($temps | length),
        min: num($temp_min),
        max: num($temp_max),
        devices: $temps
      }
    }
    ' <<<"$_hwjson")"
mem_devices_json="[]"
for ((i=0; i<${meminfo[count]:-0}; i++));do
mem_devices_json="$(jq -n \
--argjson arr "$mem_devices_json" \
--arg id "$i" \
--arg slot "${meminfo[mem$i.slot]:-}" \
--arg size "${meminfo[mem$i.size]:-}" \
--arg type "${meminfo[mem$i.type]:-}" \
--arg speed "${meminfo[mem$i.speed]:-}" \
--arg vendor "${meminfo[mem$i.vendor]:-}" \
--arg serial "${meminfo[mem$i.serial]:-}" \
--arg part "${meminfo[mem$i.part]:-}" \
'
          $arr + [{
            id: ($id|tonumber),
            slot: $slot,
            size: $size,                # 原样字符串：如 "16GB"
            type: $type,
            speed_mhz: ($speed|tonumber?),
            vendor: $vendor,
            serial: $serial,
            part_number: $part
          }]
          ')"
done
_hwjson="$hwjson"
hwjson="$(jq \
--argjson devices "$mem_devices_json" \
--arg mem_channels "${meminfo[mem_channels]:-}" \
--arg mem_total "${meminfo[total]:-}" \
--arg mem_used "${meminfo[used]:-}" \
--arg mem_avail "${meminfo[avail]:-}" \
--arg mem_used_pct "${meminfo[mem_used_pct]:-}" \
--arg mem_avail_pct "${meminfo[mem_avail_pct]:-}" \
--arg swap_total "${meminfo[swap_total]:-}" \
--arg swap_used "${meminfo[swap_used]:-}" \
--arg swap_avail "${meminfo[swap_avail]:-}" \
--arg swap_used_pct "${meminfo[swap_used_pct]:-}" \
--arg swap_avail_pct "${meminfo[swap_avail_pct]:-}" \
--arg balloon "${meminfo[balloon]:-}" \
--arg ksm "${meminfo[ksm]:-}" \
--arg neighbor "${meminfo[neighbor]:-}" \
--arg mem_read "${meminfo[read]:-}" \
--arg mem_write "${meminfo[write]:-}" \
--arg mem_lat "${meminfo[lat]:-}" \
'
    ########################################
    # helpers
    ########################################
    def num($v):
      if ($v // "" | tostring | test("^[0-9]+(\\.[0-9]+)?$"))
      then ($v | tonumber)
      else null
      end;
    def bool($v):
      ($v == "1");
    ########################################
    # Memory
    ########################################
    .Memory = {
      channels:        num($mem_channels),
      summary: {
        total:         $mem_total,
        used:          $mem_used,
        available:     $mem_avail,
        used_percent:  num($mem_used_pct),
        avail_percent: num($mem_avail_pct)
      },
      swap: {
        total:         $swap_total,
        used:          $swap_used,
        available:     $swap_avail,
        used_percent:  num($swap_used_pct),
        avail_percent: num($swap_avail_pct)
      },
      devices: $devices,
      virtualization: {
        balloon:  bool($balloon),
        ksm:      bool($ksm),
        neighbor: num($neighbor)
      },
      benchmarks: {
        read_MBps:  num($mem_read),
        write_MBps: num($mem_write),
        latency_ns: num($mem_lat)
      }
    }
    ' <<<"$_hwjson")"
disk_devices_json="[]"
for ((i=1; i<=${diskinfo[count]:-0}; i++));do
[[ -z ${diskinfo[disk$i.capacity]} ]]&&continue
type="${diskinfo[disk$i.type]}"
name="${diskinfo[disk$i.name]}"
usage_json="{}"
if [[ $type == "HDD" ]];then
usage_json="$(jq -n \
--argjson arr "$usage_json" \
--arg pcycle "${diskinfo[disk$i.pcycle]:-}" \
--arg poh "${diskinfo[disk$i.poh]:-}" \
--arg t "${diskinfo[disk$i.temp]:-}" \
--arg smart "${diskinfo[disk$i.smart_pass]:-}" \
--arg s1 "${diskinfo[disk$i.smart_1]:-}" \
--arg s5 "${diskinfo[disk$i.smart_5]:-}" \
--arg s187 "${diskinfo[disk$i.smart_187]:-}" \
--arg s196 "${diskinfo[disk$i.smart_196]:-}" \
--arg s197 "${diskinfo[disk$i.smart_197]:-}" \
--arg s198 "${diskinfo[disk$i.smart_198]:-}" \
'
              def num($v):
                if ($v | type) == "string"
                   and ($v | test("^[+-]?(?:[0-9]+(?:\\.[0-9]*)?|\\.[0-9]+)(?:[eE][+-]?[0-9]+)?$"))
                then ($v | tonumber)
                else null
                end;
              $arr + {
                power_cycles: num($pcycle),
                power_hours:  num($poh),
                temperature:  num($t),
                smart_status: $smart,
                smart: {
                  "01": num($s1),
                  "05": num($s5),
                  "BB": num($s187),
                  "C4": num($s196),
                  "C5": num($s197),
                  "C6": num($s198)
                }
              }
              ')"
elif [[ $type == "SSD" ]];then
usage_json="$(jq -n \
--argjson arr "$usage_json" \
--arg pcycle "${diskinfo[disk$i.pcycle]:-}" \
--arg poh "${diskinfo[disk$i.poh]:-}" \
--arg t "${diskinfo[disk$i.temp]:-}" \
--arg smart "${diskinfo[disk$i.smart_pass]:-}" \
--arg r "${diskinfo[disk$i.read_raw]:-}" \
--arg w "${diskinfo[disk$i.write_raw]:-}" \
--arg life "${diskinfo[disk$i.life]:-}" \
'
              def num($v):
                if ($v | type) == "string"
                   and ($v | test("^[+-]?(?:[0-9]+(?:\\.[0-9]*)?|\\.[0-9]+)(?:[eE][+-]?[0-9]+)?$"))
                then ($v | tonumber)
                else null
                end;
              $arr + {
                power_cycles: num($pcycle),
                power_hours:  num($poh),
                temperature:  num($t),
                smart_status: $smart,
                read:         num($r),
                write:        num($w),
                life_percent: num($life)
              }
              ')"
elif [[ $type == "NVMe" ]];then
usage_json="$(jq -n \
--argjson arr "$usage_json" \
--arg pcycle "${diskinfo[disk$i.pcycle]:-}" \
--arg poh "${diskinfo[disk$i.poh]:-}" \
--arg t "${diskinfo[disk$i.temp]:-}" \
--arg smart "${diskinfo[disk$i.smart_pass]:-}" \
--arg r "${diskinfo[disk$i.read_raw]:-}" \
--arg w "${diskinfo[disk$i.write_raw]:-}" \
--arg life "${diskinfo[disk$i.life]:-}" \
--arg spare "${diskinfo[disk$i.spare]:-}" \
'
              def num($v):
                if ($v | type) == "string"
                   and ($v | test("^[+-]?(?:[0-9]+(?:\\.[0-9]*)?|\\.[0-9]+)(?:[eE][+-]?[0-9]+)?$"))
                then ($v | tonumber)
                else null
                end;
              $arr + {
                power_cycles:  num($pcycle),
                power_hours:   num($poh),
                temperature:   num($t),
                smart_status:  $smart,
                read:          num($r),
                write:         num($w),
                life_percent:  num($life),
                spare_percent: num($spare)
              }
              ')"
fi
disk_devices_json="$(jq -n \
--argjson arr "$disk_devices_json" \
--arg id "$i" \
--arg name "$name" \
--arg dev "${diskinfo[disk$i.dev]:-}" \
--arg type "$type" \
--arg model "${diskinfo[disk$i.model]:-}" \
--arg serial "${diskinfo[disk$i.serial]:-}" \
--arg firmware "${diskinfo[disk$i.firmware]:-}" \
--arg capacity "${diskinfo[disk$i.capacity]:-}" \
--arg rpm "${diskinfo[disk$i.rpm]:-}" \
--arg form "${diskinfo[disk$i.form]:-}" \
--argjson usage "$usage_json" \
'
          $arr + [{
            id: ($id|tonumber),
            name: $name,
            device: $dev,
            type: $type,
            model: $model,
            serial: $serial,
            firmware: $firmware,
            capacity: $capacity,
            rotation_rpm: $rpm,
            form_factor: $form,
            health: $usage
          }]
          ')"
done
raid_devices_json="[]"
for ((i=1; i<=${diskinfo[raid_count]:-0}; i++));do
raid_devices_json="$(jq -n \
--argjson arr "$raid_devices_json" \
--arg name "${diskinfo[raid$i.name]:-}" \
--arg level "${diskinfo[raid$i.level]:-}" \
--arg devs "${diskinfo[raid$i.devs]:-}" \
--arg mount "${diskinfo[raid$i.mount]:-}" \
'
          $arr + [{
            name: $name,
            level: $level,
            members: ($devs | split(" ") | map(select(length>0))),
            mountpoint: $mount
          }]
          ')"
done
disk_fio_json="{}"
for k in "${!diskinfo[@]}";do
[[ $k =~ ^fio\.([^\.]+)\.([^\.]+)\.(bw|iops)$ ]]||continue
rw="${BASH_REMATCH[1]}"
name="${BASH_REMATCH[2]}"
metric="${BASH_REMATCH[3]}"
val="${diskinfo[$k]}"
disk_fio_json="$(jq -n \
--argjson obj "$disk_fio_json" \
--arg rw "$rw" \
--arg name "$name" \
--arg metric "$metric" \
--arg val "$val" \
'
          $obj
          | .[$rw] = (.[$rw] // {})
          | .[$rw][$name] = (.[$rw][$name] // {})
          | .[$rw][$name][$metric] = ($val|tonumber?)
          ')"
done
_hwjson="$hwjson"
hwjson="$(jq \
--argjson disks "$disk_devices_json" \
--argjson raids "$raid_devices_json" \
--argjson fio "$disk_fio_json" \
--arg total "${diskinfo[total]:-}" \
--arg used "${diskinfo[used]:-}" \
--arg avail "${diskinfo[avail]:-}" \
--arg p_used "${diskinfo[p_used]:-}" \
--arg p_avail "${diskinfo[p_avail]:-}" \
--arg testdir "${diskinfo[testdir]:-}" \
--arg testdev "${diskinfo[testdev]:-}" \
--arg testtype "${diskinfo[testdev_type]:-}" \
--arg members "${diskinfo[testdev_members]:-}" \
--arg mount "${diskinfo[testdev_mount]:-}" \
'
    ########################################
    # helpers
    ########################################
    def num($v):
      if ($v // "" | tostring | test("^[0-9]+$"))
      then ($v|tonumber)
      else null
      end;
    ########################################
    # Disk
    ########################################
    .Disk = {
      summary: {
        total_bytes: num($total),
        used_bytes:  num($used),
        avail_bytes: num($avail),
        used_percent: num($p_used),
        avail_percent: num($p_avail)
      },
      devices: $disks,
      raid: $raids,
      test: {
        directory: $testdir,
        device: $testdev,
        device_type: $testtype,
        members: ($members | split(" ") | map(select(length>0))),
        mountpoint: $mount
      },
      benchmarks: {
        fio: $fio
      }
    }
    ' <<<"$_hwjson")"
_hwjson="$hwjson"
hwjson="$(jq \
--arg total "${markinfo[total]:-}" \
--arg cpu "${markinfo[cpu]:-}" \
--arg gpu "${markinfo[gpu]:-}" \
--arg mem "${markinfo[mem]:-}" \
--arg disk "${markinfo[disk]:-}" \
--arg total_pct "${markinfo[total_pct]:-}" \
--arg cpu_pct "${markinfo[cpu_pct]:-}" \
--arg gpu_pct "${markinfo[gpu_pct]:-}" \
--arg mem_pct "${markinfo[mem_pct]:-}" \
--arg disk_pct "${markinfo[disk_pct]:-}" \
'
    def num($v):
      if ($v // "" | tostring | test("^[0-9]+(\\.[0-9]+)?$"))
      then ($v | tonumber)
      else null
      end;
    .Benchmark = {
      total:        num($total),
      cpu:          num($cpu),
      gpu:          num($gpu),
      memory:       num($mem),
      disk:         num($disk),
      total_pct:    num($total_pct),
      cpu_pct:      num($cpu_pct),
      gpu_pct:      num($gpu_pct),
      memory_pct:   num($mem_pct),
      disk_pct:     num($disk_pct)
    }
    ' <<<"$_hwjson")"
}
check_Hardware(){
IP=$1
ibar_step=0
hwjson='{
        "Head": {},
        "OS": {},
        "Motherboard": {},
        "CPU": {},
        "GPU": {},
        "Memory": {},
        "Disk": {},
        "Benchmark": {}
    }'
[[ $2 -eq 4 ]]&&hide_ipv4 $IP
[[ $2 -eq 6 ]]&&hide_ipv6 $IP
countRunTimes
get_virt
[[ $mode_skip != *"1"* ]]&&get_os
[[ $mode_skip != *"2"* ]]&&get_mb
[[ $mode_skip != *"3"* ]]&&get_cpu
[[ $mode_skip != *"3"* && $mode_fast -eq 0 ]]&&test_cpu_sysbench
[[ $mode_skip != *"3"* && $mode_fast -eq 0 && mode_privacy -eq 0 ]]&&test_cpu_gb5
[[ $mode_skip != *"4"* ]]&&get_gpu
[[ $mode_skip != *"4"* && $mode_fast -eq 0 && mode_privacy -eq 0 ]]&&test_gpu
[[ $mode_skip != *"5"* ]]&&get_mem
[[ $mode_skip != *"5"* && $mode_fast -eq 0 ]]&&test_mem
[[ $mode_skip != *"6"* ]]&&get_disk
[[ $mode_skip != *"6"* && $mode_fast -eq 0 ]]&&test_disk
[[ $mode_skip != *"7"* && $mode_fast != 1 && ($mode_skip != *3* || $mode_skip != *4* || $mode_skip != *5* || $mode_skip != *6*) ]]&&get_mark
echo -ne "$Font_LineClear" 1>&2
for ((i=0; i<ADLines; i++));do
echo -ne "$Font_LineUp" 1>&2
echo -ne "$Font_LineClear" 1>&2
done
local hw_report=$(show_head
[[ $mode_skip != *"1"* ]]&&show_os
[[ $mode_skip != *"2"* ]]&&show_mb
[[ $mode_skip != *"3"* ]]&&show_cpu
[[ $mode_skip != *"4"* ]]&&show_gpu
[[ $mode_skip != *"5"* ]]&&show_mem
[[ $mode_skip != *"6"* ]]&&show_disk
[[ $mode_skip != *"7"* && $mode_fast != 1 && ($mode_skip != *3* || $mode_skip != *4* || $mode_skip != *5* || $mode_skip != *6*) ]]&&show_mark
show_tail)
local report_link=""
[[ mode_json -eq 1 || mode_output -eq 1 || mode_privacy -eq 0 ]]&&save_json
[[ mode_privacy -eq 0 ]]&&report_link=$(curl -$2 -s -X POST http://upload.check.place -d "type=hardware" --data-urlencode "json=$hwjson" --data-urlencode "content=$hw_report")
[[ mode_json -eq 0 ]]&&echo -ne "\r$hw_report\n"
[[ mode_json -eq 0 && mode_privacy -eq 0 && $report_link == *"https://Report.Check.Place/"* ]]&&echo -ne "\r${stail[link]}$report_link$Font_Suffix\n"
[[ mode_json -eq 1 ]]&&echo -ne "\r$hwjson\n"
echo -ne "\r\n"
if [[ mode_output -eq 1 ]];then
case "$outputfile" in
*.[aA][nN][sS][iI])echo "$hw_report" >>"$outputfile" 2>/dev/null
;;
*.[jJ][sS][oO][nN])echo "$hwjson" >>"$outputfile" 2>/dev/null
;;
*)echo -e "$hw_report"|sed 's/\x1b\[[0-9;]*[mGKHF]//g' >>"$outputfile" 2>/dev/null
esac
fi
}
adaptoslocale
check_connectivity
get_ipv4
get_ipv6
[[ -n $NQENV ]]&&eval "$NQENV"
get_opts "$@"
[[ mode_no -eq 0 ]]&&install_dependencies 1>&2
set_language
if [[ $ERRORcode -ne 0 ]];then
echo -ne "\r$Font_B$Font_Red${swarn[$ERRORcode]}$Font_Suffix\n"
exit $ERRORcode
fi
clear
show_ad
if [[ -n $IPV4 ]];then
check_Hardware "$IPV4" 4
else
check_Hardware "$IPV6" 6
fi
