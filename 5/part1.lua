#!/usr/bin/env lua

file = io.open("input")

rules = {}
updates = {}

-- read the file
for line in file:lines() do
    if line:match("(%d+)|(%d+)") then
        for k, v in line:gmatch("(%d+)|(%d+)") do
            key = tonumber(k)
            value = tonumber(v)
            if rules[key] ~= nil then
                rules[key][#rules[key]+1] = value
            else
                rules[key] = {}
                rules[key][0] = value
            end
        end
    elseif line:match("[^,]+") then
        updates[#updates+1] = {}
        for value in line:gmatch("[^,]+") do
            updates[#updates][#(updates[#updates])+1] = tonumber(value)
        end
    end
end

file:close()

-- iterate over the pages in each update and ensure that the rules are respected
sum = 0
for _, update in pairs(updates) do
    seen = {}
    correct = true
    for _, page in pairs(update) do
        page_rules = rules[page]
        if page_rules ~= nil then
            for _, after in pairs(page_rules) do
                if seen[after] ~= nil then
                    correct = false
                    break
                end
            end
        end
        seen[page] = 1
    end
    if correct then
        -- find the middle value in the update
        sum = sum + update[(#update)//2 + 1]
    end
end

print(sum)
