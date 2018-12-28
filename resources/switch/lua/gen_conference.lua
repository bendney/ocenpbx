
conf = "/usr/local/freeswitch/conf"
dialplan_xml  = conf .. "/dialplan/default.xml"

local dbh = freeswitch.Dbh("pgsql://hostaddr=127.0.0.1 dbname=freeswitch user=freeswitch password='654321'");		-- sqlite database in subdirectory "db"

assert(dbh:connected());													-- exits the script if we didn't connect properly
os.execute('rm -r "'..dialplan_xml..'"');
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
			--send not found but do not cache it
			XML_STRING = [[<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<document type="freeswitch/xml">
				<section name="result">
					<result status="not found" />
				</section>
			</document>]];
		end

		freeswitch.consoleLog("notice", "Debug from gen_dialplan.lua reload conference " ..confname.. "...\n");

		local xml = {}
		table.insert(xml, [[<?xml version="1.0" encoding="utf-8"?>]]);
		table.insert(xml, [[<include>]]);
		table.insert(xml, [[	<context name="default">]]);
		table.insert(xml, [[		<extension name="Local_Extension">]]);
		table.insert(xml, [[			<condition field="destination_number" expression="^(\d+)$">]]);
		table.insert(xml, [[			<action application="export" data="dialed_extension=$1"/>]]);
		table.insert(xml, [[			<action application="bind_meta_app" data="1 b s execute_extension::dx XML features"/>]]);
		table.insert(xml, [[			<action application="bind_meta_app" data="2 b s record_session::$${recordings_dir}/${caller_id_number}.${strftime(%Y-%m-%d-%H-%M-%S)}.wav"/>]]);
		table.insert(xml, [[			<action application="bind_meta_app" data="3 b s execute_extension::cf XML features"/>]]);
		table.insert(xml, [[			<action application="bind_meta_app" data="4 b s execute_extension::att_xfer XML features"/>]]);
		table.insert(xml, [[			<action application="set" data="ringback=${us-ring}"/>]]);
		table.insert(xml, [[			<action application="set" data="transfer_ringback=$${hold_music}"/>]]);
		table.insert(xml, [[			<action application="set" data="call_timeout=30"/>]]);
		table.insert(xml, [[			<action application="set" data="hangup_after_bridge=true"/>]]);
		table.insert(xml, [[			<action application="set" data="continue_on_fail=true"/>]]);
		table.insert(xml, [[			<action application="hash" data="insert/${domain_name}-call_return/${dialed_extension}/${caller_id_number}"/>]]);
		table.insert(xml, [[			<action application="hash" data="insert/${domain_name}-last_dial_ext/${dialed_extension}/${uuid}"/>]]);
		table.insert(xml, [[			<action application="set" data="called_party_callgroup=${user_data(${dialed_extension}@${domain_name} var callgroup)}"/>]]);
		table.insert(xml, [[			<action application="hash" data="insert/${domain_name}-last_dial_ext/${called_party_callgroup}/${uuid}"/>]]);
		table.insert(xml, [[			<action application="hash" data="insert/${domain_name}-last_dial_ext/global/${uuid}"/>]]);
		table.insert(xml, [[			<action application="hash" data="insert/${domain_name}-last_dial/${called_party_callgroup}/${uuid}"/>]]);
		table.insert(xml, [[			<action application="bridge" data="user/${dialed_extension}@${domain_name}"/>]]);
		table.insert(xml, [[			<action application="answer"/>]]);
		table.insert(xml, [[			<action application="sleep" data="1000"/>]]);
		table.insert(xml, [[			<action application="bridge" data="loopback/app=voicemail:default ${domain_name} ${dialed_extension}"/>]]);
		table.insert(xml, [[			</condition>]]);
		table.insert(xml, [[		</extension>]]);
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
		table.insert(xml, [[	</context>]]);
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

dest_file = io.open(dialplan_xml, "w+");
dest_file:write(XML_STRING);
io.close(dest_file);

--api = freeswitch.API()
--api:execute("reloadxml")
