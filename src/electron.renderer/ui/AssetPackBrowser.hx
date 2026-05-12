package ui;

import misc.AssetLibrary;
import misc.AssetLibrary.AssetLibraryPack;
import misc.AssetLibrary.AssetLibraryPreviewFile;
import misc.AssetLibraryState;

class AssetPackBrowser {
	static inline var PREVIEW_PAGE_SIZE = 60;

	public static function open(pack:AssetLibraryPack, onShowMoreStarters:Void->Void) {
		var starters = AssetLibrary.getStarterSamples(pack);
		var folder = AssetLibrary.getPackAbsPath(pack);
		var previewLimit = PREVIEW_PAGE_SIZE;
		var kindFilter = "*";
		var selectedAudio : Array<String> = [];
		var w = new ui.modal.Dialog(null, "assetBrowser");
		w.addTitle(L.untranslated(pack.name), true);

		new J('<div class="privateUseBanner">Private asset mode: inspect and prototype with bundled assets locally; verify licenses before public redistribution.</div>').appendTo(w.jContent);
		var jSummary = new J('<div class="summary"/>');
		jSummary.appendTo(w.jContent);
		var jMeta = new J('<div class="meta"/>');
		jMeta.appendTo(jSummary);
		new J('<span/>').text(AssetLibrary.getPackSubtitle(pack)).appendTo(jMeta);
		if( pack.author!=null && pack.author.length>0 )
			new J('<span/>').text("by "+pack.author).appendTo(jMeta);
		if( pack.license!=null && pack.license.length>0 )
			new J('<span/>').text(pack.license).appendTo(jMeta);
		if( pack.suggestedUse!=null && pack.suggestedUse.length>0 )
			new J('<span/>').text(pack.suggestedUse).appendTo(jMeta);
		for(tag in AssetLibraryState.getPackTags(pack.path))
			new J('<span/>').text("#"+tag).appendTo(jMeta);
		if( pack.summary!=null && pack.summary.length>0 )
			new J('<p/>').text(pack.summary).appendTo(jSummary);

		var jActions = new J('<div class="assetBrowserActions"/>');
		jActions.appendTo(w.jContent);
		var jFavoritePack = new J('<button type="button" class="gray"><span class="icon love"></span><span class="label"></span></button>');
		jFavoritePack.appendTo(jActions);
		function syncPackFavorite() {
			var active = AssetLibraryState.isFavoritePack(pack.path);
			jFavoritePack.toggleClass("active", active);
			jFavoritePack.find(".label").text(active ? "Favorited" : "Favorite");
		}
		syncPackFavorite();
		jFavoritePack.click((ev)->{
			AssetLibraryState.toggleFavoritePack(pack.path);
			syncPackFavorite();
		});
		for(tag in [ "rpg", "platformer", "topdown", "horror", "characters", "audio", "ui", "needs-review" ]) {
			var jTag = new J('<button type="button" class="gray"><span class="label"></span></button>');
			jTag.find(".label").text("#"+tag);
			jTag.toggleClass("active", AssetLibraryState.isPackTagged(pack.path, tag));
			jTag.appendTo(jActions);
			jTag.click((ev)->{
				var active = AssetLibraryState.togglePackTag(pack.path, tag);
				jTag.toggleClass("active", active);
			});
		}
		var jOpen = new J('<button type="button"><span class="icon open"></span>Open folder</button>');
		jOpen.appendTo(jActions);
		jOpen.click((ev)->JsTools.locateFile(folder, false));
		var jCopy = new J('<button type="button" class="gray"><span class="icon copy"></span>Copy path</button>');
		jCopy.appendTo(jActions);
		jCopy.click((ev)->{
			App.ME.clipboard.copyStr(folder);
			N.copied("folder path");
		});

		if( starters.length>0 ) {
			var jStarters = new J('<div class="assetBrowserActions starterActions"/>');
			jStarters.appendTo(w.jContent);
			jStarters.css("flex-wrap", "wrap");
			jStarters.css("max-height", "120px");
			jStarters.css("overflow", "auto");
			jStarters.css("padding", "4px");
			var shown = starters.length>10 ? starters.slice(0, 10) : starters;
			for(starter in shown) {
				var jStarter = new J('<button type="button" class="help"><span class="icon doc"></span><span class="label"></span></button>');
				jStarter.appendTo(jStarters);
				jStarter.css("flex", "1 1 210px");
				jStarter.css("min-width", "0");
				jStarter.css("overflow", "hidden");
				jStarter.css("text-overflow", "ellipsis");
				jStarter.css("text-transform", "none");
				jStarter.css("white-space", "nowrap");
				jStarter.find(".label").text(starter.name);
				jStarter.attr("title", starter.absPath);
				jStarter.click((ev)->App.ME.loadProject(starter.absPath));
			}
			if( starters.length>shown.length ) {
				var jMoreStarters = new J('<button type="button" class="gray"/>');
				jMoreStarters.text("+"+(starters.length-shown.length)+" more");
				jMoreStarters.appendTo(jStarters);
				jMoreStarters.css("flex", "0 0 auto");
				jMoreStarters.click((ev)->{
					onShowMoreStarters();
					w.close();
				});
			}
		}

		var jTools = new J('<div class="assetBrowserActions"/>');
		jTools.appendTo(w.jContent);
		var jSearch = new J('<input type="text" placeholder="Search previews"/>');
		jSearch.appendTo(jTools);
		jSearch.css("flex", "1 1 auto");
		jSearch.css("min-width", "220px");
		var jKinds = new J('<div class="assetFilters inlineFilters"/>');
		jKinds.appendTo(jTools);
		var renderPreviews : Void->Void = null;
		function addKind(label:String, kind:String) {
			var jButton = new J('<button type="button"><span class="label"></span></button>');
			jButton.find(".label").text(label);
			jButton.attr("data-kind", kind);
			jButton.appendTo(jKinds);
			jButton.click((ev)->{
				kindFilter = kind;
				previewLimit = PREVIEW_PAGE_SIZE;
				renderPreviews();
			});
		}
		addKind("All", "*");
		addKind("Images", "image");
		addKind("Audio", "audio");
		addKind("Favorites", "favorites");
		var jCount = new J('<button type="button" class="gray" disabled/>');
		jCount.appendTo(jTools);
		jCount.css("flex", "0 0 auto");

		var jGrid = new J('<div class="assetBrowserGrid"/>');
		jGrid.appendTo(w.jContent);
		var jStopAudio = new J('<button type="button" class="gray"><span class="icon close"></span>Stop audio</button>');
		jStopAudio.appendTo(jTools);
		jStopAudio.click((ev)->{
			jGrid.find("audio").each((idx, e)->{
				var audio : js.html.AudioElement = cast e;
				audio.pause();
				audio.currentTime = 0;
			});
		});
		var jVolume = new J('<input class="audioVolume" type="range" min="0" max="100" value="80" title="Audio preview volume"/>');
		jVolume.appendTo(jTools);
		jVolume.on("input", (_)->{
			var volume = Std.parseInt(jVolume.val()) / 100;
			jGrid.find("audio").each((idx, e)->{
				var audio : js.html.AudioElement = cast e;
				audio.volume = volume;
			});
		});
		var jCopySelectedAudio = new J('<button type="button" class="gray"><span class="icon copy"></span>Copy selected audio</button>');
		jCopySelectedAudio.appendTo(jTools);
		jCopySelectedAudio.click((ev)->{
			App.ME.clipboard.copyStr(selectedAudio.join("\n"));
			N.copied("selected audio paths");
		});
		var jEmpty = new J('<div class="empty"/>');
		jEmpty.appendTo(w.jContent);
		var jMorePreviews = new J('<button type="button" class="gray"><span class="icon down"></span>Show more previews</button>');
		jMorePreviews.appendTo(w.jContent);

		renderPreviews = function() {
			var query : String = jSearch.val();
			var allMatches = AssetLibrary.getPreviewFiles(pack, 0, query).filter((file)->{
				return switch kindFilter {
					case "*": true;
					case "favorites": AssetLibraryState.isFavoriteFile(file.absPath);
					case _: file.kind==kindFilter;
				}
			});
			var total = allMatches.length;
			var files = previewLimit>0 && allMatches.length>previewLimit ? allMatches.slice(0, previewLimit) : allMatches;
			jGrid.empty();
			for(file in files)
				appendAssetPreview(jGrid, file, renderPreviews, selectedAudio, Std.parseInt(jVolume.val()) / 100);

			jGrid.toggle(total>0);
			jEmpty.toggle(total==0);
			if( total==0 )
				jEmpty.text(query==null || StringTools.trim(query).length==0
					? "No previewable images or audio files were found in this pack. Use Open folder to inspect the source files."
					: "No previewable files match this search.");
			jCount.text(total==0 ? "0 previews" : files.length+" / "+total+" previews");
			jMorePreviews.toggle(total>files.length);
			jStopAudio.toggle(AssetLibrary.hasAudioFiles(pack));
			jVolume.toggle(AssetLibrary.hasAudioFiles(pack));
			jCopySelectedAudio.toggle(selectedAudio.length>0);
			jKinds.find("button").each((idx, e)->{
				var jButton = new J(e);
				jButton.toggleClass("active", jButton.attr("data-kind")==kindFilter);
			});
		}

		jSearch.on("input", (_)->{
			previewLimit = PREVIEW_PAGE_SIZE;
			renderPreviews();
		});
		jMorePreviews.click((ev)->{
			previewLimit+=PREVIEW_PAGE_SIZE;
			renderPreviews();
		});
		renderPreviews();

		w.addClose();
	}

	static function appendAssetPreview(jGrid:js.jquery.JQuery, file:AssetLibraryPreviewFile, refresh:Void->Void, selectedAudio:Array<String>, audioVolume:Float) {
		var jItem = new J('<div class="assetPreview ${file.kind}"/>');
		jItem.appendTo(jGrid);
		var jFavorite = new J('<button type="button" class="favoriteFile" title="Favorite file"><span class="icon love"></span></button>');
		jFavorite.appendTo(jItem);
		jFavorite.toggleClass("active", AssetLibraryState.isFavoriteFile(file.absPath));
		jFavorite.click((ev:js.jquery.Event)->{
			ev.stopPropagation();
			AssetLibraryState.toggleFavoriteFile(file.absPath);
			refresh();
		});
		var fileUrl = AssetLibrary.toFileUrl(file.absPath);
		if( file.kind=="image" ) {
			var jPreview = new J('<div class="preview"></div>');
			jPreview.appendTo(jItem);
			jPreview.css("background-image", 'url("$fileUrl")');
		}
		else {
			var jPreview = new J('<div class="preview audio"><span class="icon doc"></span><audio controls></audio></div>');
			jPreview.appendTo(jItem);
			jPreview.find("audio").attr("src", fileUrl);
			jPreview.find("audio").each((idx, e)->{
				var audio : js.html.AudioElement = cast e;
				audio.volume = audioVolume;
			});
		}
		new J('<div class="name"/>').text(file.name).appendTo(jItem);
		new J('<small/>').text(file.relPath).appendTo(jItem);
		var jActions = new J('<div class="previewActions"/>');
		jActions.appendTo(jItem);
		var jCopyRel = new J('<button type="button" class="gray" title="Copy atlas-relative path"><span class="icon copy"></span></button>');
		jCopyRel.appendTo(jActions);
		jCopyRel.click((ev:js.jquery.Event)->{
			ev.stopPropagation();
			App.ME.clipboard.copyStr(file.relPath);
			N.copied("atlas-relative path");
			AssetLibraryState.rememberFile(file.absPath);
		});
		var jCopyAbs = new J('<button type="button" class="gray" title="Copy absolute path"><span class="icon doc"></span></button>');
		jCopyAbs.appendTo(jActions);
		jCopyAbs.click((ev:js.jquery.Event)->{
			ev.stopPropagation();
			App.ME.clipboard.copyStr(file.absPath);
			N.copied("absolute path");
			AssetLibraryState.rememberFile(file.absPath);
		});
		if( file.kind=="image" && ui.AssetImportTools.canImportImageToCurrentEditor() ) {
			var jImport = new J('<button type="button" title="Import as tileset"><span class="icon add"></span></button>');
			jImport.appendTo(jActions);
			jImport.click((ev:js.jquery.Event)->{
				ev.stopPropagation();
				ui.AssetImportTools.importImageAsTileset(file.absPath);
			});
		}
		if( file.kind=="audio" ) {
			var jSelect = new J('<button type="button" class="gray" title="Select audio path"><span class="icon checker"></span></button>');
			jSelect.appendTo(jActions);
			jSelect.toggleClass("active", selectedAudio.indexOf(file.relPath)>=0);
			jSelect.click((ev:js.jquery.Event)->{
				ev.stopPropagation();
				var idx = selectedAudio.indexOf(file.relPath);
				if( idx>=0 )
					selectedAudio.splice(idx, 1);
				else
					selectedAudio.push(file.relPath);
				refresh();
			});
		}
		jItem.click((ev)->{
			AssetLibraryState.rememberFile(file.absPath);
			JsTools.locateFile(file.absPath, true);
		});
		jItem.find("audio").click((ev:js.jquery.Event)->ev.stopPropagation());
	}
}
