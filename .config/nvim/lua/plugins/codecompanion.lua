-- CodeCompanion plugin is currently disabled.
-- The previous configuration has been removed to avoid
-- accidentally loading the plugin or leaking tokens.
-- We still return a valid Lazy spec with `enabled = false`
-- so Lazy can parse this module without error.

return {
	"olimorris/codecompanion.nvim",
	enabled = false,
}
