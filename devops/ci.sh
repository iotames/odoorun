#!/bin/bash

# 提交合并请求。合并通过之前。
# CI_COMMIT_BRANCH 为空
# CI_PIPELINE_SOURCE:merge_request_event, CI_MERGE_REQUEST_EVENT_TYPE(detached), CI_MERGE_REQUEST_TARGET_BRANCH_NAME(dev), CI_MERGE_REQUEST_TITLE(更新README.md文件，升级容器化快速部署流程。)

# 合并请求通过之后。
# CI_PIPELINE_SOURCE(push), CI_COMMIT_BRANCH(dev), CI_COMMIT_AUTHOR(authorname <xxxxx@qq.com>)
# CI_COMMIT_TITLE(Merge branch 'feature/yourbranch_20250417' into 'dev')
# CI_COMMIT_MESSAGE(Merge branch 'feature/yourbranch_20250417' into 'dev'
# 更新README.md文件，升级容器化快速部署流程。
# See merge request group/projectname!25)

# git push --tags
# CI_PIPELINE_SOURCE=push, CI_COMMIT_TAG=v0.1.0
# CI_COMMIT_AUTHOR(myname <123456@qq.com>), CI_COMMIT_TITLE(Merge branch 'feature/yourbranch_20250417' into 'dev')
# CI_COMMIT_MESSAGE(Merge branch 'feature/yourbranch_20250417' into 'dev'
# 更新README.md文件，升级容器化快速部署流程。
# See merge request group/projectname!25)
# git push --tags 时，${CI_COMMIT_BRANCH} 为空
# git tag v0.1.0 -m "这个是CI_COMMIT_TAG_MESSAGE，想要就得填"

# 企业微信群机器人
export WEBHOOK_KEY=""
export NOTIFY_TYPE="版本发布"
export NOTIFY_TITLE="通知内容。支持MARKDOWN格式"
export SEND_DATA='{
  "msgtype": "markdown",
  "markdown": {
    "content": "<font color=\"info\">持续集成通知</font>\n>
    >类型: <font color=\"comment\">版本发布</font>
    >分支: <font color=\"comment\">dev</font>
    >内容: <font>${NOTIFY_TITLE}</font>"
  }
}'

echo SEND_DATA: ${SEND_DATA}

# curl "https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=${WEBHOOK_KEY}" \
#    -H 'Content-Type: application/json' \
#    -d '${SEND_DATA}'
