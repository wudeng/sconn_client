local socket = require "socket.c"
local buffer_queue = require "buffer_queue"

local EINTR = socket.EINTR
local EAGAIN = socket.EAGAIN

local mt = {}
mt.__index = mt

local M = {}

local function conn_error(errcode)
    return socket.strerror(errcode).."["..tostring(errcode).."]"
end

function M.new(addr, port)
    local fd = socket.socket(addr.family, socket.SOCK_STREAM, 0);
    fd:setblocking(false)
    local errcode = fd:connect(addr.addr, port)
    local obj = {
        v_send_buf = buffer_queue.create(),
        v_recv_buf = buffer_queue.create(),
        v_fd = fd,
        -- v_check_connect = true,
    }
    return setmetatable(obj, mt), errcode
end

function mt:flush_send()
    local send_buf = self.v_send_buf
    local v = send_buf:get_head_data()
    local fd = self.v_fd
    local count = 0

    while v do
        local len = #v
        local n, err = fd:send(v)
        if not n then
            if err == EAGAIN or err == EINTR then
                break
            end
            return false, conn_error(err)
        else
            count = count + n
            send_buf:pop(n)
            if n < len then
                break
            end
        end
        v = send_buf:get_head_data()
    end
    return count
end

function mt:flush_recv()
    local recv_buf = self.v_recv_buf
    local fd = self.v_fd
    local count = 0
::CONTINUE::

    local data, err = fd:recv()
    if not data then
        if err == EAGAIN or err == 0 then
            return true
        elseif err == EINTR then
            goto CONTINUE
        else
            return false, conn_error(err)
        end
    elseif #data == 0 then
        return false, "connect_break"
    else
        local len = #data
        count = count + len
        recv_buf:push(data)
    end

    return count
end

function mt:send(data)
    self.v_send_buf:push(data)
end

function mt:update()
end
-- function mt:check_connect()
--     local fd = self.v_fd
--     if not fd then
--         return false, 'fd is nil'
--     end

--     if self.v_check_connect then
--         local success, err = fd:check_async_connect()
--         if not success then
--             return false, err and conn_error(err) or "connecting"
--         else
--             self.v_check_connect = false
--             return true
--         end
--     else
--         return true
--     end
-- end

return M
