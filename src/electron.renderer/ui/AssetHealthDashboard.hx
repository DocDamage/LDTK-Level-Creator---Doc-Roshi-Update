package ui;

import misc.AssetLibrary;
import misc.AssetLibraryDiagnostics;
import misc.AssetLibraryDiagnostics.AssetLibraryPackHealth;

class AssetHealthDashboard {
	public static function open() {
		var w = new ui.modal.Dialog(null, "assetHealthDashboard");
		w.addTitle(L.t._("Asset Health"), true);
		new J('<div class="privateUseBanner">This dashboard checks the bundled atlas as it exists on this machine. It is read-only and intended to catch private-build asset drift before smoke testing.</div>').appendTo(w.jContent);

		var jLoading = new J('<div class="empty">Scanning bundled asset library...</div>');
		jLoading.appendTo(w.jContent);

		App.ME.delayer.addS(()->{
			jLoading.remove();
			renderReport(w, AssetLibraryDiagnostics.getHealthReport());
		}, 0.1);

		w.addClose();
	}

	static function addStat(jStats:js.jquery.JQuery, label:String, value:Int, ?warning=false) {
		var j = new J('<div class="healthStat"><strong></strong><span></span></div>');
		j.toggleClass("warning", warning);
		j.find("strong").text(Std.string(value));
		j.find("span").text(label);
		j.appendTo(jStats);
	}

	static function renderReport(w:ui.modal.Dialog, report:misc.AssetLibraryDiagnostics.AssetLibraryHealthReport) {
		var jStats = new J('<div class="healthStats"/>');
		jStats.appendTo(w.jContent);
		addStat(jStats, "packs", report.packCount);
		addStat(jStats, "issues", report.issueCount, report.issueCount>0);
		addStat(jStats, "missing folders", report.missingFolderCount, report.missingFolderCount>0);
		addStat(jStats, "missing thumbs", report.missingThumbCount, report.missingThumbCount>0);
		addStat(jStats, "no previews", report.noPreviewCount, report.noPreviewCount>0);
		addStat(jStats, "no starters", report.noStarterCount, report.noStarterCount>0);
		addStat(jStats, "blocked files", report.blockedExtCount, report.blockedExtCount>0);
		addStat(jStats, "large files", report.largeFileCount, report.largeFileCount>0);
		addStat(jStats, "missing refs", report.missingTemplateRefCount, report.missingTemplateRefCount>0);

		var jList = new J('<div class="healthList"/>');
		jList.appendTo(w.jContent);
		var shown = 0;
		for(health in report.packs)
			if( health.issues.length>0 ) {
				appendPackHealth(jList, health);
				shown++;
			}

		if( shown==0 )
			new J('<div class="empty">No asset health issues found.</div>').appendTo(w.jContent);
	}

	static function appendPackHealth(jList:js.jquery.JQuery, health:AssetLibraryPackHealth) {
		var pack = health.pack;
		var folder = AssetLibrary.getPackAbsPath(pack);
		var jItem = new J('<div class="healthItem"/>');
		jItem.appendTo(jList);

		var jHeader = new J('<div class="healthHeader"/>');
		jHeader.appendTo(jItem);
		new J('<strong/>').text(pack.name).appendTo(jHeader);
		new J('<span/>').text(AssetLibrary.getPackSubtitle(pack)).appendTo(jHeader);

		var jActions = new J('<div class="previewActions"/>');
		jActions.appendTo(jHeader);
		var jOpen = new J('<button type="button" class="gray" title="Open pack folder"><span class="icon open"></span></button>');
		jOpen.appendTo(jActions);
		jOpen.click((ev:js.jquery.Event)->{
			ev.stopPropagation();
			JsTools.locateFile(folder, false);
		});

		var jIssues = new J('<div class="healthIssues"/>');
		jIssues.appendTo(jItem);
		for(issue in health.issues)
			new J('<span/>').text(issue).appendTo(jIssues);
	}
}
