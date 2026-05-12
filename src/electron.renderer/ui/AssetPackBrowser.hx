package ui;

import misc.AssetLibrary;
import misc.AssetLibrary.AssetLibraryPack;
import misc.AssetLibrary.AssetLibraryPreviewFile;

class AssetPackBrowser {
	static inline var PREVIEW_PAGE_SIZE = 60;

	public static function open(pack:AssetLibraryPack, onShowMoreStarters:Void->Void) {
		var starters = AssetLibrary.getStarterSamples(pack);
		var folder = AssetLibrary.getPackAbsPath(pack);
		var previewLimit = PREVIEW_PAGE_SIZE;
		var w = new ui.modal.Dialog(null, "assetBrowser");
		w.addTitle(L.untranslated(pack.name), true);

		var jSummary = new J('<div class="summary"/>');
		jSummary.appendTo(w.jContent);
		var jMeta = new J('<div class="meta"/>');
		jMeta.appendTo(jSummary);
		new J('<span/>').text(AssetLibrary.getPackSubtitle(pack)).appendTo(jMeta);
		if( pack.suggestedUse!=null && pack.suggestedUse.length>0 )
			new J('<span/>').text(pack.suggestedUse).appendTo(jMeta);
		if( pack.summary!=null && pack.summary.length>0 )
			new J('<p/>').text(pack.summary).appendTo(jSummary);

		var jActions = new J('<div class="assetBrowserActions"/>');
		jActions.appendTo(w.jContent);
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
		var jCount = new J('<button type="button" class="gray" disabled/>');
		jCount.appendTo(jTools);
		jCount.css("flex", "0 0 auto");

		var jGrid = new J('<div class="assetBrowserGrid"/>');
		jGrid.appendTo(w.jContent);
		var jEmpty = new J('<div class="empty"/>');
		jEmpty.appendTo(w.jContent);
		var jMorePreviews = new J('<button type="button" class="gray"><span class="icon down"></span>Show more previews</button>');
		jMorePreviews.appendTo(w.jContent);

		var renderPreviews = function() {
			var query : String = jSearch.val();
			var total = AssetLibrary.getPreviewFileCount(pack, query);
			var files = AssetLibrary.getPreviewFiles(pack, previewLimit, query);
			jGrid.empty();
			for(file in files)
				appendAssetPreview(jGrid, file);

			jGrid.toggle(total>0);
			jEmpty.toggle(total==0);
			if( total==0 )
				jEmpty.text(query==null || StringTools.trim(query).length==0
					? "No previewable images or audio files were found in this pack. Use Open folder to inspect the source files."
					: "No previewable files match this search.");
			jCount.text(total==0 ? "0 previews" : files.length+" / "+total+" previews");
			jMorePreviews.toggle(total>files.length);
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

	static function appendAssetPreview(jGrid:js.jquery.JQuery, file:AssetLibraryPreviewFile) {
		var jItem = new J('<div class="assetPreview ${file.kind}"/>');
		jItem.appendTo(jGrid);
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
		}
		new J('<div class="name"/>').text(file.name).appendTo(jItem);
		new J('<small/>').text(file.relPath).appendTo(jItem);
		jItem.click((ev)->JsTools.locateFile(file.absPath, true));
		jItem.find("audio").click((ev:js.jquery.Event)->ev.stopPropagation());
	}
}
