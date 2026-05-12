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

class AssetLibrary {
	static var packExtCache = new Map<String,Array<String>>();
	static var packStarterCache = new Map<String,Array<AssetLibraryStarterSample>>();

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
		return getDir()+"/"+pack.thumb;
	}

	public static function isImagePack(pack:AssetLibraryPack) {
		return pack.kind!="Audio";
	}

	public static function isAudioPack(pack:AssetLibraryPack) {
		return pack.kind=="Audio";
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
					var ext = fp.extension.toLowerCase();
					if( ext.length==0 )
						continue;
					if( ext.charAt(0)!="." )
						ext = "."+ext;
					if( ext==".ds_store" )
						continue;
					if( !found.exists(ext) ) {
						found.set(ext, true);
						out.push(ext);
					}
				}
			}
			catch(_) {}
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

	public static function getPreviewFiles(pack:AssetLibraryPack, limit=120) : Array<AssetLibraryPreviewFile> {
		var folder = getPackAbsPath(pack);
		if( !NT.fileExists(folder) )
			return [];

		var atlasDir = getDir();
		var out : Array<AssetLibraryPreviewFile> = [];
		try {
			for(fp in JsTools.findFilesRec(folder)) {
				var ext = fp.extension.toLowerCase();
				if( ext.length>0 && ext.charAt(0)!="." )
					ext = "."+ext;
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
		catch(_) {}

		out.sort((a,b)->{
			if( a.kind!=b.kind )
				return a.kind=="image" ? -1 : 1;
			return Reflect.compare(a.relPath, b.relPath);
		});
		return out.length>limit ? out.slice(0, limit) : out;
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

		var exact = pack.path=="CuteSCKR_uncut"
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
		catch(_) {}

		out.sort((a,b)->Reflect.compare(a.name, b.name));
		packStarterCache.set(cacheKey, out);
		return out;
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
		} catch(_) null;

		return manifest==null || manifest.packs==null ? [] : manifest.packs;
	}
}
