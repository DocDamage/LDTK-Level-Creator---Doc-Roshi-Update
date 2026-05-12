package misc;

class AssetLibraryState {
	static inline var MAX_RECENTS = 24;
	static inline var PACK_FAVORITES = "docRoshi.assetLibrary.favoritePacks";
	static inline var PACK_RECENTS = "docRoshi.assetLibrary.recentPacks";
	static inline var FILE_FAVORITES = "docRoshi.assetLibrary.favoriteFiles";
	static inline var FILE_RECENTS = "docRoshi.assetLibrary.recentFiles";
	static inline var STARTER_RECENTS = "docRoshi.assetLibrary.recentStarters";

	static function readList(key:String) : Array<String> {
		var raw = try js.Browser.window.localStorage.getItem(key) catch(e:Dynamic) null;
		if( raw==null || raw.length==0 )
			return [];

		try {
			var arr : Array<Dynamic> = haxe.Json.parse(raw);
			var out = [];
			for(v in arr) {
				var s = Std.string(v);
				if( s!=null && s.length>0 && out.indexOf(s)<0 )
					out.push(s);
			}
			return out;
		}
		catch(e:Dynamic) {
			App.LOG.warning("Failed to read asset library state "+key+": "+Std.string(e));
			return [];
		}
	}

	static function writeList(key:String, values:Array<String>) {
		try js.Browser.window.localStorage.setItem(key, haxe.Json.stringify(values))
		catch(e:Dynamic) App.LOG.warning("Failed to write asset library state "+key+": "+Std.string(e));
	}

	static function toggle(key:String, value:String) : Bool {
		var values = readList(key);
		var idx = values.indexOf(value);
		if( idx>=0 ) {
			values.splice(idx, 1);
			writeList(key, values);
			return false;
		}
		values.unshift(value);
		writeList(key, values);
		return true;
	}

	static function remember(key:String, value:String) {
		if( value==null || value.length==0 )
			return;

		var values = readList(key);
		var idx = values.indexOf(value);
		if( idx>=0 )
			values.splice(idx, 1);
		values.unshift(value);
		while( values.length>MAX_RECENTS )
			values.pop();
		writeList(key, values);
	}

	static function contains(key:String, value:String) {
		return value!=null && readList(key).indexOf(value)>=0;
	}

	public static function toggleFavoritePack(path:String) return toggle(PACK_FAVORITES, path);
	public static function isFavoritePack(path:String) return contains(PACK_FAVORITES, path);
	public static function getFavoritePacks() return readList(PACK_FAVORITES);
	public static function rememberPack(path:String) remember(PACK_RECENTS, path);
	public static function getRecentPacks() return readList(PACK_RECENTS);

	public static function toggleFavoriteFile(path:String) return toggle(FILE_FAVORITES, path);
	public static function isFavoriteFile(path:String) return contains(FILE_FAVORITES, path);
	public static function getFavoriteFiles() return readList(FILE_FAVORITES);
	public static function rememberFile(path:String) remember(FILE_RECENTS, path);
	public static function getRecentFiles() return readList(FILE_RECENTS);

	public static function rememberStarter(path:String) remember(STARTER_RECENTS, path);
	public static function getRecentStarters() return readList(STARTER_RECENTS);
}
