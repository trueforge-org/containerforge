// Seed settings, copied to /config/settings.js only when it is missing or empty.
// The editor has no login by default. Add adminAuth here to protect it (not enabled by default).
module.exports = {
    uiPort: 1880,
    uiHost: "0.0.0.0",
    userDir: "/config",
    flowFile: "flows.json"
};
