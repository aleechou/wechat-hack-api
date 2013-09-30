// Generated by CoffeeScript 1.6.2
(function() {
  var HackApiClient, client, cmd, https, prompt, stdincb, urllib;

  urllib = require('urllib');

  HackApiClient = require('../index.coffee');

  https = require('https');

  client = new HackApiClient;

  stdincb = void 0;

  cmd = {
    login: function() {
      process.stdin.write('username: ');
      return function(data) {
        var username;

        username = data.trim() || 'aaron.geng@imagchina.com';
        process.stdin.write('password: ');
        return function(data) {
          var password;

          password = data.trim() || 'imagchina';
          console.log("logining as " + username + " ...");
          return client.login(username, password, '', function(err, token) {
            if (err && err.message === 'verifycode') {
              console(log('需要输入验证码，验证码已保存至:' + err.localpath));
              process.stdin.write('verify code: ');
              return arguments.callee;
            } else {
              if (token) {
                console.log('login sucess, new token is ', token);
              } else {
                console.log('login fail');
              }
              if (err) {
                return console.log('error: ', err);
              }
            }
          });
        };
      };
    },
    scanuser: function() {
      return client.scanuser(0, function(err, cgiData) {
        return console.log(cgiData);
      });
    },
    scanmessage: function() {
      return client.scanmessage(100, function(err, cgiData) {
        return console.log(cgiData);
      });
    },
    usermessage: function() {
      process.stdin.write('fakeid: ');
      return function(data) {
        return client.usermessage(data.trim() || '1867891761', function(err, cgiData) {
          return console.log(cgiData);
        });
      };
    },
    userinfo: function() {
      process.stdin.write('fakeid:');
      return function(data) {
        return client.userinfo(data.trim() || '1867891761', function(err, info) {});
      };
    },
    headimg: function() {
      process.stdin.write('fakeid:');
      return function(data) {
        var fakeid;

        fakeid = data.trim() || '1867891761';
        process.stdin.write('local path:');
        return function(data) {
          var localpath;

          localpath = data.trim();
          return client.headimg(fakeid, localpath, function(err) {
            if (err) {
              return console.log(err);
            } else {
              return console.log('download user head img to ', localpath);
            }
          });
        };
      };
    },
    send: function() {
      process.stdin.write('fakeid:');
      return function(data) {
        var fakeid;

        fakeid = data.trim() || '1867891761';
        process.stdin.write('text:');
        return function(data) {
          return client.send(fakeid, data);
        };
      };
    },
    settoken: function() {
      process.stdin.write('new token:');
      return function(data) {
        return client.token = data.trim();
      };
    },
    help: function() {
      var cmdname, _i, _len, _ref, _results;

      console.log('what are doing?');
      _ref = Object.keys(cmd);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        cmdname = _ref[_i];
        _results.push(console.log("    " + cmdname));
      }
      return _results;
    },
    t: function() {
      return urllib.request('https://mp.weixin.qq.com/cgi-bin/getcontactinfo', {
        headers: {
          Cookie: "cert=e0hwX3gNEEqV4xapDyT2pkcBgXbJ3QBi; remember_acct=aaron.geng@imagchina.com; slave_user=gh_4f18b82a5953; slave_sid=TGNUQnB4UE9TRFZNUXRPaEFTcmtYUl84MUVUT0hZX3A5VFl3bk1oZW9jWWJGTHJlQlN3dkd3REg3dXNcnNheWs1M0ZSalNkdlBtOXlObThDU0JobGVackdvYzZRbEU3cUZOZllFcXNzTUFZeFc1OGlGalpyUnhocndpNWprNFU="
        },
        type: 'POST',
        data: {
          token: "121669633",
          lang: "zh_CN",
          t: "ajax-getcontactinfo",
          fakeid: '486924695'
        }
      }, function(err, body, res) {
        return console.log(body.toString());
      });
    }
  };

  process.stdin.resume();

  process.stdin.on('data', function(data) {
    var newcb;

    data = data.toString();
    if (stdincb) {
      newcb = stdincb(data);
    } else {
      data = data.trim();
      cmd[data] && (newcb = cmd[data]());
    }
    stdincb = typeof newcb === 'function' ? newcb : void 0;
    if (!stdincb) {
      return prompt();
    }
  });

  prompt = function() {
    return process.stdin.write(' > ');
  };

  console.log("this is wechat hack-api");

  cmd.help();

  prompt();

}).call(this);
