#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const errors = [];

const blockedAtlasExtensions = [".exe", ".dll", ".pdb", ".so", ".dylib", ".msi", ".bat", ".cmd", ".sh"];

function rel(filePath) {
	return path.relative(root, filePath).replace(/\\/g, "/");
}

function fail(message) {
	errors.push(message);
}

function readJson(filePath) {
	try {
		return JSON.parse(fs.readFileSync(filePath, "utf8"));
	}
	catch (error) {
		fail(`${rel(filePath)}: ${error.message}`);
		return null;
	}
}

function isPinnedVersion(version) {
	return typeof version === "string" && /^[0-9]+\.[0-9]+\.[0-9]+(?:[-+][0-9A-Za-z.-]+)?$/.test(version);
}

function validatePackageVersions() {
	const packagePath = path.join(root, "app", "package.json");
	const pkg = readJson(packagePath);
	if (!pkg)
		return;

	for (const sectionName of ["dependencies", "devDependencies"]) {
		const section = pkg[sectionName] || {};
		for (const [name, version] of Object.entries(section)) {
			if (!isPinnedVersion(version))
				fail(`${rel(packagePath)}: ${sectionName}.${name} should be pinned to an exact version, found "${version}"`);
		}
	}
}

function validateElectronBuilderFilters() {
	const configPath = path.join(root, "app", "electron-builder.json");
	const config = readJson(configPath);
	if (!config)
		return;

	const samplesEntry = (config.extraFiles || []).find((entry) => entry && typeof entry === "object" && entry.from === "extraFiles/samples");
	if (!samplesEntry) {
		fail(`${rel(configPath)}: extraFiles must use an object entry for extraFiles/samples so raw runtime files can be filtered`);
		return;
	}

	const filters = samplesEntry.filter || [];
	for (const ext of blockedAtlasExtensions) {
		const pattern = `!atlas/**/*${ext}`;
		if (!filters.includes(pattern))
			fail(`${rel(configPath)}: missing samples filter ${pattern}`);
	}
}

function validateWorkflowVersions() {
	const workflowDir = path.join(root, ".github", "workflows");
	if (!fs.existsSync(workflowDir))
		return;

	for (const fileName of fs.readdirSync(workflowDir)) {
		if (!fileName.endsWith(".yml") && !fileName.endsWith(".yaml"))
			continue;

		const filePath = path.join(workflowDir, fileName);
		const text = fs.readFileSync(filePath, "utf8");
		for (const stale of ["actions/checkout@v2", "actions/setup-node@v1", "actions/upload-artifact@v2", "node-version: '14'", 'node-version: "14"']) {
			if (text.includes(stale))
				fail(`${rel(filePath)}: stale workflow dependency "${stale}"`);
		}
	}
}

function main() {
	validatePackageVersions();
	validateElectronBuilderFilters();
	validateWorkflowVersions();

	if (errors.length > 0) {
		console.error(`Release config validation failed with ${errors.length} issue(s):`);
		for (const error of errors)
			console.error(` - ${error}`);
		process.exit(1);
	}

	console.log("Release config validation passed.");
}

main();
