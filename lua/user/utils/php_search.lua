local M = {}

function M.search_method()
	if vim.bo.filetype ~= "php" then
		print("Not a PHP file")
		return
	end

	vim.ui.input({ prompt = "Describe what you want to do: " }, function(query)
		if not query or query == "" then
			return
		end

		local php_code = [[
$query = strtolower($argv[1]);
$results = [];

function getTypeName($type) {
    if ($type instanceof ReflectionNamedType) {
        return ($type->allowsNull() ? '?' : '') . $type->getName();
    } elseif ($type instanceof ReflectionUnionType) {
        $types = array_map(fn($t) => $t->getName(), $type->getTypes());
        return implode('|', $types);
    }
    return 'mixed';
}

// Get all PHP functions
$functions = get_defined_functions()['internal'];

foreach ($functions as $func) {
    if (!function_exists($func)) continue;
    
    if (strpos(strtolower($func), $query) === false) {
        continue;
    }
    
    try {
        $reflection = new ReflectionFunction($func);
        $params = [];
        
        foreach ($reflection->getParameters() as $param) {
            $paramStr = '$' . $param->getName();
            
            if ($param->hasType()) {
                $paramStr = getTypeName($param->getType()) . ' ' . $paramStr;
            }
            
            if ($param->isOptional() && $param->isDefaultValueAvailable()) {
                $default = $param->getDefaultValue();
                $paramStr .= ' = ' . var_export($default, true);
            }
            
            $params[] = $paramStr;
        }
        
        $signature = $func . '(' . implode(', ', $params) . ')';
        
        if ($reflection->hasReturnType()) {
            $signature .= ': ' . getTypeName($reflection->getReturnType());
        }
        
        $results[] = $signature;
        
    } catch (Exception $e) {
        continue;
    }
}

// Also search common class methods
$classes = ['DateTime', 'PDO', 'Exception', 'ArrayObject', 'SplFileObject'];
foreach ($classes as $className) {
    if (!class_exists($className)) continue;
    
    $reflection = new ReflectionClass($className);
    foreach ($reflection->getMethods(ReflectionMethod::IS_PUBLIC) as $method) {
        $methodName = $method->getName();
        
        if (strpos(strtolower($methodName), $query) === false) {
            continue;
        }
        
        $params = [];
        foreach ($method->getParameters() as $param) {
            $paramStr = '$' . $param->getName();
            
            if ($param->hasType()) {
                $paramStr = getTypeName($param->getType()) . ' ' . $paramStr;
            }
            
            if ($param->isOptional() && $param->isDefaultValueAvailable()) {
                $default = $param->getDefaultValue();
                $paramStr .= ' = ' . var_export($default, true);
            }
            
            $params[] = $paramStr;
        }
        
        $signature = $className . '::' . $methodName . '(' . implode(', ', $params) . ')';
        
        if ($method->hasReturnType()) {
            $signature .= ': ' . getTypeName($method->getReturnType());
        }
        
        $results[] = $signature;
    }
}

if (empty($results)) {
    echo "No methods found matching your query\n";
} else {
    foreach (array_slice($results, 0, 30) as $result) {
        echo $result . "\n";
    }
}
]]

		local cmd = string.format("php -r %s %s", vim.fn.shellescape(php_code), vim.fn.shellescape(query))
		local output = vim.fn.systemlist(cmd)

		if #output == 0 or (output[1] and output[1]:match("No methods found")) then
			print("No results found")
			return
		end

		local height = math.floor(vim.o.lines * 0.4)

		vim.cmd(height .. "split")
		local bufnr = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_win_set_buf(0, bufnr)

		vim.bo[bufnr].buftype = "nofile"
		vim.bo[bufnr].bufhidden = "wipe"
		vim.bo[bufnr].swapfile = false
		vim.bo[bufnr].filetype = "php"

		local header = { "Search results for: " .. query, string.rep("-", 80), "" }
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, header)
		vim.api.nvim_buf_set_lines(bufnr, #header, -1, false, output)
		vim.bo[bufnr].modifiable = false

		vim.keymap.set("n", "<CR>", function()
			vim.cmd("bwipeout! " .. bufnr)
		end, { buffer = bufnr, silent = true })

		vim.keymap.set("n", "h", function()
			local line = vim.api.nvim_get_current_line()
			local func_name = line:match("^([%w_]+)")
			if func_name then
				local url = "https://www.php.net/manual/en/function." .. func_name:gsub("_", "-") .. ".php"
				vim.fn.system("xdg-open " .. vim.fn.shellescape(url))
				print("Opening documentation for " .. func_name)
			end
		end, { buffer = bufnr, silent = true })

		vim.api.nvim_buf_set_name(bufnr, "PHP Search: " .. query)
		print("Press <CR> to close, 'h' to open php.net docs")
	end)
end

return M
