local sconn = require "sconn"
local socket = require "socket.c"
--local sleep = socket.sleep

-- local sock, err = sconn.connect_host("127.0.0.1", 9527)
local sock, err = sconn.connect_host("127.0.0.1", 1248)
assert(sock, err)

local count = 1
local out = {}

local function pause()
    io.stdin:read '*l'
end

while true do
    local s = "kiss_"..(count)

    if count % 7==0 then
        local success, err = sock:reconnect()
        assert(success, err)
    end

    sock:send(s)
    print("send:", s, "len:", #s)

    local success, err = sock:update()
    if not success then
        print(success, err)
    end

    local len = sock:recv(out)
    local data = table.concat(out, "", 1, len)
    print("recv:", type(data), "len:", #data, data)

    count = count + 1
    pause()
    -- os.execute("sleep 1")
end
