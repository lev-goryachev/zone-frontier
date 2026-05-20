const fs = require("fs");
const path = require("path");
const { lua, lauxlib, lualib, to_luastring, to_jsstring } = require("fengari");

const root = path.resolve(__dirname, "..");
const srcPath = path.join(root, "src").replace(/\\/g, "/");
const testsPath = path.join(root, "tests").replace(/\\/g, "/");

function luaString(value) {
  return to_luastring(value);
}

function runLuaFile(L, filePath) {
  const status = lauxlib.luaL_loadfile(L, luaString(filePath));
  if (status !== lua.LUA_OK) {
    const message = to_jsstring(lua.lua_tostring(L, -1));
    lua.lua_pop(L, 1);
    throw new Error(message);
  }

  const callStatus = lua.lua_pcall(L, 0, lua.LUA_MULTRET, 0);
  if (callStatus !== lua.LUA_OK) {
    const message = to_jsstring(lua.lua_tostring(L, -1));
    lua.lua_pop(L, 1);
    throw new Error(message);
  }
}

function runTest(testFile) {
  const L = lauxlib.luaL_newstate();
  lualib.luaL_openlibs(L);

  const prelude = [
    `package.path = "${srcPath}/?.lua;${testsPath}/?.lua;" .. package.path`,
  ].join("\n");

  if (lauxlib.luaL_dostring(L, luaString(prelude)) !== lua.LUA_OK) {
    const message = to_jsstring(lua.lua_tostring(L, -1));
    lua.lua_pop(L, 1);
    throw new Error(message);
  }

  runLuaFile(L, testFile.replace(/\\/g, "/"));
}

const tests = fs
  .readdirSync(path.join(root, "tests"))
  .filter((name) => /^test_.*\.lua$/.test(name) && name !== "test_helpers.lua")
  .sort()
  .map((name) => path.join(root, "tests", name));

let failures = 0;

for (const test of tests) {
  const label = path.relative(root, test);
  try {
    runTest(test);
    console.log(`PASS ${label}`);
  } catch (error) {
    failures += 1;
    console.error(`FAIL ${label}`);
    console.error(error.message);
  }
}

if (failures > 0) {
  process.exitCode = 1;
} else {
  console.log(`PASS ${tests.length} Lua tests`);
}

