
conf = "/usr/local/freeswitch/conf"
conference_dir  = conf .. "/dialplan/default/"

local dbh = freeswitch.Dbh("pgsql://hostaddr=127.0.0.1 dbname=freeswitch user=freeswitch password='654321'");		-- sqlite database in subdirectory "db"
assert(dbh:connected());												-- exits the script if we didn't connect properly

os.execute('rm -r "'..conference_dir..'"');
os.execute('mkdir "'..conference_dir..'"');

dbh:query("select * from conference", function(row)
		freeswitch.consoleLog("notice", "Debug from database confnum " ..row.confnum.. " confname " ..row.confname.. "\n");
		confnum = row.confnum;
		confname = row.confname;

		if (confnum == nil or confname == nil) then
			XML_STRING = [[<include></include>]];
		end
		freeswitch.consoleLog("notice", "Debug from gen_conference.lua reload conference " ..confname.. "...\n");

		conference_xml = conference_dir .. "/" ..confname.. ".xml"

		local xml = {}
		table.insert(xml, [[<include>]]);
		table.insert(xml, [[		<extension name="]] ..confname.. [[">]]);
		table.insert(xml, [[			<condition field="destination_number" expression="^]] ..confnum.. [[$">]]);
		table.insert(xml, [[			<action application="set" data="conference_auto_outcall_caller_id_name=]] ..confname.. [["/>]]);
		table.insert(xml, [[			<action application="set" data="conference_auto_outcall_caller_id_number=]] ..confnum.. [["/>]]);
		table.insert(xml, [[			<action application="set" data="conference_auto_outcall_timeout=60"/>]]);
		table.insert(xml, [[			<action application="set" data="conference_auto_outcall_flags=none"/>]]);
		table.insert(xml, [[			<action application="conference_set_auto_outcall" data="loopback/9664"/>]]);
		table.insert(xml, [[			<action application="conference" data="madboss@default"/>]]);
		table.insert(xml, [[			</condition>]]);
		table.insert(xml, [[		</extension>]]);
		table.insert(xml, [[</include>]]);

		XML_STRING = table.concat(xml, "\n");

		conference_file = io.open(conference_xml, "w+");
		conference_file:write(XML_STRING);
		io.close(conference_file);
	end); 

dbh:release();

--api = freeswitch.API()
--api:execute("reloadxml")
