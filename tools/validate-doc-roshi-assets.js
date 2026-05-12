#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const childProcess = require("child_process");

const root = path.resolve(__dirname, "..");
const samplesDir = path.join(root, "app", "extraFiles", "samples");
const atlasDir = path.join(samplesDir, "atlas");
const manifestPath = path.join(atlasDir, "assetLibrary.json");

const EXPECTED_ASSET_STARTERS = 151;
const EXPECTED_CUTESCKR_STARTERS = 78;
const EXPECTED_DOC_ROSHI_STARTERS = 233;
const BLOCKED_TRACKED_ATLAS_EXTENSIONS = new Set([".exe", ".dll", ".pdb", ".so", ".dylib", ".msi", ".bat", ".cmd", ".sh"]);

const errors = [];

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

function exists(filePath) {
	return fs.existsSync(filePath);
}

function resolveFrom(baseDir, relPath) {
	return path.join(baseDir, relPath.replace(/\//g, path.sep));
}

function listSamples(prefix) {
	return fs.readdirSync(samplesDir)
		.filter((name) => name.startsWith(prefix) && name.endsWith(".ldtk"))
		.sort();
}

function listTrackedAtlasFiles() {
	try {
		const output = childProcess.execFileSync("git", ["ls-files", "app/extraFiles/samples/atlas"], {
			cwd: root,
			encoding: "utf8",
			stdio: ["ignore", "pipe", "ignore"],
		});
		return output.split(/\r?\n/).filter(Boolean);
	}
	catch (_) {
		return [];
	}
}

function sanitizeStarterPath(packPath) {
	let out = "";
	let lastWasSep = true;

	for (const char of packPath) {
		if (/^[0-9A-Za-z]$/.test(char)) {
			out += char;
			lastWasSep = false;
		}
		else if (!lastWasSep) {
			out += "_";
			lastWasSep = true;
		}
	}

	return out.replace(/_+$/g, "");
}

function starterMatchesPack(fileNameNoExt, pack) {
	if (pack.path === ".")
		return false;

	const exact = pack.path === "CuteSCKR_uncut"
		? "Doc_Roshi_CuteSCKR"
		: `Doc_Roshi_Asset_${sanitizeStarterPath(pack.path)}`;

	if (fileNameNoExt === exact || fileNameNoExt.startsWith(`${exact}_`))
		return true;

	return pack.kind === "Audio" && fileNameNoExt === "Doc_Roshi_Horror_Audio_Demo";
}

function fieldValue(level, identifier) {
	const field = (level.fieldInstances || []).find((instance) => instance.__identifier === identifier);
	return field ? field.__value : undefined;
}

function layerDef(project, identifier) {
	return ((project.defs || {}).layers || []).find((layer) => layer.identifier === identifier);
}

function tilesetDef(project, identifier) {
	return ((project.defs || {}).tilesets || []).find((tileset) => tileset.identifier === identifier);
}

function layerInstance(level, identifier) {
	return (level.layerInstances || []).find((layer) => layer.__identifier === identifier);
}

function entityDef(project, identifier) {
	return ((project.defs || {}).entities || []).find((entity) => entity.identifier === identifier);
}

function validateManifest() {
	const manifest = readJson(manifestPath);
	if (!manifest)
		return null;

	if (!Array.isArray(manifest.packs)) {
		fail(`${rel(manifestPath)}: expected packs array`);
		return null;
	}

	for (const pack of manifest.packs) {
		if (!pack.name || !pack.path || !pack.kind)
			fail(`${rel(manifestPath)}: pack is missing name, path, or kind`);

		const packPath = resolveFrom(atlasDir, pack.path);
		if (!exists(packPath))
			fail(`${rel(manifestPath)}: pack path does not exist: ${pack.path}`);

		if (pack.thumb) {
			const thumbPath = resolveFrom(atlasDir, pack.thumb);
			if (!exists(thumbPath))
				fail(`${rel(manifestPath)}: thumbnail does not exist: ${pack.thumb}`);
		}
	}

	return manifest;
}

function validateTrackedAtlasFiles() {
	for (const fileName of listTrackedAtlasFiles()) {
		const ext = path.extname(fileName).toLowerCase();
		if (BLOCKED_TRACKED_ATLAS_EXTENSIONS.has(ext))
			fail(`Tracked atlas file should stay ignored as raw runtime output: ${fileName}`);
	}
}

function validateStarterCounts(allDocRoshi, assetStarters, cuteSckrStarters) {
	if (assetStarters.length !== EXPECTED_ASSET_STARTERS)
		fail(`Expected ${EXPECTED_ASSET_STARTERS} Doc_Roshi_Asset starters, found ${assetStarters.length}`);

	if (cuteSckrStarters.length !== EXPECTED_CUTESCKR_STARTERS)
		fail(`Expected ${EXPECTED_CUTESCKR_STARTERS} Doc_Roshi_CuteSCKR starters, found ${cuteSckrStarters.length}`);

	if (allDocRoshi.length !== EXPECTED_DOC_ROSHI_STARTERS)
		fail(`Expected ${EXPECTED_DOC_ROSHI_STARTERS} Doc_Roshi starters, found ${allDocRoshi.length}`);
}

function validateStarterLinks(manifest, allDocRoshi) {
	if (!manifest)
		return;

	const fileNames = allDocRoshi.map((fileName) => path.basename(fileName, ".ldtk"));

	for (const pack of manifest.packs) {
		const matches = fileNames.filter((fileName) => starterMatchesPack(fileName, pack));
		if (pack.path === ".") {
			if (matches.length !== 0)
				fail(`Classic sample pack should not link Doc Roshi starters, found ${matches.length}`);
			continue;
		}

		if (matches.length === 0)
			fail(`Asset pack "${pack.name}" (${pack.path}) has no linked starter samples`);
	}
}

function validateCommonStarter(fileName) {
	const filePath = path.join(samplesDir, fileName);
	const project = readJson(filePath);
	if (!project)
		return null;

	if (!project.__header__ || project.__header__.fileType !== "LDtk Project JSON")
		fail(`${fileName}: missing LDtk project header`);

	if (!project.defs)
		fail(`${fileName}: missing defs`);

	if (!Array.isArray(project.levels) || project.levels.length === 0) {
		fail(`${fileName}: missing levels`);
		return project;
	}

	const level = project.levels[0];
	if (!Array.isArray(level.layerInstances))
		fail(`${fileName}: first level is missing layerInstances`);

	const brief = fieldValue(level, "StarterBrief");
	if (brief === undefined || brief === null || brief === "")
		fail(`${fileName}: missing level field StarterBrief`);

	const layout = layerInstance(level, "Layout");
	if (layout) {
		const expectedCells = layout.__cWid * layout.__cHei;
		if (!Array.isArray(layout.intGridCsv) || layout.intGridCsv.length !== expectedCells)
			fail(`${fileName}: Layout intGridCsv has ${layout.intGridCsv ? layout.intGridCsv.length : 0} cells, expected ${expectedCells}`);
	}

	const markers = layerInstance(level, "StarterMarkers");
	if (!markers)
		fail(`${fileName}: missing StarterMarkers layer instance`);
	else if (!Array.isArray(markers.entityInstances) || markers.entityInstances.length === 0)
		fail(`${fileName}: StarterMarkers has no entity instances`);

	return project;
}

function validateAssetStarter(fileName) {
	const project = validateCommonStarter(fileName);
	if (!project || !Array.isArray(project.levels) || project.levels.length === 0)
		return;

	const level = project.levels[0];
	const featuredTilesLayerDef = layerDef(project, "FeaturedTiles");
	const featuredTilesLayer = layerInstance(level, "FeaturedTiles");
	const featuredTileset = tilesetDef(project, "FeaturedAssetTiles");

	for (const id of ["FeaturedAsset", "SourceFolder", "AssetPackKind", "RecommendedUse"]) {
		const value = fieldValue(level, id);
		if (value === undefined || value === null || value === "")
			fail(`${fileName}: missing level field ${id}`);
	}

	const featuredAsset = fieldValue(level, "FeaturedAsset");
	if (typeof featuredAsset === "string" && featuredAsset.length > 0) {
		const featuredPath = resolveFrom(samplesDir, featuredAsset);
		if (!exists(featuredPath))
			fail(`${fileName}: FeaturedAsset path does not exist: ${featuredAsset}`);
	}

	if (!featuredTilesLayerDef)
		fail(`${fileName}: missing FeaturedTiles layer definition`);
	if (!featuredTilesLayer)
		fail(`${fileName}: missing FeaturedTiles layer instance`);
	if (!featuredTileset)
		fail(`${fileName}: missing FeaturedAssetTiles tileset`);

	if (!featuredTilesLayer || !featuredTileset)
		return;

	const markers = layerInstance(level, "StarterMarkers");
	if (markers && Array.isArray(markers.entityInstances)) {
		for (const marker of markers.entityInstances) {
			const def = ((project.defs || {}).entities || []).find((entity) => entity.uid === marker.defUid);
			const defHasNote = def && (def.fieldDefs || []).some((field) => field.identifier === "MarkerNote");
			const markerNote = (marker.fieldInstances || []).find((field) => field.__identifier === "MarkerNote");

			if (!defHasNote)
				fail(`${fileName}: marker entity ${marker.__identifier} is missing MarkerNote definition`);
			if (!markerNote || !markerNote.__value)
				fail(`${fileName}: marker entity ${marker.__identifier} is missing MarkerNote value`);
		}
	}

	const tiles = featuredTilesLayer.gridTiles || [];
	if (tiles.length === 0)
		fail(`${fileName}: FeaturedTiles has no grid tiles`);

	for (const tile of tiles) {
		if (!Array.isArray(tile.src) || tile.src.length !== 2) {
			fail(`${fileName}: FeaturedTiles contains a tile without src coordinates`);
			continue;
		}

		const tileSize = featuredTileset.tileGridSize || featuredTilesLayer.__gridSize || 16;
		if (tile.src[0] < 0 || tile.src[1] < 0 || tile.src[0] + tileSize > featuredTileset.pxWid || tile.src[1] + tileSize > featuredTileset.pxHei)
			fail(`${fileName}: tile source ${tile.src.join(",")} is outside FeaturedAssetTiles bounds`);
	}
}

function validateCuteSckrStarter(fileName) {
	const project = validateCommonStarter(fileName);
	if (!project || !Array.isArray(project.levels) || project.levels.length === 0)
		return;

	const level = project.levels[0];
	const featuredTileset = fieldValue(level, "FeaturedTileset");
	if (typeof featuredTileset !== "string" || featuredTileset.length === 0) {
		fail(`${fileName}: missing level field FeaturedTileset`);
		return;
	}

	const featuredPath = resolveFrom(samplesDir, featuredTileset);
	if (!exists(featuredPath))
		fail(`${fileName}: FeaturedTileset path does not exist: ${featuredTileset}`);

	if (level.bgRelPath !== featuredTileset)
		fail(`${fileName}: bgRelPath does not match FeaturedTileset`);
}

function main() {
	if (!exists(samplesDir))
		fail(`Samples directory does not exist: ${rel(samplesDir)}`);
	if (!exists(atlasDir))
		fail(`Atlas directory does not exist: ${rel(atlasDir)}`);

	const manifest = validateManifest();
	validateTrackedAtlasFiles();
	const allDocRoshi = listSamples("Doc_Roshi_");
	const assetStarters = listSamples("Doc_Roshi_Asset_");
	const cuteSckrStarters = listSamples("Doc_Roshi_CuteSCKR_");

	validateStarterCounts(allDocRoshi, assetStarters, cuteSckrStarters);
	validateStarterLinks(manifest, allDocRoshi);

	for (const fileName of allDocRoshi)
		readJson(path.join(samplesDir, fileName));

	for (const fileName of assetStarters)
		validateAssetStarter(fileName);

	for (const fileName of cuteSckrStarters)
		validateCuteSckrStarter(fileName);

	if (errors.length > 0) {
		console.error(`Doc Roshi asset validation failed with ${errors.length} issue(s):`);
		for (const error of errors)
			console.error(` - ${error}`);
		process.exit(1);
	}

	console.log(`Doc Roshi asset validation passed: ${allDocRoshi.length} starters, ${assetStarters.length} asset starters, ${cuteSckrStarters.length} CuteSCKR starters.`);
}

main();
