-- Plugin for Pest tests

return {
    "nvim-neotest/neotest",
    dependencies = {
        ...,
        "V13Axel/neotest-pest",
    },
    config = function()
        require("neotest").setup({
            adapters = {
                require('neotest-pest')({
                    ignore_dirs = { "vendor", "node_modules" },
                    root_ignore_files = { "phpunit-only.tests" },
                    test_file_suffixes = { "Test.php", "_test.php", "PestTest.php" },
                    sail_enabled = function() return false end,
                    sail_executable = "vendor/bin/sail",
                    sail_project_path = "/var/www/html",
                    pest_cmd = "vendor/bin/pest",
                    parallel = 5,
                    compact = false,
                    results_path = function() return "/some/accessible/path" end,
                }),
            }
        })
    end,
}
