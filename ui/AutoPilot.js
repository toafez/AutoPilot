Ext.namespace("SYNO.SDS.AutoPilot.Utils");

Ext.define("SYNO.SDS.AutoPilot.Application", {
    extend: "SYNO.SDS.AppInstance",
    appWindowName: "SYNO.SDS.AutoPilot.MainWindow",
    constructor: function() {
        this.callParent(arguments);
    }
});

Ext.define("SYNO.SDS.AutoPilot.MainWindow", {
    extend: "SYNO.SDS.AppWindow",
    constructor: function(a) {
        this.appInstance = a.appInstance;
        SYNO.SDS.AutoPilot.MainWindow.superclass.constructor.call(this, Ext.apply({
            layout: "fit",
            resizable: true,
            cls: "syno-app-win",
            maximizable: true,
            minimizable: true,
            width: 1024,
            height: 768,
            html: SYNO.SDS.AutoPilot.Utils.getMainHtml()
        }, a));
        SYNO.SDS.AutoPilot.Utils.ApplicationWindow = this;
    },

    onOpen: function() {
        SYNO.SDS.AutoPilot.MainWindow.superclass.onOpen.apply(this, arguments);
    },

    onRequest: function(a) {
        SYNO.SDS.AutoPilot.MainWindow.superclass.onRequest.call(this, a);
    },

    onClose: function() {
        clearTimeout(SYNO.SDS.AutoPilot.TimeOutID);
        SYNO.SDS.AutoPilot.TimeOutID = undefined;
        SYNO.SDS.AutoPilot.MainWindow.superclass.onClose.apply(this, arguments);
        this.doClose();
        return true;
    }
});

Ext.apply(SYNO.SDS.AutoPilot.Utils, function() {
    return {
        getMainHtml: function() {
            // Timestamp must be inserted here to prevent caching of iFrame
            return '<iframe src="webman/3rdparty/AutoPilot/index.cgi?timestamp=' + new Date().getTime() + '" title="react-app" style="width: 100%; height: 100%; border: none; margin: 0" allowfullscreen></iframe>';
        },
    }
}())

