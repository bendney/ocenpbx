
conf = "/usr/local/freeswitch/conf"
dir  = conf .. "/directory/default"

local dbh = freeswitch.Dbh("pgsql://hostaddr=127.0.0.1 dbname=freeswitch user=freeswitch password='654321'");		-- sqlite database in subdirectory "db"

assert(dbh:connected());													-- exits the script if we didn't connect properly
os.execute('rm -r "'..dir..'"');
os.execute('mkdir "'..dir..'"');

dbh:query("select * from userinfo", function(row)
		freeswitch.consoleLog("notice", "Debug from database user " ..row.username.. " secret " ..row.password.. "\n");
		username = row.username;
		password = row.password;

		dest = dir .. "/" ..username.. ".xml"

		freeswitch.consoleLog("notice", "Debug from gen_directory.lua create user" ..username.. "...\n");

		local xml = {}
		table.insert(xml, [[<include>]]);
		table.insert(xml, [[	<user id="]] ..username.. [[">]]);
		table.insert(xml, [[		<params>]]);
		table.insert(xml, [[			<param name="password" value="]] ..password.. [["/>]]);
		table.insert(xml, [[			<param name="vm-password" value="]] ..username.. [["/>]]);
		table.insert(xml, [[		</params>]]);
		table.insert(xml, [[		<variables>]]);
		table.insert(xml, [[			<variable name="toll_allow" value="domestic,international,local"/>]]);
		table.insert(xml, [[			<variable name="accountcode" value="]] ..username.. [["/>]]);
		table.insert(xml, [[			<variable name="user_context" value="default"/>]]);
		table.insert(xml, [[			<variable name="effective_caller_id_name" value="]] ..username.. [["/>]]);
		table.insert(xml, [[			<variable name="effective_caller_id_number" value="]] ..username.. [["/>]]);
		table.insert(xml, [[			<variable name="outbound_caller_id_name" value="$${outbound_caller_name}"/>]]);
		table.insert(xml, [[			<variable name="outbound_caller_id_number" value="$${outbound_caller_id}"/>]]);
		table.insert(xml, [[			<variable name="callgroup" value="techsupport"/>]]);
		table.insert(xml, [[		</variables>]]);
		table.insert(xml, [[	</user>]]);
		table.insert(xml, [[</include>]]);
		XML_STRING = table.concat(xml, "\n");

	if (username == nil or password == nil) then
		--send not found but do not cache it
			XML_STRING = [[<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<document type="freeswitch/xml">
				<section name="result">
					<result status="not found" />
				</section>
			</document>]];
	end

		dest_file = io.open(dest, "w+");
		dest_file:write(XML_STRING);
		io.close(dest_file);

	end); 

dbh:release();

--api = freeswitch.API()
--api:execute("reloadxml")
