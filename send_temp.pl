#!/usr/bin/perl

use strict;

require "/home/qa-server/control_module/var/env_4_control_module.pl";
require "/home/qa-server/control_module/lib/control_module_db_ops.pl";
require "/home/qa-server/control_module/lib/control_module_event_handlers_COMMON.pl";

my $this_email = "kyo.lee\@eucalyptus.com";
my $this_subject = "pdf email test";
my $this_message = "blabla bla bal bal bal \n val val vla vla \n bla valva lvalv lavl abal \nRESULT URL\thttp://qa-server/euca-qa/display_test.php?testname=GA-windows-multinet-ubuntu1204-64&uid=1004";

control_common_send_result_email($this_email, $this_subject, $this_message);

exit(0);

1;


