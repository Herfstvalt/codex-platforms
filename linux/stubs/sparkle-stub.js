// Stub replacement for the Mac sparkle.node native module.
// Codex calls sparkleManager.initialize() before app startup; we no-op
// everything so the rest of the app can start. Auto-update is disabled.
//
// All methods return safe defaults that match what main-DlFGMsC6.js
// expects per its grepped usage:
//   - getInstallProgressPercent() -> number
//   - getIsUpdateReady() -> boolean
//   - getUpdateLifecycleState() -> string

module.exports = {
  initialize: async () => {},
  shutdown: async () => {},
  checkForUpdates: async () => ({ updateAvailable: false }),
  installUpdate: async () => {},
  getInstallProgressPercent: () => 0,
  getIsUpdateReady: () => false,
  getUpdateLifecycleState: () => 'idle',
  on: () => {},
  off: () => {},
  removeAllListeners: () => {},
};
