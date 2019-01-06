
local caller_id_number = session:getVariable("caller_id_number");
local destination_number = session:getVariable("destination_number");

freeswitch.consoleLog("notice", "Debug calller_id_number " ..caller_id_number.. " destination_number " ..destination_number.. "\n");

local caller_grade;
local callee_grade;
local dbh = freeswitch.Dbh("pgsql://hostaddr=127.0.0.1 dbname=freeswitch user=freeswitch password='654321'");		-- sqlite database in subdirectory "db"

assert(dbh:connected());													-- exits the script if we didn't connect properly

dbh:query("select * from userinfo where username='"..caller_id_number.. "'", function(row)
		freeswitch.consoleLog("notice", "Debug from database user " ..row.username.. " secret " ..row.password.. "\n");
                caller_grade = row.grade;

	if (username == nil or password == nil) then
		--send not found but do not cache it
	end

	end); 

dbh:query("select * from userinfo where username='"..destination_number.."'", function(row)
                freeswitch.consoleLog("notice", "Debug from database user " ..row.username.. " secret " ..row.password.. "\n");
                callee_grade = row.grade;

         end);

freeswitch.consoleLog("notice", "Debug caller grade " ..caller_grade.. " callee grade " ..callee_grade.. "\n");

dbh:release();

if (caller_grade < callee_grade) then
	freeswitch.consoleLog("notice", "Debug caller grade " ..caller_grade.. " less than callee grade " ..callee_grade.. "\n");
else
	freeswitch.consoleLog("notice", "Debug caller grade " ..caller_grade.. " greater than callee grade " ..callee_grade.. "\n");
	session:hangup();	
end

--api = freeswitch.API()
--api:execute("reloadxml")
