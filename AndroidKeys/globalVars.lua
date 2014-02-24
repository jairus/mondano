--Explanation: This module allows access to variables across all files without making them 
--real globals. In other words, it makes the local table called 'globals' to act as a global table.
--Usage:
--from another file in the same folder use this line to access the 'globals' table:
--local g = require ("globalVars");
--Then, you can assign new variables inside the table and access them from any other file that calls this module.
--example: g.myVar = "New value";

--beginning of the module
local globals = {};

return globals;
--end of the module
