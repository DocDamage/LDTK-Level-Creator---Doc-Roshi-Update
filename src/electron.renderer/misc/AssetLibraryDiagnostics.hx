package misc;

import misc.AssetLibrary.AssetLibraryPack;
import misc.AssetLibrary.AssetLibraryStarterSample;

typedef AssetLibraryTemplateReference = {
	var rawPath : String;
	var absPath : String;
	var kind : String;
	var missing : Bool;
}

typedef AssetLibraryTemplateSummary = {
	var refs : Array<AssetLibraryTemplateReference>;
	var imageCount : Int;
	var audioCount : Int;
	var otherCount : Int;
	var missingCount : Int;
}

typedef AssetLibraryPackHealth = {
	var pack : AssetLibraryPack;
	var missingFolder : Bool;
	var missingThumb : Bool;
	var previewCount : Int;
	var starterCount : Int;
	var blockedExtCount : Int;
	var largeFileCount : Int;
	var issues : Array<String>;
}

typedef AssetLibraryHealthReport = {
	var packs : Array<AssetLibraryPackHealth>;
	var packCount : Int;
	var issueCount : Int;
	var missingFolderCount : Int;
	var missingThumbCount : Int;
	var noPreviewCount : Int;
	var noStarterCount : Int;
	var blockedExtCount : Int;
	var largeFileCount : Int;
	var missingTemplateRefCount : Int;
}

class AssetLibraryDiagnostics {
	static inline var LARGE_FILE_BYTES = 16 * 1024 * 1024;

	static function normalizePath(path:String) {
		if( path==null )
			return "";
		return StringTools.replace(path, "\\", "/");
	}

	static function referenceKind(path:String) {
		var ext = AssetLibrary.normalizeExtension(dn.FilePath.fromFile(path).extension);
		if( AssetLibrary.isImageExtension(ext) )
			return "image";
		if( AssetLibrary.isAudioExtension(ext) )
			return "audio";
		return "other";
	}

	static function addReference(raw:String, refs:Array<AssetLibraryTemplateReference>, seen:Map<String,Bool>) {
		var s = normalizePath(raw);
		var idx = s.indexOf("atlas/");
		if( idx<0 )
			return;

		var rel = s.substr(idx);
		if( seen.exists(rel) )
			return;
		seen.set(rel, true);

		var abs = JsTools.getSamplesDir()+"/"+rel;
		refs.push({
			rawPath: rel,
			absPath: abs,
			kind: referenceKind(rel),
			missing: !NT.fileExists(abs),
		});
	}

	static function crawlReferences(value:Dynamic, refs:Array<AssetLibraryTemplateReference>, seen:Map<String,Bool>) {
		if( Std.isOfType(value, String) ) {
			addReference(cast value, refs, seen);
			return;
		}

		if( Std.isOfType(value, Array) ) {
			for(v in (cast value:Array<Dynamic>))
				crawlReferences(v, refs, seen);
			return;
		}

		if( Reflect.isObject(value) )
			for(field in Reflect.fields(value))
				crawlReferences(Reflect.field(value, field), refs, seen);
	}

	public static function getStarterSummary(starter:AssetLibraryStarterSample) : AssetLibraryTemplateSummary {
		var refs : Array<AssetLibraryTemplateReference> = [];
		var seen = new Map<String,Bool>();
		try {
			var json = haxe.Json.parse(NT.readFileString(starter.absPath));
			crawlReferences(json, refs, seen);
		}
		catch(e:Dynamic) {
			App.LOG.warning("Failed to inspect template dependencies "+starter.absPath+": "+Std.string(e));
		}

		var images = 0;
		var audio = 0;
		var other = 0;
		var missing = 0;
		for(ref in refs) {
			switch ref.kind {
				case "image": images++;
				case "audio": audio++;
				case _: other++;
			}
			if( ref.missing )
				missing++;
		}

		return {
			refs: refs,
			imageCount: images,
			audioCount: audio,
			otherCount: other,
			missingCount: missing,
		}
	}

	public static function writeCloneManifest(source:AssetLibraryStarterSample, targetProjectPath:String) {
		var summary = getStarterSummary(source);
		var out = {
			sourceTemplate: source.absPath,
			sourceTemplateName: source.name,
			createdProject: targetProjectPath,
			createdAt: Date.now().toString(),
			references: summary.refs.map((ref)->{
				return {
					path: ref.rawPath,
					kind: ref.kind,
					missing: ref.missing,
				}
			}),
		}
		NT.writeFileString(targetProjectPath+".asset-manifest.json", dn.data.JsonPretty.stringify(out, Full));
	}

	static function fileSize(path:String) : Float {
		return try {
			var stat : Dynamic = js.node.Fs.statSync(path);
			stat.size;
		}
		catch(e:Dynamic) 0;
	}

	public static function getPackHealth(pack:AssetLibraryPack) : AssetLibraryPackHealth {
		var folder = AssetLibrary.getPackAbsPath(pack);
		var thumb = AssetLibrary.getThumbAbsPath(pack);
		var missingFolder = !NT.fileExists(folder);
		var missingThumb = pack.thumb!=null && pack.thumb.length>0 && !NT.fileExists(thumb);
		var blockedExtCount = 0;
		var largeFileCount = 0;
		var issues = [];

		if( missingFolder )
			issues.push("Missing pack folder");
		if( missingThumb )
			issues.push("Missing thumbnail");

		if( !missingFolder ) {
			try {
				for(fp in JsTools.findFilesRec(folder)) {
					var ext = AssetLibrary.normalizeExtension(fp.extension);
					if( ext.length>0 && AssetLibrary.isBlockedRuntimeExtension(ext) )
						blockedExtCount++;
					if( fileSize(fp.full)>LARGE_FILE_BYTES )
						largeFileCount++;
				}
			}
			catch(e:Dynamic) {
				issues.push("Scan failed");
				App.LOG.warning("Failed to scan asset health for "+folder+": "+Std.string(e));
			}
		}

		var previewCount = AssetLibrary.getPreviewFileCount(pack);
		var starterCount = AssetLibrary.getStarterSamples(pack).length;
		if( previewCount==0 )
			issues.push("No previewable image/audio files");
		if( starterCount==0 )
			issues.push("No starter template");
		if( blockedExtCount>0 )
			issues.push(blockedExtCount+" blocked/source-drop files");
		if( largeFileCount>0 )
			issues.push(largeFileCount+" files over 16 MiB");

		return {
			pack: pack,
			missingFolder: missingFolder,
			missingThumb: missingThumb,
			previewCount: previewCount,
			starterCount: starterCount,
			blockedExtCount: blockedExtCount,
			largeFileCount: largeFileCount,
			issues: issues,
		}
	}

	public static function getHealthReport() : AssetLibraryHealthReport {
		var out : Array<AssetLibraryPackHealth> = [];
		var issueCount = 0;
		var missingFolderCount = 0;
		var missingThumbCount = 0;
		var noPreviewCount = 0;
		var noStarterCount = 0;
		var blockedExtCount = 0;
		var largeFileCount = 0;
		var missingTemplateRefCount = 0;

		for(pack in AssetLibrary.getPacks()) {
			var health = getPackHealth(pack);
			out.push(health);
			issueCount += health.issues.length;
			if( health.missingFolder ) missingFolderCount++;
			if( health.missingThumb ) missingThumbCount++;
			if( health.previewCount==0 ) noPreviewCount++;
			if( health.starterCount==0 ) noStarterCount++;
			blockedExtCount += health.blockedExtCount;
			largeFileCount += health.largeFileCount;
			for(starter in AssetLibrary.getStarterSamples(pack))
				missingTemplateRefCount += getStarterSummary(starter).missingCount;
		}

		out.sort((a,b)->{
			if( a.issues.length!=b.issues.length )
				return Reflect.compare(b.issues.length, a.issues.length);
			return Reflect.compare(a.pack.name, b.pack.name);
		});

		return {
			packs: out,
			packCount: out.length,
			issueCount: issueCount + missingTemplateRefCount,
			missingFolderCount: missingFolderCount,
			missingThumbCount: missingThumbCount,
			noPreviewCount: noPreviewCount,
			noStarterCount: noStarterCount,
			blockedExtCount: blockedExtCount,
			largeFileCount: largeFileCount,
			missingTemplateRefCount: missingTemplateRefCount,
		}
	}
}
