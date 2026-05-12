package ui;

import misc.AssetLibrary;
import misc.AssetLibraryState;

class AssetImportTools {
	static function isImagePath(absPath:String) {
		var ext = AssetLibrary.normalizeExtension(dn.FilePath.fromFile(absPath).extension);
		return AssetLibrary.isImageExtension(ext) || ext==".aseprite" || ext==".ase";
	}

	public static function canImportImageToCurrentEditor() {
		return page.Editor.ME!=null && page.Editor.ME.project!=null;
	}

	public static function importImageAsTileset(absPath:String) : Null<data.def.TilesetDef> {
		if( !canImportImageToCurrentEditor() )
			return null;
		if( !isImagePath(absPath) )
			return null;

		var editor = page.Editor.ME;
		var project = editor.project;
		var td = project.defs.createTilesetDef();
		var relPath = project.makeRelativeFilePath(absPath);

		App.LOG.fileOp("Loading bundled asset atlas: "+absPath);
		var result = td.importAtlasImage(relPath);
		switch result {
			case Ok:

			case FileNotFound, LoadingFailed(_), UnsupportedFileOrigin(_):
				project.defs.removeTilesetDef(td);
				new ui.modal.dialog.Warning(Lang.imageLoadingMessage(relPath, result));
				return null;

			case TrimmedPadding, RemapLoss, RemapSuccessful:
				new ui.modal.dialog.Message(Lang.imageLoadingMessage(relPath, result), "tile");
		}

		editor.watcher.watchImage(td.relPath);
		project.defs.autoRenameTilesetIdentifier(null, td);
		editor.ge.emit(TilesetDefAdded(td));
		editor.ge.emit(TilesetImageLoaded(td, false));
		AssetLibraryState.rememberFile(absPath);
		N.success("Tileset imported from asset library");
		return td;
	}

	public static function appendRecentImageButton(anchor:js.jquery.JQuery, onPick:String->Void) {
		var files = AssetLibraryState.getRecentFiles().filter((path)->NT.fileExists(path) && isImagePath(path));
		if( files.length==0 )
			return;

		var jButton = new J('<button type="button" class="recall assetRecent" title="Recent bundled assets"><span class="icon update"/></button>');
		jButton.insertAfter(anchor);
		jButton.click((ev:js.jquery.Event)->{
			ev.stopPropagation();
			var ctx = new ui.modal.ContextMenu(ev);
			ctx.addTitle(L.t._("Recent bundled assets"));
			for(absPath in files.slice(0, 12)) {
				var fp = dn.FilePath.fromFile(absPath);
				ctx.addAction({
					label: L.untranslated(fp.fileWithExt),
					iconId: "tile",
					subText: L.untranslated(AssetLibrary.getAtlasRelativePath(absPath)),
					cb: ()->{
						AssetLibraryState.rememberFile(absPath);
						onPick(absPath);
					},
				});
			}
		});
	}
}
