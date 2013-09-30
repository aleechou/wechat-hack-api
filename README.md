这是一个微信公众平台的 hack api，通过hack编辑后台实现

== Useage ==

```javascript
var WechatHackApi = require('wechat-hack-api') ;

var client = new WechatHackApi ;
client.login('<username>','<password>','<verify code if need>',function(err,token){

    // 登陆时遇到验证码
    if(err && err.message=='verifycode')
    {
        // 验证码图片已经下载至：err.localpath
        // todo ...
    }

    if(token)
    {
        // login success !

        // 发送消息
        client.send('<fakeid>','hello',function(err){
            // todo ...
        }) ;

        // 获得用户头像
        client.headimg('<fakeid>','<local path>',function(err){
            // todo ...
        }) ;

        // 用户信息
        client.userinfo('<fakeid>',function(err,data){
            // todo ...
        }) ;

        // 扫描用户
        client.scanuser(function(err,data){
            // todo ...
        }) ;

        // 扫描消息
        client.scanmessage(function(err,data){
            // todo ...
        }) ;
    }
})

```
