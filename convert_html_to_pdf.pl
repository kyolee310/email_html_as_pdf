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

$ENV{'TEST_HOME'} = "/home/qa-server";
$ENV{'THIS_HOME'} = $ENV{'TEST_HOME'} . "/lib/send_qa_mail";
$ENV{'CACHE_HOME'} = "/tmp/temp/pdfcache";

sub print_time{
	my ($sec,$min,$hour,$mday,$mon,$year,$wday, $yday,$isdst)=localtime(time);
	my $this_time = sprintf "[%4d-%02d-%02d %02d:%02d:%02d]", $year+1900,$mon+1,$mday,$hour,$min,$sec;
	return $this_time;
};

sub print_output{
	my $str = shift @_;
	my $ts = print_time();
	my $outstr = "$ts [CONVERT_HTML_TO_PDF] [LOG]\t" . $str;
	print $outstr . "\n";
	return 0;
};

sub print_error{
	my $str = shift @_;
	my $ts = print_time();
	my $outstr = "$ts [CONVERT_HTML_TO_PDF] [ERROR]\t" . $str;
	print $outstr . "\n";
	exit(1);
};


####################################  MAIN  ##########################################

if( @ARGV < 1 ){
	print_error("USAGE : ./convert_html_to_pdf.pl <URL>");
};


my $input = shift @ARGV;

print_output("URL: { $input }");

my $html_file = download_url_to_file($input);

print_output("DOWNLOADED URL to a FILE: { $ENV{'CACHE_HOME'}/$html_file }");

prepare_html($html_file);

my $pdf_file = convert_html_to_pdf($html_file);

print_output("CONVERTED HTML to PDF: { $ENV{'CACHE_HOME'}/$pdf_file }");

exit(0);

1;

sub url_safe{
	my $url = shift @_;
	$url =~ s/\&/\\\&/;
	return $url;
};

sub download_url_to_file{

	my $url = shift @_;

	my $htmlfile = "";
	my $testname = "UNKNOWN";
	my $uid = "UNKNOWN";

	$url = url_safe($url);

	if( $url =~ /testname=([\w|-]+)/ ){
		$testname = $1;
	};

	if( $url =~ /uid=(\d+)/ ){
		$uid = $1;
	};

	my $pdf_file = $testname . "_UID-" . $uid . ".pdf";

	if( -e "$ENV{'CACHE_HOME'}/$pdf_file" ){
		print_output("CONVERTED HTML to PDF: { $ENV{'CACHE_HOME'}/$pdf_file }");
		exit(0);
	};

	$htmlfile = $testname . "_UID-" . $uid . ".html"; 

	if( -e $htmlfile ){
		my $prev_files = $testname . "_UID-*";
		system("rm -f $ENV{'CACHE_HOME'}/" . $prev_files . ".html");
		system("rm -f $ENV{'CACHE_HOME'}/" . $prev_files . ".pdf");
	};

	my $cmd = "wget $url -O $ENV{'CACHE_HOME'}/$htmlfile";
	system("$cmd");

	return $htmlfile;
};


sub prepare_html{
	my $htmlfile = shift @_;

	my $buf = "";

	open(HTML, "< $ENV{'CACHE_HOME'}/$htmlfile") or die $!;
	my $line;
	while($line=<HTML>){
		my @line_array = split("</a>", $line);
		foreach my $word (@line_array){
			if( $word =~ /(.*)<td>(.+)<td>(<a href="\S+\/artifacts"><font color="red">failed<br>.+)/ ){
			#	print "FROM\t" . $word . "\n\n";
				$word = "$1<td><font color=\"red\">$2</font><td>$3";
			#	print "TO" . $word . "\n\n";
			};
			$buf .= $word;
		};
	};
	close(HTML);

	system("rm -f $ENV{'CACHE_HOME'}/$htmlfile");

	open( FILTERED, "> $ENV{'CACHE_HOME'}/$htmlfile") or die $!;
	print FILTERED "$buf";
	close(FILTERTED);

	return 0;
};

sub convert_html_to_pdf{

	my $htmlfile = shift @_;

	my $pdffile = "temp.pdf";

	if( $htmlfile =~ /(.+)\.html/ ){
		$pdffile = $1 . ".pdf";
	};

	if( -e $pdffile ){
		system("rm -f $ENV{'CACHE_HOME'}/$pdffile");
	};

	my $cmd = "htmldoc --webpage -t pdf --size 13x11in --fontsize 10pt --color --linkcolor blue $ENV{'CACHE_HOME'}/$htmlfile > $ENV{'CACHE_HOME'}/$pdffile";
	system("$cmd");

	return $pdffile;;
};

# To make 'sed' command human-readable
# my_sed( target_text, new_text, filename);
#   --->
#        sed --in-place 's/ <target_text> / <new_text> /' <filename>
sub my_sed{

        my ($from, $to, $file) = @_;

        $from =~ s/([\'\"\/])/\\$1/g;
        $to =~ s/([\'\"\/])/\\$1/g;

        my $cmd = "sed --in-place 's/" . $from . "/" . $to . "/' " . $file;

        system($cmd);

        return 0;
}

1;

