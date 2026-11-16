--!nocheck
-- Quality gate: `lune run check`. Runs each step in order and stops at the first failure.
-- Excluded from luau-lsp analysis because it needs the Lune type definitions (@lune/*),
-- which are not part of the Roblox definitions used by the gate. It is still
-- formatted by StyLua and linted by Selene.

local fs = require("@lune/fs")
local net = require("@lune/net")
local process = require("@lune/process")

-- Keep in step with luau-lsp in rokit.toml.
local LUAU_LSP_VERSION = "1.70.1"
local GLOBAL_TYPES_URL =
	`https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/{LUAU_LSP_VERSION}/scripts/globalTypes.d.luau`
local GLOBAL_TYPES_PATH = ".cache/globalTypes.d.luau"
local SOURCEMAP_PATH = "sourcemap.json"
local BUILD_PATH = "build/creature-game.rbxl"

type StepResult = { ok: boolean, output: string }

local function exec(program: string, args: { string }): StepResult
	local result = process.exec(program, args)
	local output = result.stdout .. result.stderr
	if not result.ok then
		output ..= `\n({program} exited with code {result.code})`
	end
	return { ok = result.ok, output = output }
end

local function ensureDir(path: string)
	if not fs.isDir(path) then
		fs.writeDir(path)
	end
end

local function blinkGenerate(): StepResult
	local found = false
	if fs.isDir("src/net") then
		for _, name in fs.readDir("src/net") do
			if string.sub(name, -6) == ".blink" then
				found = true
				-- The config path must come before options; -y accepts the prompt to create output folders.
				local result = exec("blink", { `src/net/{name}`, "-y" })
				if not result.ok then
					return result
				end
			end
		end
	end
	if not found then
		-- Networking arrives with the battle service (master plan phase 1). Until then there is nothing to generate.
		return { ok = true, output = "" }
	end
	return { ok = true, output = "" }
end

local function stylua(): StepResult
	return exec("stylua", { "--check", "src", "tests", "lune" })
end

local function selene(): StepResult
	return exec("selene", { "src", "tests", "lune" })
end

local function ensureGlobalTypes(): StepResult
	if fs.isFile(GLOBAL_TYPES_PATH) then
		return { ok = true, output = "" }
	end
	local response = net.request(GLOBAL_TYPES_URL)
	if not response.ok then
		return {
			ok = false,
			output = `could not fetch {GLOBAL_TYPES_URL}: HTTP {response.statusCode}`,
		}
	end
	ensureDir(".cache")
	fs.writeFile(GLOBAL_TYPES_PATH, response.body)
	return { ok = true, output = "" }
end

local function analyze(): StepResult
	local types = ensureGlobalTypes()
	if not types.ok then
		return types
	end

	if not fs.isDir("Packages") or not fs.isDir("ServerPackages") then
		return {
			ok = false,
			output = "Packages/ or ServerPackages/ missing: run `wally install` first",
		}
	end

	local sourcemap =
		exec("rojo", { "sourcemap", "default.project.json", "--output", SOURCEMAP_PATH })
	if not sourcemap.ok then
		return sourcemap
	end

	-- Rewrites the Wally link files so package types are visible to the analyzer. It is NOT
	-- idempotent (it fails on files it already rewrote), so only run it on freshly installed
	-- links. Rewritten links contain REQUIRED_MODULE; a fresh `wally install` overwrites them.
	if not string.find(fs.readFile("Packages/Trove.lua"), "REQUIRED_MODULE", 1, true) then
		local packageTypes = exec(
			"wally-package-types",
			{ "--sourcemap", SOURCEMAP_PATH, "Packages", "ServerPackages" }
		)
		if not packageTypes.ok then
			return packageTypes
		end
	end

	return exec("luau-lsp", {
		"analyze",
		`--sourcemap={SOURCEMAP_PATH}`,
		`--definitions=@roblox={GLOBAL_TYPES_PATH}`,
		"--ignore=Packages/**",
		"--ignore=ServerPackages/**",
		"src",
		"tests",
	})
end

local function tests(): StepResult
	local output = ""
	local found = false
	for _, name in fs.readDir("tests") do
		if string.sub(name, -10) == ".test.luau" then
			found = true
			local result = exec("lune", { "run", `tests/{string.sub(name, 1, -6)}` })
			output ..= `{name}: {result.output}`
			if not result.ok then
				return { ok = false, output = output }
			end
		end
	end
	if not found then
		return { ok = false, output = "no *.test.luau files found in tests/" }
	end
	return { ok = true, output = output }
end

local function rojoBuild(): StepResult
	ensureDir("build")
	return exec("rojo", { "build", "default.project.json", "--output", BUILD_PATH })
end

local steps: { { name: string, run: () -> StepResult } } = {
	{ name = "Blink generate", run = blinkGenerate },
	{ name = "StyLua --check", run = stylua },
	{ name = "Selene", run = selene },
	{ name = "luau-lsp analyze (strict)", run = analyze },
	{ name = "Lune tests", run = tests },
	{ name = "Rojo build", run = rojoBuild },
}

for _, step in steps do
	local ok, result = pcall(step.run)
	if not ok then
		result = { ok = false, output = tostring(result) }
	end
	if result.ok then
		print(`PASS  {step.name}`)
	else
		print(`FAIL  {step.name}`)
		print(result.output)
		process.exit(1)
	end
end

print("All checks passed")
