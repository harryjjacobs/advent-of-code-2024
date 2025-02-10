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

function print_update(update)
    for _, page in pairs(update) do
        io.write(page..",")
    end
    print()
end

-- i regret using lua
function table.copy(t)
    local new_table = {}
    for k, v in pairs(t) do
      new_table[k] = v
    end
    return new_table
end

-- sum the number of common elements between two "arrays" (values in tables)
-- assumes that each array is a set
function intersection_sum(a, b)
    local sum=0
    for _, page_a in pairs(a) do
        for _, page_b in pairs(b) do
            if page_a == page_b then
                sum = sum + 1
            end
        end
    end
    return sum
end

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
    if not correct then
        print("incorrect:")
        print_update(update)
        sorted = table.copy(update)
        rule_counts = {}
        for i, page in pairs(update) do
            page_rules = rules[page]
            if page_rules ~= nil then
                rule_counts[page] = intersection_sum(page_rules, update)
            else
                rule_counts[page] = 0
            end
        end
        -- sort the update pages by rule count (i.e. the page who's rules refer to the most pages in the same update should be first)
        function sort_predicate(a, b)
            return rule_counts[a] > rule_counts[b]
        end
        table.sort(sorted, sort_predicate)
        print("correct:")
        print_update(sorted)
        sum = sum + sorted[(#sorted)//2 + 1]
    end
end

print(sum)
