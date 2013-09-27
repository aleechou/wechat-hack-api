HackApiClient = require './index.coffee'

module.exports = (username, password) ->

    robot = new HackApiClient


    orirequest = robot._request
    rotbot._request = (url,opts,cb) ->
        
        orirequest.call this, url,opts, (err,body,res)=>

            # 处理会话超时
            if xxxxx
                @login username, password, '', (err) =>
                    if err
                        cb && cb err
                        return
                    # 登陆成功后 重新执行请求
                    else
                        orirequest url,opts,cb
                return

            cb && cb.call this, err, body, res

    robot
