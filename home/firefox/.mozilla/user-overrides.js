/* My user overrides on top of Arkenfox user.js ***/

user_pref("browser.sessionstore.interval", 3600000); // Reduce SSD writes
user_pref("browser.sessionstore.resume_from_crash", false);

// user_pref("layout.css.devPixelsPerPx", 1.3); // 1.3 for 4K, -1.0 for FHD

user_pref("keyword.enabled", true); // Allow url bar to interpret input as search

/* WELCOME & WHAT's NEW NOTICES ***/
user_pref("browser.startup.homepage_override.mstone", "ignore"); // master switch
user_pref("startup.homepage_welcome_url", "");
user_pref("startup.homepage_welcome_url.additional", "");
user_pref("startup.homepage_override_url", ""); // What's New page after updates

/* UX FEATURES: disable and hide the icons and menus ***/
user_pref("browser.messaging-system.whatsNewPanel.enabled", false); // What's New [FF69+]
user_pref("extensions.pocket.enabled", false); // Pocket Account [FF46+]
user_pref("identity.fxaccounts.enabled", false); // Firefox Accounts & Sync [FF60+] [RESTART]
user_pref("reader.parse-on-load.enabled", true); // Reader View

user_pref("signon.management.page.fileImport.enabled", true); // Enable import-from-file feature

user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true); // Enable <USER_PROFILE>/chrome/userChrome.css

user_pref("browser.uidensity", 1); // Make UI chrome denser

user_pref("identity.fxaccounts.enabled", true); // Firefox Accounts & Sync [FF60+] [RESTART]

 * [SETTING] Privacy & Security>History>Custom Settings>Clear history when Firefox closes | Settings ***/
user_pref("privacy.sanitize.sanitizeOnShutdown", false);

/** SANITIZE ON SHUTDOWN: IGNORES "ALLOW" SITE EXCEPTIONS ***/
/* 2811: set/enforce what items to clear on shutdown (if 2810 is true) [SETUP-CHROME]
 * [NOTE] If "history" is true, downloads will also be cleared
 * [NOTE] "sessions": Active Logins: refers to HTTP Basic Authentication [1], not logins via cookies
 * [1] https://en.wikipedia.org/wiki/Basic_access_authentication ***/
// user_pref("privacy.clearOnShutdown.cache", true);     // [DEFAULT: true]
// user_pref("privacy.clearOnShutdown.downloads", true); // [DEFAULT: true]
// user_pref("privacy.clearOnShutdown.formdata", true);  // [DEFAULT: true]
user_pref("privacy.clearOnShutdown.history", false);   // [DEFAULT: true]
// user_pref("privacy.clearOnShutdown.sessions", true);  // [DEFAULT: true]

