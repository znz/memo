# How to apply:
#  sudo /mnt/shared/mitamae-riscv64-linux local /mnt/shared/chkbuild-service.rb

# 旧 riscv.rubyci.org での設定を参考にして、 git pull, start-rubyci, rm -rf tmp/build にしている。
# start-rubyci を動かす ruby は ruby-infra-recipe でインストールされた rbenv管理のものなので、 bash -l を使っている。
file '/etc/systemd/system/chkbuild.service' do
  action :create
  owner 'root'
  mode '444'
  content <<-EOF
[Unit]
Description=Run chkbuild

[Service]
Type=oneshot
WorkingDirectory=/home/chkbuild/chkbuild
# mitamae with https://github.com/ruby/ruby-infra-recipe uses deploy branch,
# so this explicitly pull from origin/master to current branch.
ExecStartPre=/usr/bin/git pull origin master
ExecStart=/bin/bash -lc /home/chkbuild/chkbuild/start-rubyci
ExecStartPost=/bin/rm -rf tmp/build
User=chkbuild
Group=chkbuild
PrivateTmp=true

Environment=RUBYCI_NICKNAME=#{node[:hostname]}
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
EnvironmentFile=-/etc/systemd/system/chkbuild.env
  EOF
end

# /etc/systemd/system/chkbuild.env は root だけ読めればいいので、パーミッションは 400 で作成する。
# ローカルでのテストなら DISABLE_S3_UPLOAD を設定する。

# マシンがブートしてから10分後に初回実行して、その後1時間リブートなどのメンテナンスができる時間を置いてから繰り返す。
file '/etc/systemd/system/chkbuild.timer' do
  action :create
  owner 'root'
  mode '444'
  content <<-EOF
[Unit]
Description=Run chkbuild

[Timer]
OnBootSec=10min
OnUnitInactiveSec=1h
Persistent=true

[Install]
WantedBy=timers.target
  EOF
end

package 'ccache'


# ccache を使う。
directory '/etc/systemd/system/chkbuild.service.d'
file '/etc/systemd/system/chkbuild.service.d/ccache.conf' do
  action :create
  owner 'root'
  mode '444'
  content <<-EOF
[Service]
Environment=CC='ccache gcc' CXX='ccache g++' XDG_CACHE_HOME=/home/chkbuild/.cache
ExecStartPre=!/usr/bin/install -o chkbuild -g chkbuild -m 2775 -d /home/chkbuild/.cache
  EOF
end

# 再起動のトリガーに使えるように touch 処理を追加する。
file '/etc/systemd/system/chkbuild.service.d/touch.conf' do
  action :create
  owner 'root'
  mode '444'
  content <<-EOF
[Service]
ExecStartPost=!/usr/bin/touch /run/chkbuild.done /mnt/shared/chkbuild.done
  EOF
end

file '/etc/systemd/system/reboot-if-required.service' do
  action :create
  owner 'root'
  mode '444'
  content <<-EOF
[Unit]
Description=Reboot if required
RefuseManualStart=true
RefuseManualStop=true
ConditionPathExists=/run/reboot-required

[Service]
Type=oneshot
# wait because host may reboot
ExecStartPre=/usr/bin/sleep 5m
ExecStart=/sbin/reboot
  EOF
end

file '/etc/systemd/system/reboot-after-chkbuild.path' do
  action :create
  owner 'root'
  mode '444'
  content <<-EOF
[Unit]
Description=Trigger reboot-if-required

[Path]
PathModified=/run/chkbuild.done
Unit=reboot-if-required.service

[Install]
WantedBy=multi-user.target
  EOF
end

# 確認なしで自動で再起動する。
file '/etc/needrestart/conf.d/50-autorestart.conf' do
  action :create
  owner 'root'
  mode '444'
  content <<-EOF
$nrconf{restart} = 'a';
  EOF
end

execute 'systemctl daemon-reload'
service 'reboot-after-chkbuild.path' do
  action [:enable, :start]
end
service 'chkbuild.timer' do
  action [:enable, :start]
end
