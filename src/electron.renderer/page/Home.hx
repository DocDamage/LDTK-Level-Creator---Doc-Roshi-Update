package page;

import hxd.Key;
import misc.AssetLibrary.AssetLibraryPack;
import misc.AssetLibrary.AssetLibraryPreviewFile;

class Home extends Page {
	public static var ME : Home;

	var pendingBackupChecks : Array<{ projectFp:dn.FilePath, jTarget:js.jquery.JQuery }> = [];
	var assetFilter = "*";
	var sampleFilter = "*";

	public function new() {
		super();

		ME = this;
		var changeLog = Const.getChangeLog();
		var ver = Const.getAppVersionObj();
		loadPageTemplate("home", {
			app: Const.APP_NAME,
			majorVer: ver.major,
			minorVer: ver.minor,
			patchVer: ver.patch,
			buildDate: dn.MacroTools.getHumanBuildDate(),
			latestVer: changeLog.latest.version,
			latestDesc: changeLog.latest.title==null ? L.t._("Release notes") : '"'+changeLog.latest.title+'"',
			deepnightUrl: Const.DEEPNIGHT_DOMAIN,
			discordUrl: Const.DISCORD_URL,
			docUrl: Const.DOCUMENTATION_URL,
			websiteUrl : Const.HOME_URL,
			issueUrl : Const.ISSUES_URL,
			jsonUrl: Const.JSON_DOC_URL,
			email: Const.getContactEmail(),
		});
		App.ME.setWindowTitle();

		// Hide patch version if zero
		if( ver.patch!=0 )
			jPage.find("header .version").addClass("patchRelease");

		jPage.find(".changelogs code").each( function(idx,e) {
			var jCode = new J(e);
			if( (~/sample/i).match( jCode.text().toLowerCase() ) ) {
				var jLink = new J('<a href="#" class="discreet">${jCode.text()}</a>');
				jLink.click( function(ev:js.jquery.Event) {
					ev.preventDefault();
					onLoadSamples();
				});
				jCode.replaceWith(jLink);
			}
		});

		// Buttons
		jPage.find(".load").click( (_)->onLoad() );
		jPage.find(".samples").click( (_)->{
			if( settings.getUiStateBool(HideSamplesOnHome) )
				showSamples();
			else
				hideSamples();
		});
		jPage.find(".sampleProjects .hide").click( (_)->hideSamples() );
		jPage.find(".assets").click( (_)->{
			if( jPage.find(".assetLibrary").is(":visible") )
				hideAssetLibrary();
			else
				showAssetLibrary();
		});
		jPage.find(".assetLibrary .hide").click( (_)->hideAssetLibrary() );
		jPage.find(".import").click( (ev)->onImport(ev) );
		jPage.find(".new").click( (_)->if( !cd.hasSetS("newLock",0.2) ) onNew() );

		if( !settings.getUiStateBool(HideSamplesOnHome) )
			showSamples(false);

		jPage.find(".support").click( (ev)->{
			var w = new ui.Modal();
			w.setAnchor(MA_Centered);
			w.loadTemplate("support", {
				app: Const.APP_NAME,
				itchUrl: Const.ITCH_IO_BUY_URL,
				gitHubSponsorUrl: Const.GITHUB_SPONSOR_URL,
				steamUrl: Const.STEAM_URL,
			});
			w.jContent.find("[data-link]").click((ev:js.jquery.Event)->{
				var jButton = ev.getThis();
				var url = jButton.attr("data-link");
				electron.Shell.openExternal(url);
			});
		});

		jPage.find("button.update").click((_)->{
			new ui.modal.dialog.Changelog();
		});

		jPage.find("button.settings").click( function(ev) {
			new ui.modal.dialog.EditAppSettings();
		});

		jPage.find("button.exit").click( function(ev) {
			App.ME.exit();
		});

		updateRecents();
		if( settings.v.lastProject!=null ) {
			settings.v.lastProject = null;
			settings.save();
		}

		// Quick search
		new ui.QuickSearch(false, jPage.find(".recentFiles, .recentDirs"), jPage.find(".search"));

		// Samples
		var path = JsTools.getSamplesDir();
		App.LOG.debug("samplesDir="+path);
		var files = NT.readDir(path);
		files.sort( (a,b)->{
			var aTemplate = StringTools.startsWith(a, "Doc_Roshi_");
			var bTemplate = StringTools.startsWith(b, "Doc_Roshi_");
			if( aTemplate!=bTemplate )
				return aTemplate ? -1 : 1;
			return Reflect.compare(a,b);
		});
		var jSamples = jPage.find(".sampleProjects");
		var jScroller = jSamples.children(".scroller");
		jPage.find(".allSamples .scroller").on( "wheel", (ev:js.html.WheelEvent)->{
			var ev = (cast ev).originalEvent;
			var jTarget = new J(ev.currentTarget);
			jTarget.scrollLeft( jTarget.scrollLeft() + ev.deltaY );
			ev.preventDefault();
		});
		for(f in files) {
			var fp = dn.FilePath.fromFile(path+"/"+f);
			if( fp.extension!="ldtk" )
				continue;

			var jSample = new J('<div class="sample"/>');
			jSample.appendTo(jScroller);
			var name = StringTools.replace( fp.fileName, "_", " " );
			var sampleKind = getSampleKind(fp.fileName);
			jSample.attr("data-kind", sampleKind);
			jSample.attr("data-search", getSampleSearchText(fp.fileName, name, sampleKind));
			jSample.append('<div class="thumb" style="background-image:url($path/thumbs/${fp.fileName}.png)"></div>');
			if( StringTools.startsWith(fp.fileName, "Doc_Roshi_") ) {
				jSample.addClass("template");
				jSample.append('<div class="name"><span class="badge">Template</span><strong>$name</strong><small>Bundled asset starter</small></div>');
			}
			else
				jSample.append('<div class="name">$name</div>');
			jSample.click(_->{
				App.ME.loadProject( fp.full );
			});

			if( App.ME.recentProjectsContains(fp.full) )
				jSample.addClass("seen");
		}
		createSampleFilters();
		updateSampleFilter();

		loadAssetLibrary();
	}

	function getSampleKind(fileName:String) {
		if( StringTools.startsWith(fileName, "Doc_Roshi_CuteSCKR_") )
			return "cutesckr";
		if( StringTools.startsWith(fileName, "Doc_Roshi_") )
			return "template";
		return "core";
	}

	function getSampleSearchText(fileName:String, name:String, kind:String) {
		var labels = switch kind {
			case "cutesckr": "template cutesckr bundled asset starter tileset";
			case "template": "template bundled asset starter";
			case _: "core example sample";
		}
		return (fileName+" "+name+" "+labels).toLowerCase();
	}

	function createSampleFilters() {
		var jFilters = jPage.find(".sampleProjects .sampleFilters");
		jFilters.empty();

		function addFilter(label:String, kind:String) {
			var jButton = new J('<button type="button"/>');
			jButton.appendTo(jFilters);
			jButton.append('<span class="label"></span><span class="count"></span>');
			jButton.find(".label").text(label);
			jButton.attr("data-kind", kind);
			jButton.click((ev)->{
				sampleFilter = kind;
				updateSampleFilter();
			});
		}

		addFilter(L.t._("All"), "*");
		addFilter(L.t._("Templates"), "template");
		addFilter(L.untranslated("CuteSCKR"), "cutesckr");
		addFilter(L.t._("Core"), "core");

		jPage.find(".sampleProjects .sampleSearch").off().on("input", (_)->updateSampleFilter());
	}

	function updateSampleFilter() {
		var query = (jPage.find(".sampleProjects .sampleSearch").val():String);
		query = query==null ? "" : query.toLowerCase();

		jPage.find(".sampleProjects .sampleFilters button").each( function(idx, e) {
			var jButton = new J(e);
			jButton.toggleClass("active", jButton.attr("data-kind")==sampleFilter);
			jButton.find(".count").text( Std.string(countMatchingSamples(jButton.attr("data-kind"), query)) );
		});

		var visibleCount = 0;
		jPage.find(".sampleProjects .sample").each( function(idx, e) {
			var jSample = new J(e);
			var visible = sampleMatchesFilter(jSample, sampleFilter, query);
			if( visible )
				visibleCount++;
			jSample.toggle(visible);
		});
		jPage.find(".sampleProjects .sampleEmpty").toggle(visibleCount==0);
	}

	function countMatchingSamples(kindFilter:String, query:String) {
		var count = 0;
		jPage.find(".sampleProjects .sample").each( function(idx, e) {
			if( sampleMatchesFilter(new J(e), kindFilter, query) )
				count++;
		});
		return count;
	}

	function sampleMatchesFilter(jSample:js.jquery.JQuery, kindFilter:String, query:String) {
		var kind = jSample.attr("data-kind");
		var matchesKind = kindFilter=="*" || kind==kindFilter || ( kindFilter=="template" && (kind=="template" || kind=="cutesckr") );
		var haystack = jSample.attr("data-search");
		var matchesQuery = query.length==0 || haystack.indexOf(query)>=0;
		return matchesKind && matchesQuery;
	}

	function loadAssetLibrary() {
		var atlasDir = AssetLibrary.getDir();
		var jScroller = jPage.find(".assetLibrary .scroller");

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

		createAssetLibraryFilters(packs);

		for(pack in packs) {
			var folder = AssetLibrary.getPackAbsPath(pack);
			var thumb = AssetLibrary.getThumbAbsPath(pack);
			thumb = StringTools.replace(thumb, "\\", "/");

			var jPack = new J('<div class="sample assetPack"/>');
			jPack.appendTo(jScroller);
			jPack.attr("data-kind", pack.kind);
			jPack.attr("data-search", AssetLibrary.getSearchText(pack));
			if( pack.thumb!=null && pack.thumb.length>0 && NT.fileExists(thumb) )
				jPack.append('<div class="thumb" style="background-image:url(\'$thumb\')"></div>');
			else
				jPack.append('<div class="thumb"></div>');

			var jName = new J('<div class="name"/>');
			jName.appendTo(jPack);
			jName.append('<div class="packHeader"><span class="kind">${pack.kind}</span><span class="count">${pack.files}</span></div>');
			jName.append('<strong>${pack.name}</strong>');
			jName.append('<small class="exts">${AssetLibrary.getExtensionLabel(pack)}</small>');
			if( pack.suggestedUse!=null && pack.suggestedUse.length>0 )
				jName.append('<small class="use">${pack.suggestedUse}</small>');
			if( pack.author!=null && pack.author.length>0 )
				jName.append('<small class="credit">by ${pack.author}</small>');
			if( pack.license!=null && pack.license.length>0 )
				jName.append('<small class="license">${pack.license}</small>');
			jPack.attr("title", pack.summary);
			jPack.click((ev)->openAssetPackBrowser(pack));
			jPack.on("contextmenu", (ev:js.jquery.Event)->{
				ev.preventDefault();
				openAssetPackMenu(ev, pack, folder, thumb);
			});
		}
		updateAssetLibraryFilter();
	}

	function createAssetLibraryFilters(packs:Array<AssetLibraryPack>) {
		var jFilters = jPage.find(".assetLibrary .assetFilters");
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
				assetFilter = kind;
				updateAssetLibraryFilter();
			});
		}

		addFilter(L.t._("All"), "*");
		for(kind in kinds)
			addFilter(kind, kind);

		jPage.find(".assetLibrary .assetSearch").off().on("input", (_)->updateAssetLibraryFilter());
	}

	function updateAssetLibraryFilter() {
		var query = (jPage.find(".assetLibrary .assetSearch").val():String);
		query = query==null ? "" : query.toLowerCase();

		jPage.find(".assetLibrary .assetFilters button").each( function(idx, e) {
			var jButton = new J(e);
			jButton.toggleClass("active", jButton.attr("data-kind")==assetFilter);
			jButton.find(".count").text( Std.string(countMatchingAssetPacks(jButton.attr("data-kind"), query)) );
		});

		var visibleCount = 0;
		jPage.find(".assetLibrary .assetPack").each( function(idx, e) {
			var jPack = new J(e);
			var visible = assetPackMatchesFilter(jPack, assetFilter, query);
			if( visible )
				visibleCount++;
			jPack.toggle(visible);
		});
		jPage.find(".assetLibrary .assetEmpty").toggle(visibleCount==0);
	}

	function countMatchingAssetPacks(kindFilter:String, query:String) {
		var count = 0;
		jPage.find(".assetLibrary .assetPack").each( function(idx, e) {
			if( assetPackMatchesFilter(new J(e), kindFilter, query) )
				count++;
		});
		return count;
	}

	function assetPackMatchesFilter(jPack:js.jquery.JQuery, kindFilter:String, query:String) {
		var matchesKind = kindFilter=="*" || jPack.attr("data-kind")==kindFilter;
		var haystack = jPack.attr("data-search");
		var matchesQuery = query.length==0 || haystack.indexOf(query)>=0;
		return matchesKind && matchesQuery;
	}

	function openAssetPackMenu(ev:js.jquery.Event, pack:AssetLibraryPack, folder:String, thumb:String) {
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
			cb: ()->openAssetPackBrowser(pack),
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

	function openAssetPackBrowser(pack:AssetLibraryPack) {
		var files = AssetLibrary.getPreviewFiles(pack);
		var folder = AssetLibrary.getPackAbsPath(pack);
		var w = new ui.modal.Dialog(null, "assetBrowser");
		w.addTitle(L.untranslated(pack.name), true);

		var jSummary = new J('<div class="summary"/>');
		jSummary.appendTo(w.jContent);
		var jMeta = new J('<div class="meta"/>');
		jMeta.appendTo(jSummary);
		jMeta.append('<span>${AssetLibrary.getPackSubtitle(pack)}</span>');
		if( pack.suggestedUse!=null && pack.suggestedUse.length>0 )
			jMeta.append('<span>${pack.suggestedUse}</span>');
		if( pack.summary!=null && pack.summary.length>0 )
			jSummary.append('<p>${pack.summary}</p>');

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

		if( files.length==0 ) {
			w.jContent.append('<div class="empty">No previewable images or audio files in this pack.</div>');
			w.addClose();
			return;
		}

		var jGrid = new J('<div class="assetBrowserGrid"/>');
		jGrid.appendTo(w.jContent);
		for(file in files)
			appendAssetPreview(jGrid, file);

		if( pack.files>files.length )
			w.jContent.append('<div class="more">Showing ${files.length} previewable files from this pack.</div>');

		w.addClose();
	}

	function appendAssetPreview(jGrid:js.jquery.JQuery, file:AssetLibraryPreviewFile) {
		var abs = StringTools.replace(file.absPath, "\\", "/");
		var jItem = new J('<div class="assetPreview ${file.kind}"/>');
		jItem.appendTo(jGrid);
		if( file.kind=="image" )
			jItem.append('<div class="preview" style="background-image:url(\'$abs\')"></div>');
		else
			jItem.append('<div class="preview audio"><span class="icon doc"></span><audio controls src="file:///$abs"></audio></div>');
		jItem.append('<div class="name">${file.name}</div>');
		jItem.append('<small>${file.relPath}</small>');
		jItem.click((ev)->JsTools.locateFile(file.absPath, true));
		jItem.find("audio").click((ev:js.jquery.Event)->ev.stopPropagation());
	}


	function updateRecents() : Void {
		ui.Tip.clear();
		pendingBackupChecks = [];

		// Clean up invalid paths
		settings.v.recentProjects = settings.v.recentProjects.filter( (p)->{
			if( p==null || p.length==0 )
				return false;

			var fp = dn.FilePath.fromFile(p);
			return fp!=null && fp.directory!=null && fp.fileWithExt!=null;
		});
		settings.v.recentDirs = settings.v.recentDirs.filter( (p)->{
			if( p==null || p.length==0 )
				return false;

			var fp = dn.FilePath.fromDir(p);
			return fp!=null && fp.directory!=null;
		});
		settings.save();



		var recents = settings.v.recentProjects.copy();


		// Automatically detect backups
		var i = 0;
		while( i<recents.length ) {
			var fp = dn.FilePath.fromFile(recents[i]);
			var backup = fp.clone();
			backup.fileName+=Const.BACKUP_NAME_SUFFIX;
			if( !App.ME.recentProjectsContains(backup.full) && NT.fileExists(backup.full) )
				recents.insert(i+1, backup.full);
			i++;
		}


		// List files
		var jRecentFiles = jPage.find("ul.recentFiles");
		jRecentFiles.empty();
		if( recents.length>0 )
			jRecentFiles.append('<li class="title">Recent projects</li>');

		var i = recents.length-1;
		while( i>=0 ) {
			var filePath = recents[i];
			var isBackupFile = filePath.indexOf( Const.BACKUP_NAME_SUFFIX )>=0;
			var jLi = new J('<li/>');

			try {
				var fp = dn.FilePath.fromFile(filePath);
				var col = App.ME.getRecentDirColor(fp.directory);
				if( App.ME.isInAppDir(filePath,true) )
					jLi.addClass("sample");
				if( App.ME.hasForcedDirColor(fp.directory) )
					jLi.css("background-color", col.toCssRgba(0.4));
				// jLi.css("background-color", col.toCssRgba(App.ME.hasForcedDirColor(fp.directory) ? 0.4 : 0.1));

				var jName = new J('<span class="fileName">${fp.fileName}</span>');
				jName.appendTo(jLi);
				jName.css("color", col.toWhite(0.4).toHex());

				var jDir = JsTools.makePath(fp.full, col.toWhite(0.6));
				jDir.appendTo(jLi);

				jLi.click( function(ev) {
					App.ME.loadProject(filePath);
				});

				if( !NT.fileExists(filePath) )
					jLi.addClass("missing");

				if( isBackupFile )
					jLi.addClass("crash");

				// Backups button (async)
				var jBackupWrapper = new J('<div class="backupWrapper"></div>');
				jBackupWrapper.appendTo(jLi);
				jBackupWrapper.append('<div class="icon loading"></div>');
				pendingBackupChecks.push({ projectFp:fp.clone(), jTarget:jBackupWrapper });

				var act : ui.modal.ContextMenu.ContextActions = [
					{
						label: L.t._("Load from this folder"),
						iconId: "open",
						cb: onLoad.bind( dn.FilePath.fromFile(filePath).directory ),
					},
					{
						label: L.t._("Locate file"),
						iconId: "locate",
						cb: JsTools.locateFile.bind(filePath, true),
					},
					{
						label: L.t._("Assign custom color"),
						iconId: "color",
						cb: ()->{
							var cp = new ui.modal.dialog.ColorPicker(Const.getNicePalette(), col);
							cp.onValidate = (c)->{
								App.ME.forceDirColor(fp.directory, c);
								updateRecents();
							}
						},
						separatorBefore: true,
					},
					{
						label: L.t._("Reset assigned color"),
						iconId: "color",
						show: ()->App.ME.hasForcedDirColor(fp.directory),
						cb: ()->{
							App.ME.forceDirColor(fp.directory);
							updateRecents();
						},
					},
					{
						label: L.t._("Remove from history"),
						show: ()->!isBackupFile,
						cb: ()->{
							App.ME.unregisterRecentProject(filePath);
							updateRecents();
						},
						separatorBefore: true,
					},
					{
						label: L._Delete(L.t._("Backup file")),
						show: ()->isBackupFile,
						cb: ()->{
							NT.removeFile(filePath);
							App.ME.unregisterRecentProject(filePath);
							updateRecents();
						}
					},
					{
						label: L.t._("Clear all history"),
						cb: ()->{
							App.ME.clearRecentProjects();
							updateRecents();
						}
					},
				];
				ui.modal.ContextMenu.attachTo(jLi, act );

				jLi.appendTo(jRecentFiles);
			}

			catch( e:Dynamic ) {
				App.LOG.error("Problem with recent file: "+filePath);
				jLi.remove();
			}


			i--;
		}


		// Trim common parts in dirs
		var dirs = settings.v.recentDirs.map( dir->dn.FilePath.fromDir(dir) );
		dirs.reverse();

		// List dirs
		var jRecentDirs = jPage.find("ul.recentDirs");
		jRecentDirs.empty();
		if( dirs.length>0 )
			jRecentDirs.append('<li class="title">Recent folders</li>');
		for(fp in dirs) {
			var jLi = new J('<li/>');
			try {

				if( !NT.fileExists(fp.directory) )
					jLi.addClass("missing");

				if( App.ME.isInAppDir(fp.full,true) )
					jLi.addClass("sample");

				var shortFp = dn.FilePath.fromDir( fp.directory );
				var col = App.ME.getRecentDirColor(fp.directory);
				jLi.css("background-color", col.toCssRgba(App.ME.hasForcedDirColor(fp.directory) ? 0.4 : 0.1));
				jLi.append( JsTools.makePath( shortFp.full, col.toWhite(0.6) ) );
				jLi.click( (_)->{
					if( NT.fileExists(fp.directory) )
						onLoad(fp.directory);
					else {
						App.ME.unregisterRecentDir(fp.directory);

						// Try to open parent
						fp.removeLastDirectory();
						if( NT.fileExists(fp.directory) )
							onLoad(fp.directory);
						else
							N.error("Removed lost folder from history");

						updateRecents();
					}
				});

				var actions : ui.modal.ContextMenu.ContextActions = [
					{
						label: L.t._("New project in this folder"),
						iconId: "new",
						cb: onNew.bind(fp.directory),
					},
					{
						label: L.t._("Locate folder"),
						iconId: "locate",
						cb: JsTools.locateFile.bind(fp.directory, false),
					},
					{
						label: L.t._("Assign custom color"),
						iconId: "color",
						cb: ()->{
							var cp = new ui.modal.dialog.ColorPicker(Const.getNicePalette(), col);
							cp.onValidate = (c)->{
								App.ME.forceDirColor(fp.directory, c);
								updateRecents();
							}
						},
						separatorBefore: true,
					},
					{
						label: L.t._("Reset assigned color"),
						iconId: "color",
						show: ()->App.ME.hasForcedDirColor(fp.directory),
						cb: ()->{
							App.ME.forceDirColor(fp.directory);
							updateRecents();
						},
					},
					{
						label: L.t._("Remove from history"),
						cb: ()->{
							App.ME.unregisterRecentDir(fp.directory);
							updateRecents();
						},
						separatorBefore: true,
					},
					{
						label: L.t._("Clear all folder history"),
						cb: ()->{
							App.ME.clearRecentDirs();
							updateRecents();
						}
					},
				];
				ui.modal.ContextMenu.attachTo(jLi, actions);

				jLi.appendTo(jRecentDirs);

			}
			catch(e:Dynamic) {
				App.LOG.error("Problem with recent dir: "+fp.full);
				jLi.remove();
			}
		}

		JsTools.parseComponents(jRecentFiles);
	}


	public function onLoad(?openPath:String) {
		if( openPath==null )
			openPath = App.ME.getDefaultDialogDir();
		dn.js.ElectronDialogs.openFile(["."+Const.FILE_EXTENSION,".json"], openPath, function(filePath) {
			App.ME.loadProject(filePath);
		});
	}


	function onImport(ev:js.jquery.Event) {
		var ctx = new ui.modal.ContextMenu(ev);
		ctx.addTitle( L.t._("Import a project from another app") );
		ctx.setAnchor( MA_JQuery(new J(ev.target)) );
		ctx.addAction({
			label: L.t._("Ogmo 3 project"),
			cb: ()->onImportOgmo(),
		});
	}

	function onImportOgmo() {
		var dir = settings.getUiDir("ImportOgmo", App.ME.getDefaultDialogDir());

		dn.js.ElectronDialogs.openFile([".ogmo"], dir, function(filePath) {
			settings.storeUiDir("ImportOgmo", dn.FilePath.extractDirectoryWithoutSlash(filePath,true));
			var i = new importer.OgmoLoader(filePath);
			ui.modal.MetaProgress.start("Importing OGMO 3 project...", 3);
			delayer.addS( ()->{
				var p = i.load();
				i.log.printAllToLog(App.LOG);
				if( p!=null ) {
					ui.modal.MetaProgress.advance();
					new ui.ProjectSaver(this, p, (ok)->{
						ui.modal.MetaProgress.advance();
						N.success("Success!");
						App.ME.loadProject(p.filePath.full, (ok)->ui.modal.MetaProgress.completeCurrent());
					});
				}
				else {
					ui.modal.MetaProgress.closeCurrent();
					new ui.modal.dialog.LogPrint(i.log);
					new ui.modal.dialog.Message(L.t._("Failed to import this Ogmo project. If you really need this, feel free to send me the Ogmo project file so I can check and fix the updater (see contact link)."));
				}
			}, 0.1);
		});
	}


	function showSamples(anim=true) {
		jPage.find(".files").addClass("hasSamples");
		if( anim )
			jPage.find(".sampleProjects").slideDown(100);
		else
			jPage.find(".sampleProjects").show();
		settings.setUiStateBool( HideSamplesOnHome, false );
	}


	function hideSamples() {
		jPage.find(".sampleProjects").slideUp(60, ()->{
			if( !jPage.find(".assetLibrary").is(":visible") )
				jPage.find(".files").removeClass("hasSamples");
		});
		settings.setUiStateBool( HideSamplesOnHome, true );
	}


	function showAssetLibrary(anim=true) {
		jPage.find(".files").addClass("hasSamples");
		if( anim )
			jPage.find(".assetLibrary").slideDown(100);
		else
			jPage.find(".assetLibrary").show();
	}


	function hideAssetLibrary() {
		jPage.find(".assetLibrary").slideUp(60, ()->{
			if( !jPage.find(".sampleProjects").is(":visible") )
				jPage.find(".files").removeClass("hasSamples");
		});
	}


	public function onLoadSamples() {
		dn.js.ElectronDialogs.openFile(["."+Const.FILE_EXTENSION], JsTools.getSamplesDir(), function(filePath) {
			App.ME.loadProject(filePath);
		});
	}

	public function onNew(?openPath:String) {
		if( openPath==null )
			openPath = settings.getUiDir("NewProject", App.ME.getDefaultDialogDir());
		dn.js.ElectronDialogs.saveFileAs(["."+Const.FILE_EXTENSION], openPath, function(filePath) {
			var fp = dn.FilePath.fromFile(filePath);
			fp.extension = "ldtk";
			settings.storeUiDir("NewProject", fp.directory);

			function _createNew() {
				var p = data.Project.createEmpty(fp.full);

				var data = ui.ProjectSaver.prepareProjectSavingData(p);
				new ui.ProjectSaver(this, p, (success)->{
					if( success ) {
						N.msg("New project created: "+p.filePath.full);
						App.ME.loadPage( ()->new Editor(p), true );
					}
					else {
						N.error("Couldn't create this project file!");
					}
				});
			}

			// Check if file isn't in app dir
			if( App.ME.isInAppDir(fp.full, true) ) {
				new ui.modal.dialog.Choice(
					Lang.t._("<strong>WARNING:</strong> you are trying to create a project in the application directory!\n<strong>Any file saved here will be LOST during next app update.</strong>"),
					[
						{ label:"Create somewhere else", cb:onNew.bind(openPath) },
						{ label:"Ignore that (you will lose your project during next update)", className:"gray", cb:_createNew },
					]
				);
				return;
			}
			else
				_createNew();

		});
	}


	override function onKeyPress(keyCode:Int) {
		super.onKeyPress(keyCode);

		if( App.ME.isLocked() )
			return;

		switch keyCode {
			case K.W, K.Q:
				if( App.ME.isCtrlCmdDown() )
					App.ME.exit();

			case K.ENTER if( !ui.Modal.hasAnyOpen() ):
				jPage.find("ul.recentFiles li:not(.title):first").click();

			case K.ESCAPE:
				if( ui.Modal.hasAnyOpen() )
					ui.Modal.closeLatest();
				else if( jPage.find(".changelogsWrapper").hasClass("fullscreen") )
					jPage.find("button.fullscreen").click();

			// Open settings
			case K.F12 if( !App.ME.hasAnyToggleKeyDown() ):
				if( !ui.Modal.isOpen(ui.modal.dialog.EditAppSettings) )
					new ui.modal.dialog.EditAppSettings();
		}
	}


	override function update() {
		super.update();

		// Async lookup of backup dirs
		if( pendingBackupChecks.length>0 && !cd.hasSetS("asyncBackupCheck", 0.15) ) {
			var pb = pendingBackupChecks.shift();
			pb.jTarget.empty();

			// Parse project JSON
			var json : ldtk.Json.ProjectJson = try {
				var raw = NT.readFileString(pb.projectFp.full);
				haxe.Json.parse(raw);
			} catch(_) null;

			if( json!=null ) {
				// Check if backup files exist there
				var backupPath = pb.projectFp.directoryWithSlash + ( json.backupRelPath==null ? pb.projectFp.fileName+"/"+Const.BACKUP_DIR : json.backupRelPath );
				var all = ui.ProjectSaver.listBackupFiles(json.iid, backupPath);
				if( all.length>0 ) {
					var jBackups = new J('<button class="backups gray"/>');
					jBackups.appendTo(pb.jTarget);
					jBackups.append('<span class="icon history"/>');
					jBackups.click( (ev:js.jquery.Event)->{
						ev.stopPropagation();
						// List all backup files
						var ctx = new ui.modal.ContextMenu(ev);
						var crashBackups = [];
						for( b in all ) {
							if( b.crash )
								crashBackups.push(b.backup);

							ctx.addAction({
								label: ui.ProjectSaver.isCrashFile(b.backup.full) ? Lang.t._("Crash recovery"): Lang.relativeDate(b.date),
								className: b.crash ? "crash" : null,
								subText: Lang.date(b.date),
								cb: ()->App.ME.loadProject(b.backup.full, (p:data.Project)->{
									p.backupOriginalFile = pb.projectFp.clone();
								}),
							});
						}

						if( crashBackups.length>0 )
							ctx.addAction({
								label: L.t._("Delete all crash recovery files"),
								className: "warning",
								cb: ()->{
									new ui.modal.dialog.Confirm(
										L.t._("Delete all crash recovery files project ::name::?", { name: pb.projectFp.fileName}),
										true,
										()->{
											for(fp in crashBackups)
												NT.removeFile(fp.full);
											updateRecents();
										}
									);
								}
							});
					});
				}
			}


		}
	}
}
