package ui;

import misc.AssetLibrary;
import misc.AssetLibrary.AssetLibraryStarterEntry;
import misc.AssetLibraryState;

class TemplateWizard {
	static var filter = "*";

	public static function open() {
		var entries = AssetLibrary.getAllStarterEntries();
		var w = new ui.modal.Dialog(null, "templateWizard");
		w.addTitle(L.t._("Template Wizard"), true);

		var jSummary = new J('<div class="privateUseBanner"/>');
		jSummary.text("Private asset mode: these bundled templates are for this personal Doc Roshi build and keep their source atlas references local.");
		jSummary.appendTo(w.jContent);

		var jTools = new J('<div class="assetBrowserActions templateTools"/>');
		jTools.appendTo(w.jContent);
		var jSearch = new J('<input type="text" placeholder="Search templates, packs, genres"/>');
		jSearch.appendTo(jTools);
		var jFilters = new J('<div class="assetFilters"/>');
		jFilters.appendTo(w.jContent);
		var jCount = new J('<button type="button" class="gray" disabled/>');
		jCount.appendTo(jTools);

		var jGrid = new J('<div class="templateGrid"/>');
		jGrid.appendTo(w.jContent);
		var jEmpty = new J('<div class="empty"/>').text("No matching templates").appendTo(w.jContent);
		var render : Void->Void = null;

		function addFilter(label:String, kind:String) {
			var jButton = new J('<button type="button"><span class="label"></span><span class="count"></span></button>');
			jButton.find(".label").text(label);
			jButton.attr("data-kind", kind);
			jButton.appendTo(jFilters);
			jButton.click((ev)->{
				filter = kind;
				render();
			});
		}

		addFilter("All", "*");
		addFilter("RPG", "rpg");
		addFilter("Platformer", "platformer");
		addFilter("Top-down", "topdown");
		addFilter("Horror/Audio", "horror");
		addFilter("CuteSCKR", "cutesckr");
		addFilter("Favorites", "favorites");
		addFilter("Recent", "recent");

		function matches(entry:AssetLibraryStarterEntry, kind:String, query:String) {
			var matchesKind = switch kind {
				case "*": true;
				case "favorites": AssetLibraryState.isFavoritePack(entry.pack.path);
				case "recent": AssetLibraryState.getRecentStarters().indexOf(entry.starter.absPath)>=0;
				case _: entry.category==kind;
			}
			return matchesKind && AssetLibrary.matchesTokens(entry.searchText, query);
		}

		function count(kind:String, query:String) {
			var n = 0;
			for(entry in entries)
				if( matches(entry, kind, query) )
					n++;
			return n;
		}

		function createFromStarter(entry:AssetLibraryStarterEntry) {
			var openPath = App.ME.settings.getUiDir("TemplateWizard", App.ME.getDefaultDialogDir());
			dn.js.ElectronDialogs.saveFileAs(["."+Const.FILE_EXTENSION], openPath, function(filePath:String) {
				try {
					var created = AssetLibrary.cloneStarterTo(entry.starter, filePath);
					App.ME.settings.storeUiDir("TemplateWizard", dn.FilePath.extractDirectoryWithoutSlash(created, true));
					AssetLibraryState.rememberStarter(entry.starter.absPath);
					N.success("Template project created");
					App.ME.loadProject(created);
					w.close();
				}
				catch(e:Dynamic) {
					App.LOG.error("Failed to create project from template "+entry.starter.absPath+": "+Std.string(e));
					new ui.modal.dialog.Warning(L.t._("Couldn't create this template project."));
				}
			});
		}

		function appendEntry(entry:AssetLibraryStarterEntry) {
			var jItem = new J('<div class="sample template templateWizardItem"/>');
			jItem.attr("title", entry.starter.absPath);
			jItem.appendTo(jGrid);

			var thumb = AssetLibrary.getThumbAbsPath(entry.pack);
			var jThumb = new J('<div class="thumb"/>');
			jThumb.appendTo(jItem);
			if( thumb.length>0 && NT.fileExists(thumb) )
				jThumb.css("background-image", 'url("${AssetLibrary.toFileUrl(thumb)}")');

			var jName = new J('<div class="name"/>');
			jName.appendTo(jItem);
			new J('<div class="packHeader"><span class="kind"></span><span class="count">LDtk</span></div>').appendTo(jName);
			jName.find(".kind").text(entry.category);
			new J('<strong/>').text(entry.starter.name).appendTo(jName);
			new J('<small/>').text(entry.pack.name).appendTo(jName);

			var jActions = new J('<div class="templateItemActions"/>');
			jActions.appendTo(jName);
			var jCreate = new J('<button type="button" title="Create project from this template"><span class="icon new"></span></button>');
			jCreate.appendTo(jActions);
			jCreate.click((ev:js.jquery.Event)->{
				ev.stopPropagation();
				createFromStarter(entry);
			});
			var jReveal = new J('<button type="button" class="gray" title="Reveal template file"><span class="icon locate"></span></button>');
			jReveal.appendTo(jActions);
			jReveal.click((ev:js.jquery.Event)->{
				ev.stopPropagation();
				JsTools.locateFile(entry.starter.absPath, true);
			});

			jItem.click((ev)->{
				AssetLibraryState.rememberStarter(entry.starter.absPath);
				App.ME.loadProject(entry.starter.absPath);
				w.close();
			});
		}

		render = function() {
			var query : String = jSearch.val();
			query = query==null ? "" : query;
			jGrid.empty();

			var visible = 0;
			for(entry in entries)
				if( matches(entry, filter, query) ) {
					visible++;
					appendEntry(entry);
				}

			jEmpty.toggle(visible==0);
			jGrid.toggle(visible>0);
			jCount.text(visible+" templates");
			jFilters.find("button").each((idx, e)->{
				var jButton = new J(e);
				var kind = jButton.attr("data-kind");
				jButton.toggleClass("active", kind==filter);
				jButton.find(".count").text(Std.string(count(kind, query)));
			});
		}

		jSearch.on("input", (_)->render());
		render();
		w.addClose();
	}
}
