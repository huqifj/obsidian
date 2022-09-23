## 网上的例子

[参考链接](https://blog.csdn.net/a112626290/article/details/105404318)

```shell
#!/usr/bin/env bash  

GITLAB_URL="172.18.20.41"

echo -n "0.请输入 Gitlab Access Token:"  
read token  
echo -n "1.请输入项目的 id:"  
read id  
echo -n "2.请输入项目 release 的名称:"  
read name  
echo -n "3.请输入即将创建 release 版本的tag:"  
read tag_name  
echo -n "4.请输入 release 的描述:"  
read description  
echo -n "5.请输入 release 二进制文件名称:"  
read release_file_name  
echo -n "6.请输入 release 二进制文件发布路径:"  
read release_path  

#创建发布版本  
curl --header 'Content-Type: application/json' --header "PRIVATE-TOKEN: $token" --data '{ "name": "'$name'", "tag_name": "'$tag_name'", "ref":"'$tag_name'" ,"description": "'$description'" }' --request POST http://$GITLAB_URL/api/v4/projects/$id/releases

#创建二进制文件链接
curl --request POST  --header "PRIVATE-TOKEN: $token"  --data name="$release_file_name"   --data url="$release_path"  "http://$GITLAB_URL/api/v4/projects/$id/releases/$tag_name/assets/links"
```

## API
```shell
# List project repository tags
curl --header "PRIVATE-TOKEN: <your_access_token>" "http://gitlab.example.com/api/v4/projects/<id>/repository/tags/test-v2.0.12"

# Get a single repository tag
curl --header "PRIVATE-TOKEN: <your_access_token>" "http://gitlab.example.com/api/v4/projects/<id>/repository/tags"

# Create a new tag
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/5/repository/tags?tag_name=test&ref=master"

# Get a Release by a tag name
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/24/releases/v0.1"
curl --header "PRIVATE-TOKEN: wq48xLxGEvXDE5sm3adr" "https://192.168.1.24:11030/api/v4/projects/8/releases/test-v1.0.0"


# Create a release
curl --header 'Content-Type: application/json' --header "PRIVATE-TOKEN: <your_access_token>" \
     --data '{ "name": "New release", "tag_name": "v0.3", "description": "Super nice release", "milestones": ["v1.0", "v1.0-rc"], "assets": { "links": [{ "name": "hoge", "url": "https://google.com", "filepath": "/binaries/linux-amd64", "link_type":"other" }] } }' \
     --request POST "https://gitlab.example.com/api/v4/projects/24/releases"


curl --header 'Content-Type: application/json' --header "PRIVATE-TOKEN: wq48xLxGEvXDE5sm3adr" \
     --data '{ "name": "api-test-v1.0.1", "tag_name": "api-test-v1.0.1", "ref": "develop", "description": "Super nice release", "assets": { "links": [{ "name": "hoge", "url": "http://192.168.1.24:11031/testdir.zip", "link_type":"other" }] } }' \
     --request POST "http://192.168.1.24:11030/api/v4/projects/8/releases"
```
