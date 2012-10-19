#!/usr/bin/perl

#    Licensed to the Apache Software Foundation (ASF) under one
#    or more contributor license agreements.  See the NOTICE file
#    distributed with this work for additional information
#    regarding copyright ownership.  The ASF licenses this file
#    to you under the Apache License, Version 2.0 (the
#    "License"); you may not use this file except in compliance
#    with the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing,
#    software distributed under the License is distributed on an
#    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#    KIND, either express or implied.  See the License for the
#    specific language governing permissions and limitations
#    under the License.
#
#    Contributor: Kyo Lee kyo.lee@eucalyptus.com


use strict;

$ENV{'CACHE_HOME'} = "/tmp/temp/pdfcache";
$ENV{'QA_LIB_HOME'} = "/home/qa-server/lib/";
$ENV{'QA_EMAIL'} = "kyo.lee\@eucalyptus.com";

my $this_email = "kyo.lee\@eucalyptus.com";
my $this_subject = "CONVERT HTML TO PDF TEST";
my $this_message = "blabla bla bal bal bal \n val val vla vla \n bla valva lvalv lavl abal \nRESULT URL\thttp://qa-server/euca-qa/display_test.php?testname=GA-windows-multinet-ubuntu1204-64&uid=1004";

control_common_send_result_email($this_email, $this_subject, $this_message);

exit(0);

sub url_safe{
	my $url = shift @_;
	$url =~ s/\&/\\\&/;
	return $url;
};

sub control_common_send_result_email{
	my ($to, $subject, $message) = @_;

	my $master_email = $ENV{'MASTER_EMAIL'};
	my $qa_email = $ENV{'QA_EMAIL'};

	if( $master_email eq "" ){
		$master_email = "kyo.lee\@eucalyptus.com";
	};

	if( $qa_email eq "" ){
                $qa_email = "kyo.lee\@eucalyptus.com";
        };

	if( $to ne $master_email ){
		sendMail_with_attachment($master_email, $qa_email, $subject, $message);		
	};
	sendMail_with_attachment($to, $qa_email, $subject, $message);

	return 0;
};


sub sendMail_with_attachment{
	my ($reciever, $sender, $subject, $message) = @_;

	my $result_url = "";;
	if( $message =~ /RESULT URL\s+(\S+)/m ){
		$result_url = $1;
	};

	$result_url = url_safe($result_url);

	my $message_file = "";
	my $testname = "UNKNOWN";
	my $uid = "UNKNOWN";

	if( $result_url =~ /testname=([\w|-]+)/ ){
		$testname = $1;
	};

	if( $result_url =~ /uid=(\d+)/ ){
		$uid = $1;
	};

	$message_file = $testname . "_UID-" . $uid . ".msg";

	system("echo \"$message\" > $ENV{'CACHE_HOME'}/$message_file");

	my $out = `perl $ENV{'QA_LIB_HOME'}/send_qa_mail/convert_html_to_pdf.pl $result_url`;

	my $pdf_location = "";
	if( $out =~ /CONVERTED HTML to PDF:\s+\{\s+(\S+)\s+\}/ ){
		$pdf_location = $1;
	};

	if( $pdf_location ne "" ){
		my $cmd = "export EMAIL=$ENV{'QA_EMAIL'} && mutt -s \"$subject\" -a $pdf_location -- $reciever < $ENV{'CACHE_HOME'}/$message_file ";
		print("$cmd\n");
		system("$cmd");
	}else{
		###	SEND NORMAL EMAIL
	};

	return 0;
};

1;


