#!/usr/bin/env bash
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# The Azure provided machines typically have the following disk allocation:
# Total space: 85GB
# Allocated: 67 GB
# Free: 17 GB
# This script frees up 28 GB of disk space by deleting unneeded packages and
# large directories.
# The Flink end to end tests download and generate more than 17 GB of files,
# causing unpredictable behavior and build failures.
#

# Copy from https://github.com/apache/flink/blob/master/tools/azure-pipelines/free_disk_space.sh
# and modified by Rookie_Zoe

echo "=============================================================================="
echo "Freeing up disk space on CI system"
echo "=============================================================================="
echo ">>>>>>>>>>>>>>> Listing disk space information"
df -h

echo ">>>>>>>>>>>>>>> Listing 100 largest packages"
dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n | tail -n 100

echo ">>>>>>>>>>>>>>> Removing large packages"
sudo -E apt-get remove -y '^ghc-8.*'
sudo -E apt-get remove -y '^dotnet-.*'
sudo -E apt-get remove -y '^llvm-.*'
sudo -E apt-get remove -y 'php.*'
sudo -E apt-get remove -y azure-cli google-cloud-sdk hhvm google-chrome-stable firefox powershell mono-devel
sudo -E apt-get autoremove -y
sudo -E apt-get clean

echo ">>>>>>>>>>>>>>> Removing large directories" # 15G total
sudo rm -rf /usr/local/lib/android
sudo rm -rf /usr/share/dotnet

echo ">>>>>>>>>>>>>>> Listing disk space information after cleanup"
df -h

echo ">>>>>>>>>>>>>>> Install tools chain which depends by building OpenWrt"
sudo -E apt-get -qq update
sudo -E apt-get -qq install build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3 python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib antlr3 gperf tree curl

echo ">>>>>>>>>>>>>>> Listing disk space information after installing"
df -h
