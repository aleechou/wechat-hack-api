#! /usr/bin/env coffee

HackApiClient = require '../index.coffee'

client = new HackApiClient
# client.login 'alee.chou@imagchina.com', '11111'

stdincb = undefined

cmd =
    login : ->
        process.stdin.write 'username: '
        (data) ->
            username = data.trim() || 'aaron.geng@imagchina.com'
            process.stdin.write 'password: '
            (data) ->
                password = data.trim() || 'imagchina'
                console.log "logining as #{username} ..."
                client.login username, password, '', (err,token)->
                    # 输入验证码
                    if err && err.message=='verifycode'
                        console log '需要输入验证码，验证码已保存至:' + err.localpath
                        process.stdin.write 'verify code: '
                        arguments.callee # 递归处理登陆
                    else
                        if token
                            console.log 'login sucess, new token is ', token
                        else
                            console.log 'login fail'
                        console.log 'error: ', err if err

    scanuser: ->
        client.scanuser 0, (err,cgiData) ->
            console.log cgiData

    scanmessage: ->
        client.scanmessage 100, (err,cgiData) ->
            console.log cgiData

    usermessage: ->
        process.stdin.write 'fakeid: '
        (data) ->
            client.usermessage data.trim()||'1867891761', (err,cgiData) ->
                console.log cgiData

    userinfo: ->
        process.stdin.write 'fakeid:'
        (data) ->
        client.userinfo data.trim()||'1867891761', (err,info)->

    headimg: ->
        process.stdin.write 'fakeid:'
        (data)->
            fakeid = data.trim() || '1867891761'
            process.stdin.write 'local path:'
            (data)->
                localpath = do data.trim
                client.headimg fakeid, localpath, (err) ->
                    if err
                        console.log err
                    else
                        console.log 'download user head img to ', localpath

    send: ->
        process.stdin.write 'fakeid:'
        (data)->
            fakeid = data.trim() || '1867891761'
            process.stdin.write 'text:'
            (data)->
                client.send fakeid, data

    settoken: ->
        process.stdin.write 'new token:'
        (data) ->
            client.token = data.trim()

    help : ->
        console.log 'what are doing?'
        console.log "    #{cmdname}" for cmdname in Object.keys(cmd)

do process.stdin.resume
process.stdin.on 'data', (data)->
    data = do data.toString
    if stdincb
        newcb = stdincb data
    else
        data = do data.trim
        cmd[data] && newcb = do cmd[data]

    stdincb = if typeof newcb=='function' then newcb else undefined
    do prompt if not stdincb

prompt = ->
    process.stdin.write ' > '

console.log "this is wechat hack-api"
do cmd.help
do prompt
