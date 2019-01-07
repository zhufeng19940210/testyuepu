#ci.sh

# 使用说明
# 终端进入到工程中的fastlane目录
# 本地构建ipa上传到蒲公英测试地址：sh local.sh -c dev_config -s 0
# 本地构建ipa上传到蒲公英灰度地址：sh local.sh -c gray_config -s 1

# 本地构建ipa上传到蒲公英临时地址pgyer@mem853.com/aomiABC123：
# sh local.sh -c dev_config -s 5

# 备注：仅打包本地代码，不会自动更新pod


#cd "/Users/apple/.jenkins/workspace/aomi/MacauLife/MacauLife/Config"

#fastlane_path="/Users/apple/.jenkins/workspace/aomi/fastlane"
#jenkins_root_path="${PWD}"
jenkins_root_path=$(dirname "${PWD}")
fastlane_path="${jenkins_root_path}/fastlane"
podfile_path="${jenkins_root_path}"

# 区测试包的提交地址 -1:不上传到蒲公英 0:提交到测试环境地址，1：提交到灰度环境，2：提交到发布环境地址
ipa_upload_type=""

# 用于存放ipa的文件夹
ipa_archive_file="archiveApp"

# 配置文件地址
config_to_base_path="${jenkins_root_path}/MacauLife/Config"
config_from_base_path="${jenkins_root_path}/MacauLife/Config/Configs"

# 蒲公英配置（HJR个人账号）
HJR_USER_KEY="b8475c6b8dc51a099bceb7af06957f33"
HJR_API_KEY="5300136993793746d09460fa7133076c"

# 测试环境-蒲公英配置
TEST_API_KEY="0eab097051a35fd3995a9b7b125ec477"
TEST_USER_KEY="25ed438b02fa08506326b645940bf2ce"

# 灰度环境-蒲公英配置
GRAY_API_KEY="81f089f67ab897419e6d18091b02a300"
GRAY_USER_KEY="a64d39b06552dd4e1c9a3f7926f3ec95"

# 发布环境-蒲公英配置
RELEASE_API_KEY="66aee9966b40c21fe9ee74567d31925d"
RELEASE_USER_KEY="66ef00f1bec2e4b91070eff74775f319"

# 蒲公英配置pgyer@mem853.com/aomiABC123
HJR_USER_KEY_test="0daccf6cc06f4eddff80eb6111011d87"
HJR_API_KEY_test="fb7a8f8824d0fbf48f629fe03e541952"

# 获取git提交日志
MSG=`git log -1 --pretty=%B`

# 获取ipa包
IPANAME="MacauLife"

# 更新配置文件
function config()
{
    #更新配置文件
    echo "Configing Workspace ..."
    cp_from="${config_from_base_path}/${opt_cfg}.plist"
    cp_to="${config_to_base_path}/config.plist"
    cp "$cp_from" "$cp_to" || { echo "❌ Config Fail! cp_from:${cp_from} cp_to:${cp_to}"; exit 1; }

    #log cfg
    echo "✅Configing Workspace Success!"
}

function cocoapods()
{
    cd "${podfile_path}"
    pod update --verbose --no-repo-update
}

# 更新证书
function sync_cer()
{
    cd ${fastlane_path}
    fastlane sync
}


# 打包 ipa
function archive_ipa()
{
    echo "🚀🚀🚀开始打包..."
    # 用fastlane打包(构建出来的包默认放到了根目录)
    cd ${fastlane_path}
    fastlane adhoc
}

# 上传ipa到蒲公英
upload_ipa()
{
    USER_KEY=""
    API_KEY=""

    if [ "${ipa_upload_type}" == "-1" ];then
        echo "参数设置为不上传到蒲公英~"
        return
    elif [ "${ipa_upload_type}" == "0" ];then
        USER_KEY=${TEST_USER_KEY}
        API_KEY=${TEST_API_KEY}
    elif [ "${ipa_upload_type}" == "1" ];then
        USER_KEY=${GRAY_USER_KEY}
        API_KEY=${GRAY_API_KEY}
    elif  [ "${ipa_upload_type}" == "2" ];then
        USER_KEY=${RELEASE_USER_KEY}
        API_KEY=${RELEASE_API_KEY}
    elif  [ "${ipa_upload_type}" == "3" ];then
        USER_KEY=${HJR_USER_KEY}
        API_KEY=${HJR_API_KEY}
    elif  [ "${ipa_upload_type}" == "5" ];then
        USER_KEY=${HJR_USER_KEY_test}
        API_KEY=${HJR_API_KEY_test}
    else
        echo "❌传入参数错误： -s 值只能是-1、0、1、2，分别代表测试包地址、灰度包地址、发布到地址"
    exit 1
    fi

    IPA_PATH="${jenkins_root_path}/${IPANAME}.ipa"
echo "🚀🚀🚀获取到ipa文件:${IPA_PATH}, 上传类型:${ipa_upload_type},开始上传到蒲公英... "
    curl -F "file=@${IPA_PATH}" -F "uKey=${USER_KEY}" -F "_api_key=${API_KEY}" -F "updateDescription=${MSG}" https://qiniu-storage.pgyer.com/apiv1/app/upload
}

# 对上传到蒲公英后的ipa进行归档
function save_ipa()
{
    echo "🚀🚀🚀对文件进行归档..."
    # 返回到根目录
    cd ${jenkins_root_path}
    echo "返回到根目录:${jenkins_root_path}"

    buildFile=${ipa_archive_file}
    # 在根目录新建文件夹
    if [  -d ${buildFile} ];then
        echo "删除已经存在的文件夹${buildFile}"
        rm -rf ${buildFile}
    fi
    echo "新建文件夹${buildFile}"
    mkdir ${buildFile}

    # 将当前日期赋值给DATE变量
    DATE=$(date "+%Y-%m-%d_%H点%M分%S秒")
    ANewFileName=${DATE}

    # 将打包出来的文件移动到新建文件夹中
    fromPath1="${jenkins_root_path}/${IPANAME}.app.dSYM.zip"
    fromPath2="${jenkins_root_path}/${IPANAME}.ipa"
    toFilePath="${jenkins_root_path}/${buildFile}"

    # 将文件【移动】到归档文件夹
    mv ${fromPath1} ${toFilePath}
    mv ${fromPath2} ${toFilePath}

    cd ${toFilePath}
    # 用日期重命名文件
    mv "${IPANAME}.ipa" "${ANewFileName}.ipa"
    mv "${IPANAME}.app.dSYM.zip" "${ANewFileName}.zip"
}

# clean
clean()
{
cd ${jenkins_root_path}
buildFile=${ipa_archive_file}
# 在根目录新建文件夹
if [  -d ${buildFile} ];then
echo "删除已经存在的文件夹${buildFile}"
rm -rf ${buildFile}
fi
}



################  interface  ################
# GETOPT
opt_cfg=""
while getopts "c:s:" arg #选项后面的冒号表示该选项需要参数
do
case $arg in
    c)
    opt_cfg=${OPTARG} #参数存在$OPTARG中
    ;;
    s)
    ipa_upload_type=${OPTARG}
    ;;
    ?)  #当有不认识的选项的时候arg为?
    echo "unkonw argument"
exit 1
    ;;
esac
done

echo "设置的配置文件名: ${opt_cfg}"

# step1: 更新配置文件
config

# step2: 更新cocoapods
# cocoapods

# 更新证书
sync_cer

# step3: 打包
archive_ipa

# step4: 上传蒲公英
upload_ipa

# step5: 上传蒲公英完成后对文件进行归档
save_ipa

# Clean
clean

#ci.sh

