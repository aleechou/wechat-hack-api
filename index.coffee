fs = require 'fs'
crypto = require 'crypto'
urllib = require 'urllib'
http = require 'http'

ApiClient = class ApiClient
    cookies: {}
    token: ''
    cgi: 'https://mp.weixin.qq.com/cgi-bin/'
    agent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.116 Safari/537.36'
    username: undefined
    password: undefined

    login: (username,password,imgcode,cb) ->
        @username = username
        @password = password

        urllib.request @cgi+'login?lang=zh_CN',
            dataType: 'json'
            headers:
                'Referer': @cgi + 'loginpage?t=wxm2-login&lang=zh_CN'
                'User-Agent': @agent
            data:
                username: username
                pwd: md5 password
                imagecode: imgcode||''
                f: 'json'
            type: 'POST'
            timeout: 30000
            , (err,body,res) =>
                #console.log arguments
                # 需要输入验证码
                if body and body.ErrCode==-6
                    @fetchVerifyCode username, (err,path)=>
                        if not err
                            rep = new Error 'verifycode'
                            rep.localpath = path
                        cb && cb rep

                else
                    token = undefined
                    if body and (rs=body.ErrMsg.toString().match(/\btoken=(\d+)/)) and rs[1]
                        @token = token = rs[1]
                        @username = username
                        @password = password

                        # cookies
                        cookies = @_receiveCookies res
                        @cookies['cert'] = cookies['cert']
                        @cookies['slave_user'] = cookies['slave_user']
                        @cookies['slave_sid'] = cookies['slave_sid']

                    cb && cb err, token

    fetchVerifyCode: (username,cb)->
        path = process.cwd() + "/tmp/#{username}.jpeg"
        filepipe = fs.createWriteStream path
        urllib.request @cgi+'verifycode?username=#{username}&r=#{new Date}',
            headers:
                'Referer': @cgi + 'loginpage?t=wxm2-login&lang=zh_CN'
                'User-Agent': @agent
            type: 'GET'
            writeStream: filepipe
            , (err,body,res) =>
                cb && cb err, if err then undefined else path


    scanuser : (pageidx,cb)->
        @_request @cgi+"contactmanage?t=user/index&pagesize=10&pageidx=#{pageidx||0}&type=0&groupid=0&lang=zh_CN"
            , {}
            , (err,body,res)->
                #console.log err,body.toString()
                rs = /<script type=\"text\/javascript\">\s+wx\.cgiData=([\s\w\W]+?)seajs\.use\(\"user\/index\"\);/.exec body.toString() if body

                cgiData = undefined
                eval 'cgiData='+rs[1] if rs

                cb && cb err, cgiData

    scanmessage : (count,cb)->
        @_request @cgi+"message?t=message/list&count=#{count||100}&day=7&lang=zh_CN"
            , {}
            , (err,body,res)->
                #console.log err,body.toString()
                rs = /<script type=\"text\/javascript\">\s+wx\.cgiData = ([\s\w\W]+?)seajs\.use\(\"message\/list\"\);/.exec body.toString() if body

                cgiData = undefined
                eval 'cgiData='+rs[1] if rs

                cb && cb err, cgiData


    usermessage : (fakeid,cb)->
        @_request @cgi+"singlesendpage?action=index&t=message/sen&tofakeid=#{fakeid}&lang=zh_CN"
            , {}
            , (err,body,res)->

                rs = /<script type=\"text\/javascript\">\s+wx\.cgiData = ([\s\w\W]+?)wx\.cgiData\.tofakeid/.exec body.toString() if body
                cgiData = undefined
                eval 'cgiData='+rs[1] if rs

                cb && cb err, cgiData.msg_items.msg_item

    userinfo: (fakeid,cb)->

        opts =
            type: 'POST'
            dataType: 'json'
            data:
                token:@token
                lang:"zh_CN"
                t:"ajax-getcontactinfo"
                fakeid:fakeid
            headers:
              Referer: "#{@cgi}contactmanage?t=user/index&pagesize=10&pageidx=0&type=0&groupid=0&lang=zh_CN&token=#{@gtoken}"

        @_request "#{@cgi}getcontactinfo", opts, (err,body,res) ->

                console.log err, if err then undefined else body
                cb && cb err,body

    headimg: (fakeid,localpath,cb)->
       @_request @cgi+"getheadimg?fakeid=#{fakeid}&lang=zh_CN",
            writeStream: fs.createWriteStream(localpath)
            headers:
                'User-Agent': @agent
                'Cookie': @_sendCookies()
            , (err,body,res)->
                cb && cb err

    voice: (msgid,localpath,cb)->
        console.log msgid
        @_request @cgi+"getvoicedata?msgid=#{msgid}&fileid=&lang=zh_CN&token=#{@gtoken}",
            writeStream: fs.createWriteStream(localpath)
            headers:
                'User-Agent': @agent
                'Cookie': @_sendCookies()
                'Referer': "#{@cgi}singlesendpage?t=wxm-message&lang=zh_CN&count=50&token=#{@gtoken}"
            , (err,body,res)->
                console.log 'voice finish'
                cb && cb err

    send: (fakeid,txt,cb) ->
        opts =
            type: 'POST'
            headers:
                'Referer': @cgi + 'singlesendpage?' + 'tofakeid=' + fakeid + 't=message/send&action=index&token=#{@gtoken}&lang=zh_CN',
            data:
                type:1
                content:txt
                error:false
                imgcode:''
                tofakeid:fakeid
                token:@token
                ajax:1
                dataType: 'json'
        console.log opts
        @_request @cgi+"singlesend", opts, (err,body)->
            console.log err, body.toString()


    _receiveCookies: (res) ->
        ret = {}
        return ret if not res.headers['set-cookie']
        for c in res.headers['set-cookie']
            if r=/^(.*?)=(.*);\s*Path=./.exec(c)
                ret[r[1]] = r[2]
        ret
    _sendCookies: ->
        cookies = ''
        for n,v of @cookies
            cookies+= '; '
            cookies+= "#{n}=#{v}"
        #console.log cookies
        cookies || undefined

    _request: (url,opts,cb) ->

        opts.timeout = 30000
        makesession = =>
            opts.headers = {} if not opts.headers
            opts.headers.Cookie = @_sendCookies()
            opts.headers['User-Agent'] = @agent
            _url = url
            if opts.type == 'POST'
                opts.data = {} if not opts.data
                opts.data.token = @token
            else
                _url+= "&token=" + @token
            _url

        urllib.request makesession(),opts,(err,body,res)=>
            # 会话超时，自动重新登陆
            if( @username && body && body.toString().match(/登录超时/) )
                console.log 'wechat session time out, auto relogin ...'
                @login @username, @password, '', (err,token)->
                    if token
                        console.log "relogined to wechat, new token is : #{token}"
                        urllib.request makesession(),opts,cb
                    else
                        console.log 'relogined fail.'
                        cb && cb(err)
                return

            # callback
            cb && cb(err,body,res)

module.exports = ApiClient


# util ---------------

md5 = (input) ->
  crypto.createHash('md5').update(input).digest 'hex'
