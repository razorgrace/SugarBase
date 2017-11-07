local addonName, addonNamespace = ...

addonNamespace.Utils = function ()
    return {
        toCamelCase = function (str)
            return str:gsub('[^%w%s]', ''):gsub('(%w)(%w*)', function (a, b) return a:upper() .. b end):gsub('%s+', '')
        end,

        static = function (index, records, indexer, predicate)
            local subset = {}

            for _, record in pairs(records) do
                if indexer(record) == index and predicate(record) then
                    return function () return true end
                end
            end
        end,

        dynamic = function (index, records, indexer, predicate)
            local subset = {}

            for _, record in pairs(records) do
                if indexer(record) == index then
                    table.insert(subset, record)
                end
            end

            if next(subset) then
                return function ()
                    for _, record in pairs(subset) do
                        if predicate(record) then
                            return true
                        end
                    end

                    return false
                end
            end
        end,
    }
end