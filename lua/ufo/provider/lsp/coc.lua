local fn = vim.fn

local promise = require('promise')

---@class UfoLspCocClient
---@field initialized boolean
---@field enabled boolean
local CocClient = {
    initialized = false,
    enabled = false,
}

---@param action string
---@vararg any
---@return Promise
function CocClient.action(action, ...)
    local args = {...}
    return promise(function(resolve, reject)
        table.insert(args, function(err, res)
            if err ~= vim.NIL then
                reject(err)
            else
                if res == vim.NIL then
                    res = nil
                end
                resolve(res)
            end
        end)
        fn.CocActionAsync(action, unpack(args))
    end)
end

---@param name string
---@vararg any
---@return Promise
function CocClient.runCommand(name, ...)
    return CocClient.action('runCommand', name, ...)
end

---
---@param bufnr number
---@param kind? string|'comment'|'imports'|'region'
---@return Promise
function CocClient.requestFoldingRange(bufnr, kind)
    if not CocClient.initialized or not CocClient.enabled then
        return promise.reject('UfoFallbackException')
    end
    return CocClient.runCommand('ufo.foldingRange', bufnr, kind)
end

function CocClient.handleInitNotify()
    if not CocClient.initialized then
        CocClient.initialized = true
    end
    CocClient.enabled = true
end

function CocClient.handleDisposeNotify()
    CocClient.enabled = false
end

return CocClient
