// skeleton.jsx — starting point for one headless AE op.
// Communicates results via a /tmp log (osascript AppleEvents time out; log is the source of truth).
// Reads optional control file (name of target comp etc.) from /tmp.
(function () {
    var LOG = "/tmp/ae_log.txt";
    var CONTROL = "/tmp/ae_control.txt"; // optional: e.g. "CompName|layer1,layer2|qaTimeSec"

    function log(msg) {
        var f = new File(LOG);
        f.open("a"); f.write(msg + "\n"); f.close(); // flush per step so a crash still leaves a trail
    }
    function readControl() {
        var f = new File(CONTROL);
        if (!f.exists) return null;
        f.open("r"); var t = f.read(); f.close(); return t;
    }
    // Clean stray temp comps from a previous crashed multi-export run.
    function cleanTempComps() {
        for (var i = app.project.numItems; i >= 1; i--) {
            var it = app.project.item(i);
            if (it instanceof CompItem && /^Temporary/.test(it.name)) { it.remove(); log("removed temp comp: " + it.name); }
        }
    }

    try {
        log("=== AE_START ===");
        cleanTempComps();
        var control = readControl();
        if (control) log("control: " + control);

        // ======== YOUR OP HERE ========
        // Do exactly ONE heavy op per dispatch (multiple exports in one run crash with
        // "Object is invalid"). Example: find a comp by name, tweak a property, QA it.
        // var comp = app.project.item(1);
        // ...
        // ===============================

        log("=== AE_DONE ===");
    } catch (e) {
        log("ERROR: " + e.toString() + (e.line ? (" @line " + e.line) : ""));
        log("=== AE_DONE ==="); // still mark done so dispatch.sh stops polling
    }
})();
