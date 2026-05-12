package misc;

typedef AssetLibraryManifest = {
	var packs : Array<AssetLibraryPack>;
}

typedef AssetLibraryPack = {
	var name : String;
	var path : String;
	var thumb : String;
	var summary : String;
	var files : Int;
	var kind : String;
	var ?author : String;
	var ?license : String;
	var ?suggestedUse : String;
}

typedef AssetLibraryPreviewFile = {
	var name : String;
	var relPath : String;
	var absPath : String;
	var extension : String;
	var kind : String;
}

typedef AssetLibraryStarterSample = {
	var name : String;
	var relPath : String;
	var absPath : String;
}

typedef AssetLibraryStarterEntry = {
	var pack : AssetLibraryPack;
	var starter : AssetLibraryStarterSample;
	var category : String;
	var searchText : String;
}

class AssetLibrary {
	static var packExtCache = new Map<String,Array<String>>();
	static var packPreviewCache = new Map<String,Array<AssetLibraryPreviewFile>>();
	static var packStarterCache = new Map<String,Array<AssetLibraryStarterSample>>();
	static var blockedRuntimeExtensions = [
		".exe" => true,
		".dll" => true,
		".pdb" => true,
		".so" => true,
		".dylib" => true,
		".msi" => true,
		".bat" => true,
		".cmd" => true,
		".sh" => true,
		".import" => true,
		".md5" => true,
		".stex" => true,
		".ds_store" => true,
		".psd" => true,
		".pck" => true,
		".tscn" => true,
		".gd" => true,
		".cfg" => true,
		".meta" => true,
		".ctex" => true,
		".sample" => true,
		".cs" => true,
		".cache" => true,
		".scn" => true,
		".js" => true,
		".prefab" => true,
		".anim" => true,
		".controller" => true,
		".xml" => true,
		".node" => true,
		".godot" => true,
		".bin" => true,
		".gdshader" => true,
		".tres" => true,
		".unity" => true,
		".assets" => true,
		".config" => true,
		".fontdata" => true,
		".oggvorbisstr" => true,
		".oggstr" => true,
		".ico" => true,
		".ress" => true,
		".res" => true,
		".uid" => true,
		".html" => true,
		".iml" => true,
		".info" => true,
		".mdb" => true,
		".browser" => true,
		".ini" => true,
		".aspx" => true,
	];

	public static function getDir() {
		return JsTools.getSamplesDir()+"/atlas";
	}

	public static function getManifestPath() {
		return getDir()+"/assetLibrary.json";
	}

	public static function getPackAbsPath(pack:AssetLibraryPack) {
		return getDir()+"/"+pack.path;
	}

	public static function getThumbAbsPath(pack:AssetLibraryPack) {
		if( pack.thumb==null || pack.thumb.length==0 )
			return "";
		return getDir()+"/"+pack.thumb;
	}

	public static function isImagePack(pack:AssetLibraryPack) {
		return pack.kind!="Audio";
	}

	public static function isAudioPack(pack:AssetLibraryPack) {
		return pack.kind=="Audio";
	}

	public static function normalizeExtension(ext:String) {
		if( ext==null )
			return "";
		ext = ext.toLowerCase();
		if( ext.length>0 && ext.charAt(0)!="." )
			ext = "."+ext;
		return ext==".ds_store" ? "" : ext;
	}

	public static function isBlockedRuntimeExtension(ext:String) {
		return blockedRuntimeExtensions.exists(normalizeExtension(ext));
	}

	public static function toFileUrl(absPath:String) {
		var p = StringTools.replace(absPath, "\\", "/");
		var parts = p.split("/");
		for(i in 0...parts.length) {
			if( i==0 && parts[i].indexOf(":")>=0 )
				parts[i] = StringTools.replace(parts[i], " ", "%20");
			else
				parts[i] = StringTools.urlEncode(parts[i]);
		}
		return "file:///"+parts.join("/");
	}

	static function warn(context:String, e:Dynamic) {
		trace("[AssetLibrary] "+context+": "+Std.string(e));
	}

	public static function getPackExtensions(pack:AssetLibraryPack) {
		var folder = getPackAbsPath(pack);
		if( packExtCache.exists(folder) )
			return packExtCache.get(folder);

		var found = new Map<String,Bool>();
		var out = [];
		if( NT.fileExists(folder) ) {
			try {
				for(fp in JsTools.findFilesRec(folder)) {
					var ext = normalizeExtension(fp.extension);
					if( ext.length==0 )
						continue;
					if( isBlockedRuntimeExtension(ext) )
						continue;
					if( !found.exists(ext) ) {
						found.set(ext, true);
						out.push(ext);
					}
				}
			}
			catch(e:Dynamic) warn("Failed to scan extensions for "+folder, e);
		}
		out.sort(Reflect.compare);
		packExtCache.set(folder, out);
		return out;
	}

	public static function hasImageFiles(pack:AssetLibraryPack) {
		for(ext in getPackExtensions(pack))
			if( ext==".png" || ext==".jpg" || ext==".jpeg" || ext==".gif" || ext==".webp" )
				return true;
		return false;
	}

	public static function hasAudioFiles(pack:AssetLibraryPack) {
		for(ext in getPackExtensions(pack))
			if( ext==".wav" || ext==".ogg" || ext==".mp3" )
				return true;
		return false;
	}

	public static function isImageExtension(ext:String) {
		return ext==".png" || ext==".jpg" || ext==".jpeg" || ext==".gif" || ext==".webp";
	}

	public static function isAudioExtension(ext:String) {
		return ext==".wav" || ext==".ogg" || ext==".mp3";
	}

	static function getAllPreviewFiles(pack:AssetLibraryPack) : Array<AssetLibraryPreviewFile> {
		if( packPreviewCache.exists(pack.path) )
			return packPreviewCache.get(pack.path);

		var folder = getPackAbsPath(pack);
		if( !NT.fileExists(folder) )
			return [];

		var atlasDir = getDir();
		var out : Array<AssetLibraryPreviewFile> = [];
		try {
			for(fp in JsTools.findFilesRec(folder)) {
				var ext = normalizeExtension(fp.extension);
				if( ext.length==0 || isBlockedRuntimeExtension(ext) )
					continue;
				var kind = isImageExtension(ext) ? "image" : isAudioExtension(ext) ? "audio" : null;
				if( kind==null )
					continue;

				var rel = StringTools.replace(fp.full, "\\", "/");
				var atlas = StringTools.replace(atlasDir, "\\", "/");
				if( StringTools.startsWith(rel, atlas+"/") )
					rel = rel.substr(atlas.length+1);

				out.push({
					name: fp.fileWithExt,
					relPath: rel,
					absPath: fp.full,
					extension: ext,
					kind: kind,
				});
			}
		}
		catch(e:Dynamic) warn("Failed to scan previews for "+folder, e);

		out.sort((a,b)->{
			if( a.kind!=b.kind )
				return a.kind=="image" ? -1 : 1;
			return Reflect.compare(a.relPath, b.relPath);
		});
		packPreviewCache.set(pack.path, out);
		return out;
	}

	static function previewMatches(file:AssetLibraryPreviewFile, query:String) {
		return matchesTokens(file.name+" "+file.relPath+" "+file.extension+" "+file.kind, query);
	}

	public static function getPreviewFiles(pack:AssetLibraryPack, limit=120, query="") : Array<AssetLibraryPreviewFile> {
		var out = [];
		for(file in getAllPreviewFiles(pack)) {
			if( previewMatches(file, query) ) {
				out.push(file);
				if( limit>0 && out.length>=limit )
					break;
			}
		}
		return out;
	}

	public static function getPreviewFileCount(pack:AssetLibraryPack, query="") {
		var count = 0;
		for(file in getAllPreviewFiles(pack))
			if( previewMatches(file, query) )
				count++;
		return count;
	}

	public static function matchesTokens(rawHaystack:String, rawQuery:String) {
		if( rawQuery==null )
			return true;

		var query = StringTools.trim(rawQuery.toLowerCase());
		if( query.length==0 )
			return true;

		var haystack = rawHaystack==null ? "" : rawHaystack.toLowerCase();
		for(token in ~/[\s,;]+/g.split(query)) {
			token = StringTools.trim(token);
			if( token.length==0 )
				continue;
			if( haystack.indexOf(token)<0 )
				return false;
		}
		return true;
	}

	static function sanitizeStarterPath(path:String) {
		var out = new StringBuf();
		var lastWasSep = true;
		for(i in 0...path.length) {
			var c = path.charCodeAt(i);
			var isAlphaNum = c>=48 && c<=57 || c>=65 && c<=90 || c>=97 && c<=122;
			if( isAlphaNum ) {
				out.addChar(c);
				lastWasSep = false;
			}
			else if( !lastWasSep ) {
				out.add("_");
				lastWasSep = true;
			}
		}
		var s = out.toString();
		while( StringTools.endsWith(s, "_") )
			s = s.substr(0, s.length-1);
		return s;
	}

	public static function getStarterSamples(pack:AssetLibraryPack) : Array<AssetLibraryStarterSample> {
		var cacheKey = pack.path;
		if( packStarterCache.exists(cacheKey) )
			return packStarterCache.get(cacheKey);

		var samplesDir = JsTools.getSamplesDir();
		var out : Array<AssetLibraryStarterSample> = [];
		if( !NT.fileExists(samplesDir) || pack.path=="." ) {
			packStarterCache.set(cacheKey, out);
			return out;
		}

		var exact = pack.path=="CuteSCKR_uncut" || pack.path=="CuteSCKR_cut"
			? "Doc_Roshi_CuteSCKR"
			: "Doc_Roshi_Asset_"+sanitizeStarterPath(pack.path);
		var prefix = exact+"_";

		try {
			for(f in NT.readDir(samplesDir)) {
				var fp = dn.FilePath.fromFile(samplesDir+"/"+f);
				if( fp.extension!="ldtk" )
					continue;
				var matches = fp.fileName==exact || StringTools.startsWith(fp.fileName, prefix);
				if( pack.kind=="Audio" && fp.fileName=="Doc_Roshi_Horror_Audio_Demo" )
					matches = true;
				if( !matches )
					continue;

				out.push({
					name: StringTools.replace(fp.fileName, "_", " "),
					relPath: fp.fileWithExt,
					absPath: fp.full,
				});
			}
		}
		catch(e:Dynamic) warn("Failed to scan starter samples for "+pack.path, e);

		out.sort((a,b)->Reflect.compare(a.name, b.name));
		packStarterCache.set(cacheKey, out);
		return out;
	}

	public static function getStarterCategory(pack:AssetLibraryPack, starter:AssetLibraryStarterSample) {
		var s = (pack.name+" "+pack.path+" "+starter.name+" "+starter.relPath+" "+pack.kind+" "+pack.suggestedUse).toLowerCase();
		if( pack.path=="CuteSCKR_uncut" || pack.path=="CuteSCKR_cut" || s.indexOf("cutesckr")>=0 )
			return "cutesckr";
		if( s.indexOf("audio")>=0 || s.indexOf("sound")>=0 || s.indexOf("sfx")>=0 || s.indexOf("horror")>=0 )
			return "horror";
		if( s.indexOf("platform")>=0 || s.indexOf("grotto")>=0 || s.indexOf("dungeon")>=0 || s.indexOf("side")>=0 )
			return "platformer";
		if( s.indexOf("rpg")>=0 || s.indexOf("room")>=0 || s.indexOf("interior")>=0 || s.indexOf("town")>=0 )
			return "rpg";
		return "topdown";
	}

	public static function getAllStarterEntries() : Array<AssetLibraryStarterEntry> {
		var out : Array<AssetLibraryStarterEntry> = [];
		var seen = new Map<String,Bool>();
		for(pack in getPacks()) {
			for(starter in getStarterSamples(pack)) {
				if( seen.exists(starter.absPath) )
					continue;
				seen.set(starter.absPath, true);
				var category = getStarterCategory(pack, starter);
				out.push({
					pack: pack,
					starter: starter,
					category: category,
					searchText: (starter.name+" "+starter.relPath+" "+pack.name+" "+pack.path+" "+pack.kind+" "+pack.summary+" "+pack.suggestedUse+" "+category).toLowerCase(),
				});
			}
		}
		out.sort((a,b)->Reflect.compare(a.starter.name, b.starter.name));
		return out;
	}

	public static function getAtlasRelativePath(absPath:String) {
		if( absPath==null )
			return "";

		var rel = StringTools.replace(absPath, "\\", "/");
		var atlas = StringTools.replace(getDir(), "\\", "/");
		if( StringTools.startsWith(rel, atlas+"/") )
			return rel.substr(atlas.length+1);
		return rel;
	}

	static function makeRelativeToDir(absPath:String, targetDir:String) {
		var fp = dn.FilePath.fromFile(absPath);
		fp.useSlashes();
		fp.makeRelativeTo(targetDir);
		return fp.full;
	}

	static function rewriteStarterAtlasRefs(value:Dynamic, targetDir:String) : Dynamic {
		if( Std.isOfType(value, String) ) {
			var s : String = cast value;
			var clean = StringTools.startsWith(s, "./") ? s.substr(2) : s;
			if( StringTools.startsWith(clean, "atlas/") )
				return makeRelativeToDir(JsTools.getSamplesDir()+"/"+clean, targetDir);
			return value;
		}

		if( Std.isOfType(value, Array) ) {
			var arr : Array<Dynamic> = cast value;
			for(i in 0...arr.length)
				arr[i] = rewriteStarterAtlasRefs(arr[i], targetDir);
			return arr;
		}

		if( Reflect.isObject(value) ) {
			for(field in Reflect.fields(value))
				Reflect.setField(value, field, rewriteStarterAtlasRefs(Reflect.field(value, field), targetDir));
		}
		return value;
	}

	public static function cloneStarterTo(starter:AssetLibraryStarterSample, targetPath:String) {
		var fp = dn.FilePath.fromFile(targetPath);
		fp.extension = Const.FILE_EXTENSION;
		var json = haxe.Json.parse(NT.readFileString(starter.absPath));
		rewriteStarterAtlasRefs(json, fp.directory);
		NT.writeFileString(fp.full, dn.data.JsonPretty.stringify(json, Full));
		return fp.full;
	}

	public static function getExtensionLabel(pack:AssetLibraryPack, limit=5) {
		var exts = getPackExtensions(pack);
		if( exts.length==0 )
			return "mixed files";

		var shown = exts.slice(0, limit);
		var label = shown.join(", ");
		if( exts.length>shown.length )
			label += " +" + (exts.length-shown.length);
		return label;
	}

	public static function getPackSubtitle(pack:AssetLibraryPack) {
		var bits = [ pack.kind, pack.files+" files" ];
		var exts = getExtensionLabel(pack);
		if( exts.length>0 )
			bits.push(exts);
		return bits.join(" - ");
	}

	public static function getSearchText(pack:AssetLibraryPack) {
		return (pack.name+" "+pack.kind+" "+pack.summary+" "+pack.suggestedUse+" "+pack.author+" "+pack.license+" "+getExtensionLabel(pack, 20)).toLowerCase();
	}

	public static function getMatchingPackExtensions(pack:AssetLibraryPack, acceptFileTypes:Null<Array<String>>) {
		var all = getPackExtensions(pack);
		if( acceptFileTypes==null || acceptFileTypes.length==0 )
			return all;

		var accepted = new Map<String,Bool>();
		for(rawExt in acceptFileTypes) {
			var ext = rawExt.toLowerCase();
			if( ext.length>0 && ext.charAt(0)!="." )
				ext = "."+ext;
			accepted.set(ext, true);
		}

		return all.filter( ext->accepted.exists(ext) );
	}

	public static function matchesAcceptedFileTypes(pack:AssetLibraryPack, acceptFileTypes:Null<Array<String>>) {
		if( acceptFileTypes==null || acceptFileTypes.length==0 )
			return true;

		return getMatchingPackExtensions(pack, acceptFileTypes).length>0;
	}

	public static function getPacks() : Array<AssetLibraryPack> {
		var manifestPath = getManifestPath();
		if( !NT.fileExists(manifestPath) )
			return [];

		var manifest : AssetLibraryManifest = try {
			haxe.Json.parse( NT.readFileString(manifestPath) );
		} catch(e:Dynamic) {
			warn("Failed to parse asset manifest "+manifestPath, e);
			null;
		}

		return manifest==null || manifest.packs==null ? [] : manifest.packs;
	}
}
