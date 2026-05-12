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

class AssetLibrary {
	static var packExtCache = new Map<String,Array<String>>();

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
