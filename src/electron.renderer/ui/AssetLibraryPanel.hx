package ui;

import misc.AssetLibrary;
import misc.AssetLibrary.AssetLibraryPack;

class AssetLibraryPanel {
	var jRoot : js.jquery.JQuery;
	var filter = "*";
	var onShowMoreStarters : AssetLibraryPack->Void;

	public function new(jRoot:js.jquery.JQuery, onShowMoreStarters:AssetLibraryPack->Void) {
		this.jRoot = jRoot;
		this.onShowMoreStarters = onShowMoreStarters;
	}

	public function load() {
		var atlasDir = AssetLibrary.getDir();
		var jScroller = jRoot.find(".scroller");

		if( !NT.fileExists(atlasDir) ) {
			jScroller.append('<div class="sample"><div class="name">No asset library folder</div></div>');
			return;
		}

		if( !NT.fileExists(AssetLibrary.getManifestPath()) ) {
			jScroller.append('<div class="sample"><div class="name">No asset manifest</div></div>');
			return;
		}

		var packs = AssetLibrary.getPacks();
		if( packs.length==0 ) {
			jScroller.append('<div class="sample"><div class="name">No asset packs</div></div>');
			return;
		}

		createFilters(packs);

		for(pack in packs)
			appendPack(jScroller, pack);

		updateFilter();
	}

	function appendPack(jScroller:js.jquery.JQuery, pack:AssetLibraryPack) {
		var folder = AssetLibrary.getPackAbsPath(pack);
		var thumb = AssetLibrary.getThumbAbsPath(pack);
		var starters = AssetLibrary.getStarterSamples(pack);

		var jPack = new J('<div class="sample assetPack"/>');
		jPack.appendTo(jScroller);
		jPack.attr("data-kind", pack.kind);
		jPack.attr("data-search", AssetLibrary.getSearchText(pack));
		var jThumb = new J('<div class="thumb"></div>');
		jThumb.appendTo(jPack);
		if( pack.thumb!=null && pack.thumb.length>0 && NT.fileExists(thumb) )
			jThumb.css("background-image", 'url("${AssetLibrary.toFileUrl(thumb)}")');

		var jName = new J('<div class="name"/>');
		jName.appendTo(jPack);
		var jHeader = new J('<div class="packHeader"><span class="kind"></span><span class="count"></span></div>');
		jHeader.appendTo(jName);
		jHeader.find(".kind").text(pack.kind);
		jHeader.find(".count").text(Std.string(pack.files));
		new J('<strong/>').text(pack.name).appendTo(jName);
		new J('<small class="exts"/>').text(AssetLibrary.getExtensionLabel(pack)).appendTo(jName);
		if( starters.length>0 ) {
			var label = starters.length+" starter template"+(starters.length==1 ? "" : "s");
			new J('<small class="use"/>').text(label).appendTo(jName);
		}
		if( pack.suggestedUse!=null && pack.suggestedUse.length>0 )
			new J('<small class="use"/>').text(pack.suggestedUse).appendTo(jName);
		if( pack.author!=null && pack.author.length>0 )
			new J('<small class="credit"/>').text("by "+pack.author).appendTo(jName);
		if( pack.license!=null && pack.license.length>0 )
			new J('<small class="license"/>').text(pack.license).appendTo(jName);
		if( pack.summary!=null && pack.summary.length>0 )
			jPack.attr("title", pack.summary);
		jPack.click((ev)->openBrowser(pack));
		jPack.on("contextmenu", (ev:js.jquery.Event)->{
			ev.preventDefault();
			openPackMenu(ev, pack, folder, thumb);
		});
	}

	function createFilters(packs:Array<AssetLibraryPack>) {
		var jFilters = jRoot.find(".assetFilters");
		jFilters.empty();

		var kinds = [];
		var seen = new Map<String,Bool>();
		for(pack in packs)
			if( !seen.exists(pack.kind) ) {
				seen.set(pack.kind, true);
				kinds.push(pack.kind);
			}
		kinds.sort(Reflect.compare);

		function addFilter(label:String, kind:String) {
			var jButton = new J('<button type="button"/>');
			jButton.appendTo(jFilters);
			jButton.append('<span class="label"></span><span class="count"></span>');
			jButton.find(".label").text(label);
			jButton.attr("data-kind", kind);
			jButton.click((ev)->{
				filter = kind;
				updateFilter();
			});
		}

		addFilter(L.t._("All"), "*");
		for(kind in kinds)
			addFilter(kind, kind);

		jRoot.find(".assetSearch").off().on("input", (_)->updateFilter());
	}

	function updateFilter() {
		var query = (jRoot.find(".assetSearch").val():String);
		query = query==null ? "" : query.toLowerCase();

		jRoot.find(".assetFilters button").each( function(idx, e) {
			var jButton = new J(e);
			jButton.toggleClass("active", jButton.attr("data-kind")==filter);
			jButton.find(".count").text(Std.string(countMatchingPacks(jButton.attr("data-kind"), query)));
		});

		var visibleCount = 0;
		jRoot.find(".assetPack").each( function(idx, e) {
			var jPack = new J(e);
			var visible = packMatchesFilter(jPack, filter, query);
			if( visible )
				visibleCount++;
			jPack.toggle(visible);
		});
		jRoot.find(".assetEmpty").toggle(visibleCount==0);
	}

	function countMatchingPacks(kindFilter:String, query:String) {
		var count = 0;
		jRoot.find(".assetPack").each( function(idx, e) {
			if( packMatchesFilter(new J(e), kindFilter, query) )
				count++;
		});
		return count;
	}

	function packMatchesFilter(jPack:js.jquery.JQuery, kindFilter:String, query:String) {
		var matchesKind = kindFilter=="*" || jPack.attr("data-kind")==kindFilter;
		var haystack = jPack.attr("data-search");
		var matchesQuery = query.length==0 || haystack.indexOf(query)>=0;
		return matchesKind && matchesQuery;
	}

	function openPackMenu(ev:js.jquery.Event, pack:AssetLibraryPack, folder:String, thumb:String) {
		ev.stopPropagation();

		var ctx = new ui.modal.ContextMenu(ev);
		ctx.addTitle(L.untranslated(pack.name));
		ctx.addAction({
			label: L.untranslated(AssetLibrary.getPackSubtitle(pack)),
			subText: pack.summary==null ? null : L.untranslated(pack.summary),
		});
		ctx.addAction({
			label: L.t._("Browse pack contents"),
			iconId: "search",
			cb: ()->openBrowser(pack),
		});
		var starters = AssetLibrary.getStarterSamples(pack);
		ctx.addAction({
			label: starters.length==1 ? L.t._("Open starter template") : L.t._("Open first starter template"),
			iconId: "open",
			subText: L.untranslated(starters.length+" starter template"+(starters.length==1 ? "" : "s")),
			show: ()->starters.length>0,
			cb: ()->App.ME.loadProject(starters[0].absPath),
		});
		ctx.addAction({
			label: L.t._("Open asset folder"),
			iconId: "open",
			cb: ()->JsTools.locateFile(folder, false),
		});
		ctx.addAction({
			label: L.t._("Copy folder path"),
			iconId: "copy",
			cb: ()->{
				App.ME.clipboard.copyStr(folder);
				N.copied("folder path");
			},
		});
		ctx.addAction({
			label: L.t._("Reveal preview image"),
			iconId: "locate",
			show: ()->pack.thumb!=null && pack.thumb.length>0 && NT.fileExists(thumb),
			cb: ()->JsTools.locateFile(thumb, true),
		});
		ctx.addAction({
			label: L.t._("Copy image import folder"),
			iconId: "copy",
			subText: L.untranslated(AssetLibrary.getExtensionLabel(pack)),
			show: ()->AssetLibrary.hasImageFiles(pack),
			cb: ()->{
				App.ME.clipboard.copyStr(folder);
				N.copied("image import folder");
			},
		});
		ctx.addAction({
			label: L.t._("Copy audio folder"),
			iconId: "copy",
			subText: L.untranslated(AssetLibrary.getExtensionLabel(pack)),
			show: ()->AssetLibrary.hasAudioFiles(pack),
			cb: ()->{
				App.ME.clipboard.copyStr(folder);
				N.copied("audio folder");
			},
		});
		if( pack.suggestedUse!=null && pack.suggestedUse.length>0 )
			ctx.addAction({
				label: L.untranslated(pack.suggestedUse),
				subText: L.untranslated(pack.summary),
			});
	}

	function openBrowser(pack:AssetLibraryPack) {
		ui.AssetPackBrowser.open(pack, ()->onShowMoreStarters(pack));
	}
}
