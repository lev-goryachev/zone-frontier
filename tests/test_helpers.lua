local M = {}

function M.assert_eq(actual, expected, message)
    if actual ~= expected then
        error((message or "assert_eq failed") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual), 2)
    end
end

function M.assert_true(value, message)
    if not value then
        error(message or "assert_true failed", 2)
    end
end

function M.assert_near(actual, expected, tolerance, message)
    if math.abs(actual - expected) > tolerance then
        error((message or "assert_near failed") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual), 2)
    end
end

return M

