var RohBot = (function () {
    function RohBot(address) {
        var _this = this;
        this.address = address;
        this.username = null;

        window.setInterval(function () {
            if (_this.isConnected()) {
                _this.send({ Type: "ping" });
            } else {
                _this.connect();
            }
        }, 2500);

        this.manualSysMessage("Connecting to RohBot...");
        this.connect();
    }
    RohBot.prototype.connect = function () {
        var _this = this;
        this.disconnect();
        this.isConnecting = true;

        this.socket = new WebSocket(this.address);
        var connected = false;

        this.socket.onopen = function (e) {
            _this.isConnecting = false;

            if (!connected)
                _this.manualSysMessage("Connected to RohBot!");

            connected = true;

            if (_this.onConnected != null)
                _this.onConnected();
        };

        var wsClosed = function (e) {
            _this.isConnecting = false;

            if (connected)
                _this.manualSysMessage("Lost connection to RohBot. Reconnecting...");

            connected = false;

            if (_this.onDisconnected != null)
                _this.onDisconnected();

            _this.disconnect();
        };

        this.socket.onclose = wsClosed;

        this.socket.onerror = function (e) {
            wsClosed(e);
            console.error("websocket error", e);
        };

        this.socket.onmessage = function (e) {
            var packet = JSON.parse(e.data);

            switch (packet.Type) {
                case "authResponse": {
                    _this.username = packet.Name;
                    if (_this.username != null && _this.username.length == 0)
                        _this.username = null;

                    if (_this.onLogin != null)
                        _this.onLogin(packet);

                    break;
                }

                case "chat": {
                    if (_this.onChat != null)
                        _this.onChat(packet);
                    break;
                }

                case "chatHistory": {
                    if (_this.onChatHistory != null)
                        _this.onChatHistory(packet);
                    break;
                }

                case "message": {
                    if (_this.onMessage != null)
                        _this.onMessage(packet);
                    break;
                }

                case "sysMessage": {
                    if (_this.onSysMessage != null)
                        _this.onSysMessage(packet);
                    break;
                }

                case "userList": {
                    if (_this.onUserList != null)
                        _this.onUserList(packet);
                    break;
                }
            }
        };
    };

    RohBot.prototype.disconnect = function () {
        this.username = null;

        if (this.socket == null)
            return;

        this.socket.close();
        this.socket.onopen = null;
        this.socket.onclose = null;
        this.socket.onerror = null;
        this.socket.onmessage = null;
        this.socket = null;
    };

    RohBot.prototype.isConnected = function () {
        if (this.socket == null)
            return false;
        return this.socket.readyState == WebSocket.OPEN;
    };

    RohBot.prototype.getUsername = function () {
        return this.username;
    };

    RohBot.prototype.login = function (username, password) {
        this.send({
            Type: "auth",
            Method: "login",
            Username: username,
            Password: password
        });
    };

    RohBot.prototype.register = function (username, password) {
        this.send({
            Type: "auth",
            Method: "register",
            Username: username,
            Password: password
        });
    };

    RohBot.prototype.requestHistory = function (roomName, afterDate) {
        this.send({
            Type: "chatHistoryRequest",
            Target: roomName,
            AfterDate: afterDate
        });
    };

    RohBot.prototype.sendMessage = function (roomName, message) {
        this.send({
            Type: "sendMessage",
            Target: roomName,
            Content: message
        });
    };

    RohBot.prototype.manualSysMessage = function (message) {
        if (this.onSysMessage != null) {
            this.onSysMessage({
                Type: "sysMessage",
                Date: new Date().getTime() / 1000,
                Content: message
            });
        }
    };

    RohBot.prototype.send = function (packet) {
        try  {
            this.socket.send(JSON.stringify(packet));
        } catch (e) {
        }
    };
    return RohBot;
})();
