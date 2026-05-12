#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const errors = [];

const blockedAtlasExtensions = [
	".exe", ".dll", ".pdb", ".so", ".dylib", ".msi", ".bat", ".cmd", ".sh",
	".import", ".md5", ".stex", ".DS_Store", ".ds_store", ".psd", ".pck", ".tscn",
	".gd", ".cfg", ".meta", ".ctex", ".sample", ".cs",
];
const licenseManifestPath = path.join(root, "docs", "asset_license_manifest.json");

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

	const lockPath = path.join(root, "app", "package-lock.json");
	const lock = readJson(lockPath);
	if (!lock)
		return;

	const rootLock = lock.packages && lock.packages[""];
	if (!rootLock) {
		fail(`${rel(lockPath)}: missing root package entry`);
		return;
	}

	for (const sectionName of ["dependencies", "devDependencies"]) {
		const packageDeps = pkg[sectionName] || {};
		const lockDeps = rootLock[sectionName] || {};
		for (const [name, version] of Object.entries(packageDeps)) {
			if (lockDeps[name] !== version)
				fail(`${rel(lockPath)}: ${sectionName}.${name} is "${lockDeps[name]}", expected "${version}" from package.json`);
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
		for (const stale of ["actions/checkout@v2", "actions/setup-node@v1", "actions/upload-artifact@v2", "node-version: '14'", 'node-version: "14"', "::set-output"]) {
			if (text.includes(stale))
				fail(`${rel(filePath)}: stale workflow dependency "${stale}"`);
		}
	}
}

function validateAssetLicenseManifest() {
	const assetManifest = readJson(path.join(root, "app", "extraFiles", "samples", "atlas", "assetLibrary.json"));
	const licenseManifest = readJson(licenseManifestPath);
	if (!assetManifest || !licenseManifest)
		return;

	if (!Array.isArray(licenseManifest.packs)) {
		fail(`${rel(licenseManifestPath)}: expected packs array`);
		return;
	}

	const entries = new Map();
	for (const entry of licenseManifest.packs) {
		if (!entry.path)
			fail(`${rel(licenseManifestPath)}: license entry is missing path`);
		else
			entries.set(entry.path, entry);

		for (const field of ["name", "author", "licenseSummary", "redistributionStatus", "attribution", "source"]) {
			if (!entry[field] || typeof entry[field] !== "string" || entry[field].trim().length === 0)
				fail(`${rel(licenseManifestPath)}: ${entry.path || "(missing path)"} is missing ${field}`);
		}
	}

	for (const pack of assetManifest.packs || []) {
		if (!entries.has(pack.path))
			fail(`${rel(licenseManifestPath)}: missing license entry for asset pack path "${pack.path}"`);
	}
}

function main() {
	validatePackageVersions();
	validateElectronBuilderFilters();
	validateWorkflowVersions();
	validateAssetLicenseManifest();

	if (errors.length > 0) {
		console.error(`Release config validation failed with ${errors.length} issue(s):`);
		for (const error of errors)
			console.error(` - ${error}`);
		process.exit(1);
	}

	console.log("Release config validation passed.");
}

main();
